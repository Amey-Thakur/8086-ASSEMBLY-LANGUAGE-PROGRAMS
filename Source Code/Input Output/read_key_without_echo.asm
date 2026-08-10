; =============================================================================
; TITLE: Reading A Key Without Echoing It
; DESCRIPTION: Services 07h and 08h read a key without printing it, which is what a password prompt or a menu needs.
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
    HOWMANY EQU 4
    KEPT    DB HOWMANY DUP (0)

    M_TITLE DB 'Reading keys without showing them', 0DH, 0AH, '$'
    M_ASK   DB 'Type four characters (nothing will appear): $'
    M_STAR  DB '*$'
    M_GOT   DB 0DH, 0AH, 'What was actually typed: $'
    M_CODES DB 0DH, 0AH, 'As character codes: $'
    M_SPACE DB ' $'
    M_WHY   DB 0DH, 0AH, 0DH, 0AH
            DB 'Service 08h reads and checks for a break; 07h reads without '
            DB 'checking, which is what a password field wants.', 0DH, 0AH, '$'

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
    ; A STAR IS PRINTED FOR EACH KEY SO THE OPERATOR CAN SEE PROGRESS WITHOUT
    ; THE CHARACTER ITSELF APPEARING. THAT IS THE WHOLE TRICK BEHIND A PASSWORD
    ; PROMPT.
    ; -------------------------------------------------------------------------
    LEA DI, KEPT
    MOV CX, HOWMANY

EACH_KEY:
    MOV AH, 07H                         ; Read, no echo, no break check
    INT 21H

    MOV [DI], AL
    INC DI

    LEA DX, M_STAR
    CALL PRINT_MESSAGE
    LOOP EACH_KEY

    LEA DX, M_GOT
    CALL PRINT_MESSAGE
    LEA SI, KEPT
    MOV CX, HOWMANY
    CALL PRINT_TEXT

    ; -------------------------------------------------------------------------
    ; THE CODES AS WELL, BECAUSE A CONTROL CHARACTER READ THIS WAY WOULD BE
    ; INVISIBLE IN THE LINE ABOVE.
    ; -------------------------------------------------------------------------
    LEA DX, M_CODES
    CALL PRINT_MESSAGE
    LEA SI, KEPT
    MOV CX, HOWMANY

EACH_CODE:
    MOV BL, [SI]
    XOR BH, BH
    MOV AX, BX
    CALL PRINT_DECIMAL
    LEA DX, M_SPACE
    CALL PRINT_MESSAGE
    INC SI
    LOOP EACH_CODE

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
; 1. Three ways to read one key:
;    - 01h reads and echoes, which is what an ordinary prompt uses.
;    - 08h reads without echoing but still acts on a break key.
;    - 07h reads without echoing and without the break check, for raw input.
; 2. Show progress, not the character:
;    - Printing a star per key tells the operator the program is listening.
;    - Printing nothing at all makes a password prompt look frozen.
;    - The characters are kept in a buffer so they can be used afterwards.
; 3. Print the codes as well:
;    - A control character read this way leaves no visible trace.
;    - Showing the numeric code makes what happened unambiguous.
;    - This is how a keyboard is debugged when a key seems to do nothing.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
