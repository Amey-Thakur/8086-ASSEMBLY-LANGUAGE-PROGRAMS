; =============================================================================
; TITLE: How The Stack Pointer Moves
; DESCRIPTION: Reports SP before and after each push and pop, showing that the stack grows downwards two bytes at a time.
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
    M_TITLE DB 'The stack grows downwards, two bytes at a time', 0DH, 0AH, '$'
    M_START DB 'SP at the start:        $'
    M_PUSH1 DB 'after PUSH 1111:        $'
    M_PUSH2 DB 'after PUSH 2222:        $'
    M_PUSH3 DB 'after PUSH 3333:        $'
    M_POP1  DB 'after one POP:          $'
    M_POP2  DB 'after the second POP:   $'
    M_POP3  DB 'after the third POP:    $'
    M_DROP  DB 'Each push costs two bytes and each pop returns them.', 0DH, 0AH, '$'
    M_ORDER DB 'The pops came back 3333 2222 1111, the reverse of the pushes.', 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA DX, M_TITLE
    CALL PRINT_MESSAGE

    ; -------------------------------------------------------------------------
    ; SP IS REPORTED THROUGH BX BECAUSE PRINT_DECIMAL ITSELF PUSHES, WHICH
    ; WOULD CHANGE THE VERY NUMBER BEING REPORTED IF IT WERE READ ANY LATER.
    ; -------------------------------------------------------------------------
    MOV BX, SP
    LEA DX, M_START
    CALL PRINT_MESSAGE
    MOV AX, BX
    CALL PRINT_DECIMAL
    CALL NEWLINE

    MOV AX, 1111
    PUSH AX
    MOV BX, SP
    LEA DX, M_PUSH1
    CALL PRINT_MESSAGE
    MOV AX, BX
    CALL PRINT_DECIMAL
    CALL NEWLINE

    MOV AX, 2222
    PUSH AX
    MOV BX, SP
    LEA DX, M_PUSH2
    CALL PRINT_MESSAGE
    MOV AX, BX
    CALL PRINT_DECIMAL
    CALL NEWLINE

    MOV AX, 3333
    PUSH AX
    MOV BX, SP
    LEA DX, M_PUSH3
    CALL PRINT_MESSAGE
    MOV AX, BX
    CALL PRINT_DECIMAL
    CALL NEWLINE

    POP AX                              ; 3333
    MOV BX, SP
    LEA DX, M_POP1
    CALL PRINT_MESSAGE
    MOV AX, BX
    CALL PRINT_DECIMAL
    CALL NEWLINE

    POP AX                              ; 2222
    MOV BX, SP
    LEA DX, M_POP2
    CALL PRINT_MESSAGE
    MOV AX, BX
    CALL PRINT_DECIMAL
    CALL NEWLINE

    POP AX                              ; 1111
    MOV BX, SP
    LEA DX, M_POP3
    CALL PRINT_MESSAGE
    MOV AX, BX
    CALL PRINT_DECIMAL
    CALL NEWLINE
    CALL NEWLINE

    LEA DX, M_DROP
    CALL PRINT_MESSAGE
    LEA DX, M_ORDER
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
; 1. Full descending:
;    - PUSH subtracts two from SP and then writes at the new SP.
;    - POP reads at SP and then adds two.
;    - SP therefore points at the last item pushed, not at the next free slot.
; 2. Always words:
;    - There is no byte push on an 8086; PUSH AL does not exist.
;    - Every push and pop moves exactly two bytes, so SP stays even.
;    - An odd SP would cost an extra bus cycle on every stack access.
; 3. Why SP is copied to BX first:
;    - PRINT_DECIMAL pushes registers of its own, which moves SP while it runs.
;    - Reading SP into BX before the call captures the value being reported.
;    - Measuring anything with the tool that disturbs it is the general hazard here.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
