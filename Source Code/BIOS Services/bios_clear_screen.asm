; =============================================================================
; TITLE: Clearing the Screen with a Scroll
; DESCRIPTION: Clears the display by asking the BIOS to scroll a window by
;              more lines than it has, which is the standard idiom.
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
    BEFORE  DB 'This line is about to be cleared away.'
    BEFORELEN EQU $ - BEFORE
    AFTER   DB 'The screen was cleared and the cursor went home.'
    AFTERLEN EQU $ - AFTER

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA SI, BEFORE
    MOV CX, BEFORELEN
    CALL BIOS_PRINT

    ; -------------------------------------------------------------------------
    ; SERVICE 06H SCROLLS A WINDOW UPWARD. A COUNT OF NOUGHT IN AL IS THE
    ; SPECIAL CASE THAT MEANS BLANK THE WHOLE WINDOW INSTEAD, WHICH IS WHY
    ; EVERY CLEAR SCREEN ROUTINE LOOKS LIKE A SCROLL.
    ;
    ;   AL  lines to scroll, or nought to blank the window
    ;   BH  the attribute to fill the vacated lines with
    ;   CH, CL  the row and column of the top left corner
    ;   DH, DL  the row and column of the bottom right
    ; -------------------------------------------------------------------------
    MOV AH, 06H
    MOV AL, 0                           ; Blank rather than scroll
    MOV BH, 07H                         ; Light grey on black
    MOV CH, 0                           ; From the very top left
    MOV CL, 0
    MOV DH, 24                          ; To the bottom right of an 80 by 25
    MOV DL, 79
    INT 10H

    ; Clearing does not move the cursor, so it is sent home explicitly
    MOV AH, 02H
    MOV BH, 0
    MOV DH, 0
    MOV DL, 0
    INT 10H

    LEA SI, AFTER
    MOV CX, AFTERLEN
    CALL BIOS_PRINT

    MOV AL, 0DH
    MOV AH, 0EH
    INT 10H
    MOV AL, 0AH
    MOV AH, 0EH
    INT 10H

    MOV AX, 4C00H
    INT 21H

; -----------------------------------------------------------------------------
; BIOS_PRINT
; -----------------------------------------------------------------------------
BIOS_PRINT PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH SI

BP_LOOP:
    JCXZ BP_DONE
    MOV AL, [SI]
    MOV AH, 0EH
    MOV BH, 0
    INT 10H
    INC SI
    LOOP BP_LOOP

BP_DONE:
    POP SI
    POP CX
    POP BX
    POP AX
    RET
BIOS_PRINT ENDP

END START

; =============================================================================
; TECHNICAL NOTES
; =============================================================================
; 1. CLEARING DOES NOT MOVE THE CURSOR:
;    - The screen goes blank and the cursor stays wherever it was, so the
;    - next character appears somewhere in the middle of an empty screen.
;    - Sending it home is a separate call and is always needed.
; 2. THE WINDOW CAN BE SMALLER:
;    - Giving corners other than the whole screen clears only that
;    - rectangle, which is how a program blanks one line or one panel
;    - without disturbing the rest.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
