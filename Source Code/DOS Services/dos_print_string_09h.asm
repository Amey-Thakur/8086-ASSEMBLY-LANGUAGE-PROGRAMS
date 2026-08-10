; =============================================================================
; TITLE: Printing a String with Service 09h
; DESCRIPTION: The service almost every DOS program uses, and the two things
;              about it that catch people out.
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
    ; The dollar sign is the terminator and is not printed. It has to be
    ; inside the declaration; a string without one prints until the service
    ; happens to find a 24h somewhere in memory.
    GREETING DB 'Amey Thakur', 0DH, 0AH, '$'
    NOTE     DB 'The dollar sign ends the string and is not shown.', 0DH, 0AH, '$'

    ; A string may contain anything else at all, including control codes.
    TABBED   DB 'one', 09H, 'two', 09H, 'three', 0DH, 0AH, '$'
    BELL     DB 'This line ends with a bell.', 07H, 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    ; -------------------------------------------------------------------------
    ; THE ADDRESS GOES IN DS:DX, AND DS HAS TO BE RIGHT BEFORE THE OFFSET IN
    ; DX MEANS ANYTHING. THAT IS WHY EVERY PROGRAM OPENS BY SETTING IT.
    ; -------------------------------------------------------------------------
    LEA DX, GREETING
    MOV AH, 09H
    INT 21H

    LEA DX, NOTE
    MOV AH, 09H
    INT 21H

    LEA DX, TABBED
    MOV AH, 09H
    INT 21H

    LEA DX, BELL
    MOV AH, 09H
    INT 21H

    MOV AH, 4CH
    INT 21H

END START

; =============================================================================
; TECHNICAL NOTES
; =============================================================================
; 1. CARRIAGE RETURN AND LINE FEED:
;    - DOS needs both: 0Dh returns the cursor to the left margin and 0Ah
;    - moves it down a line. One without the other either overwrites the
;    - line or leaves a staircase.
; 2. NO LENGTH IS PASSED:
;    - The service reads until it meets the terminator, so a string with
;    - no dollar sign has no defined end. It is the same weakness that C
;    - strings have, for the same reason.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
