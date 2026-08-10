; =============================================================================
; TITLE: Writing to the Screen Through a Handle
; DESCRIPTION: Uses the file writing service on the console, which is how a
;              program writes text of a known length rather than a terminated string.
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
    STDOUT  EQU 1                       ; Always open, always the screen
    STDERR  EQU 2                       ; The screen too, but never redirected

    NORMAL  DB 'This went to handle 1, the standard output.', 0DH, 0AH
    NORMLEN EQU $ - NORMAL

    PROBLEM DB 'This went to handle 2, where errors belong.', 0DH, 0AH
    PROBLEN EQU $ - PROBLEM

    ; A string with a dollar sign in the middle, which 09h could not print
    AWKWARD DB 'A price of $5 cannot be printed with service 09h.', 0DH, 0AH
    AWKLEN  EQU $ - AWKWARD

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    ; -------------------------------------------------------------------------
    ; HANDLES 0 TO 4 ARE OPEN BEFORE THE PROGRAM STARTS: INPUT, OUTPUT, ERROR,
    ; THE SERIAL PORT AND THE PRINTER. NOTHING HAS TO BE OPENED TO WRITE TO
    ; THE SCREEN.
    ; -------------------------------------------------------------------------
    MOV AH, 40H
    MOV BX, STDOUT
    MOV CX, NORMLEN
    LEA DX, NORMAL
    INT 21H

    MOV AH, 40H
    MOV BX, STDERR
    MOV CX, PROBLEN
    LEA DX, PROBLEM
    INT 21H

    ; -------------------------------------------------------------------------
    ; THE REAL ADVANTAGE: A LENGTH IS PASSED RATHER THAN A TERMINATOR, SO THE
    ; TEXT MAY CONTAIN ANY BYTE AT ALL. SERVICE 09H WOULD STOP AT THE DOLLAR
    ; SIGN IN THE MIDDLE OF THIS LINE.
    ; -------------------------------------------------------------------------
    MOV AH, 40H
    MOV BX, STDOUT
    MOV CX, AWKLEN
    LEA DX, AWKWARD
    INT 21H

    MOV AH, 4CH
    INT 21H

END START

; =============================================================================
; TECHNICAL NOTES
; =============================================================================
; 1. WHY ERRORS GO TO HANDLE 2:
;    - Handle 1 can be redirected to a file at the command line and
;    - handle 2 cannot, so a message sent to 2 still reaches the person
;    - running the program.
; 2. LENGTH BEATS TERMINATOR:
;    - Any byte can appear in the text, including a dollar sign or a
;    - nought. That is why every modern write call takes a length.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
