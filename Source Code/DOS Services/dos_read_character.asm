; =============================================================================
; TITLE: Reading One Character: 01h, 07h and 08h
; DESCRIPTION: Three services that all read a key and differ in whether they
;              echo it and whether they notice a break.
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
    M_01    DB 'Service 01h reads and echoes. You typed: $'
    M_08    DB 0DH, 0AH, 'Service 08h reads without echoing. You typed: $'
    M_07    DB 0DH, 0AH, 'Service 07h is the same but ignores Ctrl-C: $'
    CRLF    DB 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    ; -------------------------------------------------------------------------
    ; ALL THREE RETURN THE CHARACTER IN AL. THE DIFFERENCE IS WHAT ELSE THEY
    ; DO: 01H PUTS IT ON THE SCREEN AS IT IS TYPED, 08H DOES NOT, AND 07H
    ; ALSO DECLINES TO TREAT CTRL-C AS AN INTERRUPT, WHICH IS WHAT A PASSWORD
    ; PROMPT WANTS.
    ; -------------------------------------------------------------------------
    LEA DX, M_01
    MOV AH, 09H
    INT 21H

    MOV AH, 01H
    INT 21H
    MOV BL, AL                          ; Keep it; AH is about to be reused

    LEA DX, M_08
    MOV AH, 09H
    INT 21H

    MOV AH, 08H
    INT 21H
    MOV DL, AL                          ; Show it ourselves, since 08h did not
    MOV AH, 02H
    INT 21H

    LEA DX, M_07
    MOV AH, 09H
    INT 21H

    MOV AH, 07H
    INT 21H
    MOV DL, AL
    MOV AH, 02H
    INT 21H

    LEA DX, CRLF
    MOV AH, 09H
    INT 21H

    MOV AH, 4CH
    INT 21H

END START

; =============================================================================
; TECHNICAL NOTES
; =============================================================================
; 1. THE CHARACTER ARRIVES IN AL:
;    - And AL is the low half of AX, so the next MOV AH of a service
;    - number leaves it alone. Reading into AL and then overwriting AX
;    - entirely is the mistake to avoid.
; 2. WHY THREE SERVICES:
;    - Echoing is wanted for ordinary input and not for a password. Break
;    - handling is wanted for a command prompt and not for a routine that
;    - must clean up before it exits.
; 3. IN THE SIMULATOR:
;    - Keystrokes are queued in the input field before the program runs,
;    - because there is no way to suspend a browser while someone
;    - decides what to press. An empty queue returns a carriage return.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
