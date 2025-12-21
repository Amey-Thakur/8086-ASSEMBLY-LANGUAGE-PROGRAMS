; =============================================================================
; TITLE: Display System Time
; DESCRIPTION: Fetch and display the current system time (HH:MM:SS.ms)
;              using DOS Interrupt 21H / AH=2CH.
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
    MSG1 DB 'Current system time is: $'
    HR   DB ?
    MIN  DB ?
    SEC  DB ?
    MSEC DB ?                       ; 1/100th of a second

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
MAIN PROC
    ; Initialize data segment
    MOV AX, @DATA
    MOV DS, AX

    ; -------------------------------------------------------------------------
    ; GET SYSTEM TIME (INT 21H, AH=2CH)
    ; Return: CH=Hours, CL=Minutes, DH=Seconds, DL=1/100 Seconds
    ; -------------------------------------------------------------------------
    MOV AH, 2CH
    INT 21H

    ; Storage
    MOV HR, CH
    MOV MIN, CL
    MOV SEC, DH
    MOV MSEC, DL

    ; Header display
    LEA DX, MSG1
    MOV AH, 09H
    INT 21H

    ; -------------------------------------------------------------------------
    ; DISPLAY SEQUENCE (HH:MM:SS.ms)
    ; -------------------------------------------------------------------------
    
    ; 1. Display Hours
    MOV AL, HR
    AAM                             ; ASCII Adjust for Multiply: Splits AL's digits into AH/AL
    MOV BX, AX                      ; Store for the procedure
    CALL DISPLAY_DIGITS
    
    MOV DL, ':'
    CALL PRINT_CHAR                 ; Print separator
    
    ; 2. Display Minutes
    MOV AL, MIN
    AAM
    MOV BX, AX
    CALL DISPLAY_DIGITS
    
    MOV DL, ':'
    CALL PRINT_CHAR
    
    ; 3. Display Seconds
    MOV AL, SEC
    AAM
    MOV BX, AX
    CALL DISPLAY_DIGITS
    
    MOV DL, '.'
    CALL PRINT_CHAR
    
    ; 4. Display Milli-seconds (1/100th)
    MOV AL, MSEC
    AAM
    MOV BX, AX
    CALL DISPLAY_DIGITS

    ; Termination
    MOV AH, 4CH
    INT 21H
MAIN ENDP

; -----------------------------------------------------------------------------
; PROCEDURE: DISPLAY_DIGITS
; Description: Displays two digits stored in BH (Tens) and BL (Units).
; -----------------------------------------------------------------------------
DISPLAY_DIGITS PROC NEAR
    ; Print Tens Digit
    MOV DL, BH
    ADD DL, 30H                     ; Convert to ASCII '0'-'9'
    MOV AH, 02H
    INT 21H
    
    ; Print Units Digit
    MOV DL, BL
    ADD DL, 30H
    MOV AH, 02H
    INT 21H
    RET
DISPLAY_DIGITS ENDP

; Simple character print helper
PRINT_CHAR PROC
    MOV AH, 02H
    INT 21H
    RET
PRINT_CHAR ENDP

END MAIN

; =============================================================================
; TECHNICAL NOTES
; =============================================================================
; 1. TIME DISPLAY:
;    - AAM (ASCII Adjust for Multiply) is used here to split a binary value
;      under 100 into two separate digits (Tens in AH, Units in AL).
;    - Example: If AL=13 (0Dh), AAM makes AH=01 and AL=03.
;    - This is a compact alternative to the 'DIV 10' logic for two digits.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
