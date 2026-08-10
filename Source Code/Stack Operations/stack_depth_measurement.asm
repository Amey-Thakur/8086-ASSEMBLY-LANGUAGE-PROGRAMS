; =============================================================================
; TITLE: Measuring How Deep The Stack Has Gone
; DESCRIPTION: Records the starting SP and reports the deepest point reached by a recursive routine, which is how a stack budget is set.
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
    BASE_W  DW 0                        ; SP as the program began
    LOW_W   DW 0FFFFH                   ; The lowest SP ever seen

    M_TITLE DB 'How much stack did it actually use?', 0DH, 0AH, '$'
    M_DEPTH DB 'Recursion depth requested: $'
    M_RESLT DB 'Factorial result:          $'
    M_USED  DB 'Bytes of stack consumed:   $'
    M_PER   DB 'Bytes per level:           $'
    M_ROOM  DB 'The .STACK directive reserved 256 bytes.', 0DH, 0AH, '$'
    M_SAFE  DB 'So this routine could nest about $'
    M_LEVEL DB ' levels before running out.', 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA DX, M_TITLE
    CALL PRINT_MESSAGE

    MOV BASE_W, SP                      ; Before anything is pushed

    LEA DX, M_DEPTH
    CALL PRINT_MESSAGE
    MOV AX, 6
    CALL PRINT_DECIMAL
    CALL NEWLINE

    MOV AX, 6
    CALL FACTORIAL

    LEA DX, M_RESLT
    CALL PRINT_MESSAGE
    CALL PRINT_DECIMAL
    CALL NEWLINE

    ; -------------------------------------------------------------------------
    ; THE DEEPEST POINT IS THE SMALLEST SP SEEN, BECAUSE THE STACK GROWS DOWN.
    ; SUBTRACTING IT FROM THE STARTING SP GIVES THE BYTES ACTUALLY USED.
    ; -------------------------------------------------------------------------
    MOV AX, BASE_W
    SUB AX, LOW_W
    MOV BX, AX                          ; Keep the total
    LEA DX, M_USED
    CALL PRINT_MESSAGE
    CALL PRINT_DECIMAL
    CALL NEWLINE

    ; Six levels were entered, so divide by six for the cost of one.
    MOV AX, BX
    XOR DX, DX
    MOV CX, 6
    DIV CX
    MOV BX, AX                          ; Bytes per level
    LEA DX, M_PER
    CALL PRINT_MESSAGE
    CALL PRINT_DECIMAL
    CALL NEWLINE
    CALL NEWLINE

    LEA DX, M_ROOM
    CALL PRINT_MESSAGE

    LEA DX, M_SAFE
    CALL PRINT_MESSAGE
    MOV AX, 256
    XOR DX, DX
    MOV CX, BX
    DIV CX
    CALL PRINT_DECIMAL
    LEA DX, M_LEVEL
    CALL PRINT_MESSAGE

    MOV AH, 4CH
    INT 21H

; -----------------------------------------------------------------------------
; FACTORIAL
;
; Returns AX factorial in AX, by recursion, so that the stack genuinely grows.
; Every entry records SP if it is the deepest yet seen.
; -----------------------------------------------------------------------------
FACTORIAL PROC
    PUSH BX

    ; ---- record the depth on the way in -------------------------------------
    MOV BX, SP
    CMP BX, LOW_W
    JAE NOT_DEEPEST
    MOV LOW_W, BX
NOT_DEEPEST:

    CMP AX, 1
    JBE BASE_CASE

    MOV BX, AX
    DEC AX
    CALL FACTORIAL                      ; AX = (n-1) factorial
    MUL BX                              ; times n
    JMP FACTORIAL_DONE

BASE_CASE:
    MOV AX, 1

FACTORIAL_DONE:
    POP BX
    RET
FACTORIAL ENDP

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
; 1. The deepest point is the smallest SP:
;    - The stack grows towards lower addresses, so deeper means numerically smaller.
;    - JAE rather than JBE is therefore the right test for "not a new record".
;    - The comparison is unsigned, because SP is an unsigned offset.
; 2. What each level costs:
;    - One pushed BX and one return address, so four bytes per level here.
;    - A procedure with a frame and locals costs considerably more.
;    - Measuring beats guessing, which is the entire point of this program.
; 3. Setting the budget:
;    - .STACK 100H reserves 256 bytes, and the measured cost says how deep that goes.
;    - Overflow on an 8086 is silent: it simply writes over whatever lies below.
;    - A recursive routine on a fixed stack needs a depth limit or a measured guarantee.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
