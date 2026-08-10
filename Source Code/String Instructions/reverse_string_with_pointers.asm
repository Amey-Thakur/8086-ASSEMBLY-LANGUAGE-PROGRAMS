; =============================================================================
; TITLE: Reversing a String In Place
; DESCRIPTION: Reverses a string by swapping from both ends inward, which needs
;              half as many exchanges as characters.
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
    TEXT    DB 'ASSEMBLY'
    LENGTH  EQU 8
    OUT_BUF DB 10 DUP('$')
    M_IN    DB 'Before: ASSEMBLY', 0DH, 0AH, '$'
    M_OUT   DB 'After:  $'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX
    MOV ES, AX

    LEA DX, M_IN
    MOV AH, 09H
    INT 21H

    ; -------------------------------------------------------------------------
    ; ONE POINTER STARTS AT EACH END AND THEY MOVE TOWARD EACH OTHER. THE LOOP
    ; RUNS HALF THE LENGTH, BECAUSE EACH PASS PUTS TWO CHARACTERS IN PLACE.
    ; -------------------------------------------------------------------------
    LEA SI, TEXT                        ; The front
    LEA DI, TEXT
    ADD DI, LENGTH - 1                  ; The back
    MOV CX, LENGTH / 2

SWAP_LOOP:
    MOV AL, [SI]
    MOV BL, [DI]
    MOV [SI], BL
    MOV [DI], AL

    INC SI
    DEC DI
    LOOP SWAP_LOOP

    ; Show the result
    LEA SI, TEXT
    LEA DI, OUT_BUF
    MOV CX, LENGTH
    CLD
    REP MOVSB
    MOV BYTE PTR [DI], '$'

    LEA DX, M_OUT
    MOV AH, 09H
    INT 21H
    LEA DX, OUT_BUF
    MOV AH, 09H
    INT 21H
    CALL NEWLINE

    MOV AH, 4CH
    INT 21H

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
; 1. HALF THE LENGTH, NOT ALL OF IT:
;    - Running the full length would swap every pair twice and leave the
;    - string exactly as it started. An odd length leaves the middle
;    - character alone, which is correct.
; 2. NO SECOND BUFFER:
;    - The reversal happens where the string already is. A copy into a
;    - second buffer would need as much memory again for no benefit.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
