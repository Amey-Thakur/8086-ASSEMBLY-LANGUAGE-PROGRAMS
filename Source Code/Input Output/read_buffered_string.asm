; =============================================================================
; TITLE: Reading A Line With A Buffered Input
; DESCRIPTION: Service 0Ah reads a whole line into a buffer whose first two bytes describe it, which is what makes backspace work.
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
    ; The buffer DOS wants: capacity, then the count it fills in, then the text.
    ; The capacity counts the carriage return, so room for 30 characters means 31.
    CAPACITY EQU 31
    BUFFER   DB CAPACITY                ; What the program allows
             DB 0                       ; What DOS actually read
             DB CAPACITY DUP ('$')      ; The characters, and a terminator

    M_TITLE DB 'Service 0Ah: a whole line, editable as it is typed', 0DH, 0AH, '$'
    M_ASK   DB 'Type a name and press Enter: $'
    M_GOT   DB 0DH, 0AH, 'DOS reported $'
    M_CHARS DB ' characters: $'
    M_ROOM  DB 0DH, 0AH, 'Capacity offered: $'
    M_LEFT  DB ', unused: $'
    M_WHY   DB 0DH, 0AH, 0DH, 0AH
            DB 'The count is written into the second byte, so the program never '
            DB 'has to look for the carriage return itself.', 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA DX, M_TITLE
    CALL PRINT_MESSAGE
    LEA DX, M_ASK
    CALL PRINT_MESSAGE

    ; -------------------------------------------------------------------------
    ; DX POINTS AT THE FIRST BYTE OF THE THREE PART BUFFER, NOT AT THE TEXT.
    ; POINTING IT AT THE TEXT IS THE USUAL MISTAKE AND MAKES DOS TREAT THE FIRST
    ; CHARACTER AS THE CAPACITY.
    ; -------------------------------------------------------------------------
    LEA DX, BUFFER
    MOV AH, 0AH
    INT 21H

    ; ---- the count DOS filled in --------------------------------------------
    MOV BL, BUFFER + 1
    XOR BH, BH

    LEA DX, M_GOT
    CALL PRINT_MESSAGE
    MOV AX, BX
    CALL PRINT_DECIMAL

    LEA DX, M_CHARS
    CALL PRINT_MESSAGE
    LEA SI, BUFFER + 2
    MOV CX, BX
    CALL PRINT_TEXT

    LEA DX, M_ROOM
    CALL PRINT_MESSAGE
    MOV AX, CAPACITY
    CALL PRINT_DECIMAL

    LEA DX, M_LEFT
    CALL PRINT_MESSAGE
    MOV AX, CAPACITY
    SUB AX, BX
    CALL PRINT_DECIMAL

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
; PRINT_TEXT
;
; Prints CX characters starting at DS:SI. Both are left as they were found.
; -----------------------------------------------------------------------------
PRINT_TEXT PROC
    PUSH AX
    PUSH CX
    PUSH DX
    PUSH SI

    JCXZ PT_DONE                        ; Nothing to print

PT_LOOP:
    MOV DL, [SI]
    MOV AH, 02H
    INT 21H
    INC SI
    LOOP PT_LOOP

PT_DONE:
    POP SI
    POP DX
    POP CX
    POP AX
    RET
PRINT_TEXT ENDP

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
; 1. Three parts to the buffer:
;    - Byte zero is the capacity the program sets, and DOS will not exceed it.
;    - Byte one is the count DOS writes back, not counting the carriage return.
;    - The text starts at byte two, so the string is at the buffer plus two.
; 2. Why 0Ah and not a loop of 01h:
;    - DOS handles backspace, so the operator can correct a mistyped line.
;    - A loop reading single characters would have to implement editing itself.
;    - The count arrives ready made, with no scan for the terminator.
; 3. Capacity includes the return:
;    - A capacity of 31 leaves room for 30 characters and the carriage return.
;    - Setting it to the buffer size exactly overruns by one byte.
;    - DOS simply refuses further input once the limit is reached; it does not overflow.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
