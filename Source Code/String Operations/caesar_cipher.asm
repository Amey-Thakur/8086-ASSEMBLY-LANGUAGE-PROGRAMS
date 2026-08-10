; =============================================================================
; TITLE: Caesar Cipher
; DESCRIPTION: Shifts every letter along the alphabet by a fixed amount and
;              shifts it back, leaving anything that is not a letter alone.
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
    PLAIN   DB 'Attack at Dawn, 0600!'
    TEXTLEN EQU $ - PLAIN
    SHIFT   EQU 3
    WORKING DB TEXTLEN DUP(0)
    M_PLAIN DB 'Plain:     $'
    M_CIPH  DB 'Encrypted: $'
    M_BACK  DB 'Decrypted: $'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA DX, M_PLAIN
    MOV AH, 09H
    INT 21H
    LEA SI, PLAIN
    MOV CX, TEXTLEN
    CALL PRINT_TEXT
    CALL NEWLINE

    ; Encrypt into the working buffer
    LEA SI, PLAIN
    LEA DI, WORKING
    MOV CX, TEXTLEN
    MOV BL, SHIFT
    CALL SHIFT_TEXT

    LEA DX, M_CIPH
    MOV AH, 09H
    INT 21H
    LEA SI, WORKING
    MOV CX, TEXTLEN
    CALL PRINT_TEXT
    CALL NEWLINE

    ; Shifting back by the same amount should return the original
    LEA SI, WORKING
    LEA DI, WORKING
    MOV CX, TEXTLEN
    MOV BL, 26 - SHIFT
    CALL SHIFT_TEXT

    LEA DX, M_BACK
    MOV AH, 09H
    INT 21H
    LEA SI, WORKING
    MOV CX, TEXTLEN
    CALL PRINT_TEXT
    CALL NEWLINE

    MOV AH, 4CH
    INT 21H

; -----------------------------------------------------------------------------
; SHIFT_TEXT
;
; Shifts CX characters from DS:SI into DS:DI by BL places, wrapping within
; each case and passing anything that is not a letter through unchanged.
; -----------------------------------------------------------------------------
SHIFT_TEXT PROC
    PUSH AX
    PUSH CX
    PUSH SI
    PUSH DI

ST_LOOP:
    MOV AL, [SI]

    ; -------------------------------------------------------------------------
    ; THE TWO CASES ARE HANDLED SEPARATELY BECAUSE THEY OCCUPY DIFFERENT
    ; RANGES. ANYTHING OUTSIDE BOTH IS COPIED WITHOUT BEING TOUCHED, WHICH IS
    ; WHAT KEEPS THE PUNCTUATION AND THE DIGITS READABLE.
    ; -------------------------------------------------------------------------
    CMP AL, 'A'
    JB  ST_STORE
    CMP AL, 'Z'
    JA  ST_TRY_LOWER

    SUB AL, 'A'                         ; Down to 0 to 25
    ADD AL, BL
    CALL WRAP_26
    ADD AL, 'A'
    JMP ST_STORE

ST_TRY_LOWER:
    CMP AL, 'a'
    JB  ST_STORE
    CMP AL, 'z'
    JA  ST_STORE

    SUB AL, 'a'
    ADD AL, BL
    CALL WRAP_26
    ADD AL, 'a'

ST_STORE:
    MOV [DI], AL
    INC SI
    INC DI
    LOOP ST_LOOP

    POP DI
    POP SI
    POP CX
    POP AX
    RET
SHIFT_TEXT ENDP

; -----------------------------------------------------------------------------
; WRAP_26
;
; Brings AL back inside 0 to 25 by subtracting 26 if it has run past.
; -----------------------------------------------------------------------------
WRAP_26 PROC
    CMP AL, 26
    JB  W_DONE
    SUB AL, 26

W_DONE:
    RET
WRAP_26 ENDP

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

END START

; =============================================================================
; TECHNICAL NOTES
; =============================================================================
; 1. WHY EACH CASE IS SEPARATE:
;    - 'A' is 65 and 'a' is 97, so one wrapping calculation cannot serve
;    - both. Reducing to 0 to 25 first is what makes the wrap a single
;    - comparison.
; 2. DECRYPTING IS THE SAME ROUTINE:
;    - Shifting by 26 less the key undoes it, so no second routine is
;    - needed. Running both and comparing against the original is the
;    - cheapest test that the cipher is correct.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
