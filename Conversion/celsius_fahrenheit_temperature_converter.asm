;=============================================================================
; Program:     Temperature Conversion
; Description: Convert Celsius to Fahrenheit and vice versa.
;              Demonstrates arithmetic operations with formulas.
; 
; Author:      Amey Thakur
; Repository:  https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
; License:     MIT License
;=============================================================================

.MODEL SMALL
.STACK 100H

;-----------------------------------------------------------------------------
; DATA SEGMENT
; Formulas:
;   F = (C * 9/5) + 32
;   C = (F - 32) * 5/9
;-----------------------------------------------------------------------------
.DATA
    CELSIUS DW 25                       ; Input temperature in Celsius
    FAHRENHEIT DW ?                     ; Calculated Fahrenheit
    MSG1 DB 'Celsius to Fahrenheit: $'
    MSG2 DB 0DH, 0AH, 'Fahrenheit to Celsius: $'
    NEWLINE DB 0DH, 0AH, '$'

;-----------------------------------------------------------------------------
; CODE SEGMENT
;-----------------------------------------------------------------------------
.CODE
MAIN PROC
    ; Initialize Data Segment
    MOV AX, @DATA
    MOV DS, AX
    
    ;=========================================================================
    ; CELSIUS TO FAHRENHEIT CONVERSION
    ; Formula: F = (C * 9 / 5) + 32
    ;=========================================================================
    LEA DX, MSG1
    MOV AH, 09H
    INT 21H
    
    ; Calculate: F = (C * 9 / 5) + 32
    MOV AX, CELSIUS                     ; AX = 25 (Celsius)
    MOV BX, 9
    MUL BX                              ; AX = 25 * 9 = 225
    MOV BX, 5
    XOR DX, DX                          ; Clear DX for division
    DIV BX                              ; AX = 225 / 5 = 45
    ADD AX, 32                          ; AX = 45 + 32 = 77 (Fahrenheit)
    MOV FAHRENHEIT, AX                  ; Store result
    
    ; Display result (77F)
    CALL PRINT_NUM
    MOV DL, 'F'
    MOV AH, 02H
    INT 21H
    
    ;=========================================================================
    ; FAHRENHEIT TO CELSIUS CONVERSION
    ; Formula: C = (F - 32) * 5 / 9
    ;=========================================================================
    LEA DX, MSG2
    MOV AH, 09H
    INT 21H
    
    ; Calculate: C = (F - 32) * 5 / 9
    MOV AX, FAHRENHEIT                  ; AX = 77 (Fahrenheit)
    SUB AX, 32                          ; AX = 77 - 32 = 45
    MOV BX, 5
    MUL BX                              ; AX = 45 * 5 = 225
    MOV BX, 9
    XOR DX, DX                          ; Clear DX for division
    DIV BX                              ; AX = 225 / 9 = 25 (Celsius)
    
    ; Display result (25C)
    CALL PRINT_NUM
    MOV DL, 'C'
    MOV AH, 02H
    INT 21H
    
    ;-------------------------------------------------------------------------
    ; Program Termination
    ;-------------------------------------------------------------------------
    MOV AH, 4CH
    INT 21H
MAIN ENDP

;-----------------------------------------------------------------------------
; PRINT_NUM: Print AX as decimal number
;-----------------------------------------------------------------------------
PRINT_NUM PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    
    XOR CX, CX                          ; Digit counter
    MOV BX, 10                          ; Divisor
    
DIV_LOOP:
    XOR DX, DX                          ; Clear for division
    DIV BX                              ; AX = quotient, DX = remainder
    PUSH DX                             ; Save digit
    INC CX                              ; Count digit
    CMP AX, 0                           ; More digits?
    JNE DIV_LOOP
    
PRINT_LOOP:
    POP DX                              ; Get digit
    ADD DL, '0'                         ; Convert to ASCII
    MOV AH, 02H                         ; DOS: Print character
    INT 21H
    LOOP PRINT_LOOP
    
    POP DX
    POP CX
    POP BX
    POP AX
    RET
PRINT_NUM ENDP

END MAIN

;=============================================================================
; TEMPERATURE CONVERSION NOTES:
; - Celsius to Fahrenheit: F = C × 9/5 + 32
; - Fahrenheit to Celsius: C = (F − 32) × 5/9
; - Watch for integer division truncation
; - Water freezes: 0°C = 32°F, Water boils: 100°C = 212°F
;=============================================================================
