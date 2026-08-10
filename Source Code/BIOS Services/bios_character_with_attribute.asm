; =============================================================================
; TITLE: Writing a Character with a Colour
; DESCRIPTION: Uses service 09h to place a character with a chosen colour, and
;              repeats it, which teletype output cannot do.
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
    M_HEAD  DB 'A bar drawn with service 09h:', 0DH, 0AH, '$'
    M_TAIL  DB 0DH, 0AH, 'Each block was one call with a count of ten.', 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA DX, M_HEAD
    MOV AH, 09H
    INT 21H

    ; -------------------------------------------------------------------------
    ; SERVICE 09H WRITES THE CHARACTER IN AL, CX TIMES, WITH THE COLOUR IN BL.
    ; IT DOES NOT MOVE THE CURSOR, WHICH IS WHY IT CAN FILL A RUN IN ONE CALL
    ; AND WHY A PROGRAM USING IT HAS TO POSITION THE CURSOR ITSELF.
    ;
    ; THE ATTRIBUTE BYTE IS TWO NIBBLES: THE BACKGROUND ABOVE AND THE
    ; FOREGROUND BELOW, SO 1EH IS YELLOW ON BLUE.
    ; -------------------------------------------------------------------------
    MOV BL, 1EH                         ; Yellow on blue
    CALL DRAW_BLOCK

    MOV BL, 2FH                         ; White on green
    CALL DRAW_BLOCK

    MOV BL, 4EH                         ; Yellow on red
    CALL DRAW_BLOCK

    LEA DX, M_TAIL
    MOV AH, 09H
    INT 21H

    MOV AX, 4C00H
    INT 21H

; -----------------------------------------------------------------------------
; DRAW_BLOCK
;
; Writes ten blocks in the colour held in BL, then moves the cursor past them.
; -----------------------------------------------------------------------------
DRAW_BLOCK PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX

    MOV AH, 09H
    MOV AL, 0DBH                        ; The solid block character
    MOV BH, 0
    MOV CX, 10
    INT 10H

    ; Service 09h leaves the cursor where it was, so move it on by hand
    MOV AH, 03H
    MOV BH, 0
    INT 10H
    ADD DL, 10

    MOV AH, 02H
    MOV BH, 0
    INT 10H

    POP DX
    POP CX
    POP BX
    POP AX
    RET
DRAW_BLOCK ENDP

END START

; =============================================================================
; TECHNICAL NOTES
; =============================================================================
; 1. THE ATTRIBUTE IS TWO NIBBLES:
;    - Background in the high four bits, foreground in the low four. 1Eh
;    - is background one, blue, and foreground fourteen, yellow.
; 2. IT DOES NOT ADVANCE:
;    - Which is what makes a count useful and what makes the caller
;    - responsible for moving on. Service 0Eh advances and cannot repeat;
;    - these two together cover both needs.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
