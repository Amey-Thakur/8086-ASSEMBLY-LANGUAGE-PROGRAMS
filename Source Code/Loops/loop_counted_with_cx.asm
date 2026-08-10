; =============================================================================
; TITLE: The Counted Loop
; DESCRIPTION: The plainest use of LOOP: run a body a fixed number of times,
;              with CX as the counter the instruction maintains for you.
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
    TIMES  EQU 5
    MSG    DB 'Pass number $'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    MOV CX, TIMES
    MOV BX, 0                           ; A separate counter for display

BODY:
    INC BX

    PUSH CX                             ; The body must not disturb CX
    LEA DX, MSG
    MOV AH, 09H
    INT 21H
    MOV AX, BX
    CALL PRINT_DECIMAL
    CALL NEWLINE
    POP CX

    ; -------------------------------------------------------------------------
    ; LOOP DOES TWO THINGS: DECREMENT CX, AND BRANCH IF IT IS STILL NON ZERO.
    ; IT IS EXACTLY EQUIVALENT TO DEC CX FOLLOWED BY JNZ, IN ONE BYTE LESS.
    ; -------------------------------------------------------------------------
    LOOP BODY

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

END START

; =============================================================================
; TECHNICAL NOTES
; =============================================================================
; 1. CX IS NOT OPTIONAL:
;    - LOOP always counts in CX. Any body that needs CX for something
;    - else has to save and restore it, as this one does around the
;    - printing.
; 2. LOOP DOES NOT TOUCH THE FLAGS:
;    - Unlike DEC, LOOP leaves every flag alone. A comparison made before
;    - the loop is still readable after it, which DEC and JNZ would have
;    - destroyed.
; 3. THE RANGE:
;    - LOOP is a short jump, so the body has to fit within 128 bytes. A
;    - longer body needs DEC CX and JNZ, which can reach further.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
