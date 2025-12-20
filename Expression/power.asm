;=============================================================================
; Program:     Power Calculation (a^b)
; Description: Calculate base raised to power (exponentiation).
;              Uses repeated multiplication.
; 
; Author:      Amey Thakur
; Repository:  https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
; License:     MIT License
;=============================================================================

.MODEL SMALL
.STACK 100H

;-----------------------------------------------------------------------------
; DATA SEGMENT
;-----------------------------------------------------------------------------
.DATA
    BASE DB ?                           ; Base number
    POW DB ?                            ; Exponent
    NL1 DB 0AH, 0DH, 'ENTER BASE: $'
    NL2 DB 0AH, 0DH, 'ENTER POWER: $'
    NL3 DB 0AH, 0DH, 'RESULT: $'

;-----------------------------------------------------------------------------
; CODE SEGMENT
; Algorithm: result = base * base * base... (power times)
;-----------------------------------------------------------------------------
.CODE
MAIN PROC
    ; Initialize Data Segment
    MOV AX, @DATA
    MOV DS, AX

    ;-------------------------------------------------------------------------
    ; Get Base from User
    ;-------------------------------------------------------------------------
ENTER_BASE:
    LEA DX, NL1
    MOV AH, 09H
    INT 21H

    MOV AH, 01H                         ; Read character
    INT 21H
    SUB AL, 30H                         ; Convert ASCII to number
    MOV BL, AL                          ; BL = base
    MOV BASE, AL

    ;-------------------------------------------------------------------------
    ; Get Power from User
    ;-------------------------------------------------------------------------
ENTER_POWER:
    LEA DX, NL2
    MOV AH, 09H
    INT 21H

    MOV AH, 01H                         ; Read character
    INT 21H
    SUB AL, 30H                         ; Convert ASCII to number

    ;-------------------------------------------------------------------------
    ; Calculate Power: base^power
    ;-------------------------------------------------------------------------
    MOV CL, AL                          ; CL = power (loop counter)
    DEC CL                              ; Already have base once
    MOV AX, 00
    MOV AL, BASE                        ; AX = result = base

LBL1:
    MUL BL                              ; AX = AX * base
    LOOP LBL1                           ; Repeat (power-1) times

    ;-------------------------------------------------------------------------
    ; Display Result
    ;-------------------------------------------------------------------------
    LEA DX, NL3
    MOV AH, 09H
    INT 21H
    
    ; Convert result to two-digit ASCII
    MOV CL, 10
    DIV CL                              ; AL = tens, AH = units
    ADD AX, 3030H                       ; Convert both to ASCII
    MOV DX, AX

    ; Display tens digit
    MOV AH, 02H
    INT 21H
    ; Display units digit
    MOV DL, DH
    INT 21H

    ;-------------------------------------------------------------------------
    ; Program Termination
    ;-------------------------------------------------------------------------
    MOV AH, 4CH
    INT 21H
MAIN ENDP
END MAIN

;=============================================================================
; POWER CALCULATION NOTES:
; - a^b = a × a × a × ... (b times)
; - Example: 2^5 = 32, 3^4 = 81
; - Limitation: Result must fit in 16-bit (max 65535)
; - More efficient: Binary exponentiation (a^b = (a^2)^(b/2))
;=============================================================================
