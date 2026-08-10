; =============================================================================
; TITLE: Jumping Into A Table Of Addresses
; DESCRIPTION: A computed jump reaches one of several handlers in constant time, however many there are.
; AUTHOR: Amey Thakur (https://github.com/Amey-Thakur)
; REPOSITORY: https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
; LICENSE: MIT License
; =============================================================================

.MODEL SMALL
.STACK 100H

; -----------------------------------------------------------------------------
; DATA SEGMENT
; -----------------------------------------------------------------------------
.DATA
    ; The address of each handler, in order. The assembler fills these in, so
    ; moving a handler cannot leave the table pointing at the wrong one.
    HANDLERS DW HANDLE_ADD, HANDLE_SUB, HANDLE_MUL, HANDLE_DIV, HANDLE_MOD
    CHOICES  EQU 5

    LEFT_W  DW 60
    RIGHT_W DW 7

    REQUEST DB 0, 1, 2, 3, 4, 9
    HOWMANY EQU 6

    M_TITLE DB 'One computed jump instead of a ladder of comparisons', 0DH, 0AH, '$'
    M_CASE  DB 0DH, 0AH, 'request $'
    M_ADD   DB '   add:       $'
    M_SUB   DB '   subtract:  $'
    M_MUL   DB '   multiply:  $'
    M_DIV   DB '   divide:    $'
    M_MOD   DB '   remainder: $'
    M_BAD   DB '   out of range, refused', 0DH, 0AH, '$'
    M_WHY   DB 0DH, 0AH, 0DH, 0AH
            DB 'Every choice costs the same. A ladder of comparisons costs more '
            DB 'for the later ones, which is why a long menu uses a table.'
            DB 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA DX, M_TITLE
    CALL PRINT_MESSAGE

    XOR SI, SI
    MOV CX, HOWMANY

EACH_REQUEST:
    PUSH CX

    MOV BL, REQUEST[SI]
    XOR BH, BH

    LEA DX, M_CASE
    CALL PRINT_MESSAGE
    MOV AX, BX
    CALL PRINT_DECIMAL

    ; -------------------------------------------------------------------------
    ; THE RANGE CHECK IS NOT OPTIONAL. AN INDEX PAST THE END OF THE TABLE READS
    ; WHATEVER FOLLOWS IT AND JUMPS THERE, WHICH IS THE WORST KIND OF FAILURE:
    ; SILENT, AND DIFFERENT EVERY TIME THE DATA MOVES.
    ; -------------------------------------------------------------------------
    CMP BX, CHOICES
    JB IN_RANGE

    LEA DX, M_BAD
    CALL PRINT_MESSAGE
    JMP NEXT_REQUEST

IN_RANGE:
    SHL BX, 1                           ; Addresses are words
    JMP HANDLERS[BX]

HANDLE_ADD:
    LEA DX, M_ADD
    CALL PRINT_MESSAGE
    MOV AX, LEFT_W
    ADD AX, RIGHT_W
    CALL PRINT_DECIMAL
    CALL NEWLINE
    JMP NEXT_REQUEST

HANDLE_SUB:
    LEA DX, M_SUB
    CALL PRINT_MESSAGE
    MOV AX, LEFT_W
    SUB AX, RIGHT_W
    CALL PRINT_DECIMAL
    CALL NEWLINE
    JMP NEXT_REQUEST

HANDLE_MUL:
    LEA DX, M_MUL
    CALL PRINT_MESSAGE
    MOV AX, LEFT_W
    MOV BX, RIGHT_W
    MUL BX
    CALL PRINT_DECIMAL
    CALL NEWLINE
    JMP NEXT_REQUEST

HANDLE_DIV:
    LEA DX, M_DIV
    CALL PRINT_MESSAGE
    MOV AX, LEFT_W
    XOR DX, DX
    MOV BX, RIGHT_W
    DIV BX
    CALL PRINT_DECIMAL
    CALL NEWLINE
    JMP NEXT_REQUEST

HANDLE_MOD:
    LEA DX, M_MOD
    CALL PRINT_MESSAGE
    MOV AX, LEFT_W
    XOR DX, DX
    MOV BX, RIGHT_W
    DIV BX
    MOV AX, DX                          ; The remainder, not the quotient
    CALL PRINT_DECIMAL
    CALL NEWLINE

NEXT_REQUEST:
    INC SI
    POP CX
    LOOP EACH_REQUEST

    LEA DX, M_WHY
    CALL PRINT_MESSAGE

    MOV AH, 4CH
    INT 21H

; -----------------------------------------------------------------------------
; PRINT_DECIMAL
;
; Prints the unsigned value in AX as decimal, with no leading zeros.
; Every register it touches is restored, so a caller can rely on it.
; -----------------------------------------------------------------------------
PRINT_DECIMAL PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX

    XOR CX, CX                          ; How many digits have been stacked
    MOV BX, 10

PD_DIVIDE:
    XOR DX, DX                          ; DX:AX is the dividend, so clear DX
    DIV BX                              ; AX = quotient, DX = this digit
    PUSH DX                             ; Digits arrive lowest first
    INC CX
    OR  AX, AX
    JNZ PD_DIVIDE                       ; Keep going until the quotient is zero

PD_EMIT:
    POP DX                              ; Unstacking reverses them into order
    ADD DL, '0'
    MOV AH, 02H
    INT 21H
    LOOP PD_EMIT

    POP DX
    POP CX
    POP BX
    POP AX
    RET
PRINT_DECIMAL ENDP

; -----------------------------------------------------------------------------
; NEWLINE
;
; Moves to the start of the next line. DOS needs both characters: the return
; moves the cursor to column zero and the feed moves it down a line.
; -----------------------------------------------------------------------------
NEWLINE PROC
    PUSH AX
    PUSH DX

    MOV DL, 0DH
    MOV AH, 02H
    INT 21H
    MOV DL, 0AH
    MOV AH, 02H
    INT 21H

    POP DX
    POP AX
    RET
NEWLINE ENDP

; -----------------------------------------------------------------------------
; PRINT_MESSAGE
;
; Prints the dollar terminated string at DS:DX, leaving AX exactly as it was.
;
; Service 09H needs the service number in AH, and AH is the top half of AX. A
; caller that has just computed a result into AX and then sets AH for itself
; destroys that result: 500 becomes 09F4H, which prints as 2548. Doing the call
; in here, around a push and a pop, removes the trap for good.
; -----------------------------------------------------------------------------
PRINT_MESSAGE PROC
    PUSH AX

    MOV AH, 09H
    INT 21H

    POP AX
    RET
PRINT_MESSAGE ENDP

END START

; =============================================================================
; TECHNICAL NOTES
; =============================================================================
; 1. Constant time, whatever the choice:
;    - A multiply, a memory read and a jump, however many handlers there are.
;    - A ladder of comparisons costs one comparison per choice skipped.
;    - For five choices it hardly matters; for fifty it is the difference.
; 2. The range check is the whole safety:
;    - An index past the end reads whatever bytes follow the table and jumps there.
;    - That is a jump to an address nobody chose, and it moves whenever the data does.
;    - JB against the count, before the shift, is the entire defence.
; 3. Let the assembler fill the table:
;    - DW HANDLE_ADD stores the address the assembler gave that label.
;    - Writing the offsets by hand means editing them whenever a handler moves.
;    - The table and the handlers cannot drift apart if only one of them is written down.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
