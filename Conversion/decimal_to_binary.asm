;=============================================================================
; Program:     Decimal to Binary Conversion
; Description: Convert a decimal number to its binary representation
;              and display the result.
; 
; Author:      Amey Thakur
; Repository:  https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
; License:     MIT License
;=============================================================================

;-----------------------------------------------------------------------------
; MACRO: Display String
;-----------------------------------------------------------------------------
DIS MACRO STR
    MOV AH, 09H
    LEA DX, STR
    INT 21H
ENDM

;-----------------------------------------------------------------------------
; DATA SEGMENT
;-----------------------------------------------------------------------------
DATA SEGMENT
    MSG2 DB "BINARY NUMBER IS : $"
    STR1 DB 20 DUP('$')                ; Temporary storage (reversed)
    STR2 DB 20 DUP('$')                ; Final binary string
    NO DW 100                           ; Number to convert (100 decimal)
    LINE DB 10, 13, '$'                 ; Newline characters
DATA ENDS

;-----------------------------------------------------------------------------
; CODE SEGMENT
; Algorithm: Repeatedly divide by 2, store remainders (binary digits)
;-----------------------------------------------------------------------------
CODE SEGMENT
    ASSUME DS:DATA, CS:CODE
    
START:
    ; Initialize Data Segment
    MOV AX, DATA
    MOV DS, AX
    LEA SI, STR1                        ; Point to temp string
    MOV AX, NO                          ; Load number (100)
    MOV BH, 00                          ; Digit counter
    MOV BL, 2                           ; Divisor (for binary)
    
    ;-------------------------------------------------------------------------
    ; Division Loop: Extract binary digits (LSB first)
    ; 100 / 2 = 50 R0, 50 / 2 = 25 R0, 25 / 2 = 12 R1, ...
    ;-------------------------------------------------------------------------
L1: 
    DIV BL                              ; AL = quotient, AH = remainder
    ADD AH, '0'                         ; Convert remainder to ASCII
    MOV BYTE PTR[SI], AH                ; Store digit
    MOV AH, 00                          ; Clear remainder for next division
    INC SI                              ; Next position
    INC BH                              ; Count digits
    CMP AL, 00                          ; Check if quotient is 0
    JNE L1                              ; Continue if not zero

    ;-------------------------------------------------------------------------
    ; Reverse the String (LSB stored first, need MSB first)
    ;-------------------------------------------------------------------------
    MOV CL, BH                          ; Number of digits
    LEA SI, STR1                        ; Source (reversed)
    LEA DI, STR2                        ; Destination (correct order)
    MOV CH, 00
    ADD SI, CX                          ; Point to end of source
    DEC SI

L2: 
    MOV AH, BYTE PTR[SI]                ; Get digit from end
    MOV BYTE PTR[DI], AH                ; Store at beginning
    DEC SI                              ; Move source backward
    INC DI                              ; Move dest forward
    LOOP L2

    ;-------------------------------------------------------------------------
    ; Display Result
    ; 100 decimal = 1100100 binary
    ;-------------------------------------------------------------------------
    DIS LINE                            ; Newline
    DIS MSG2                            ; "BINARY NUMBER IS : "
    DIS STR2                            ; Binary number
    
    ;-------------------------------------------------------------------------
    ; Program Termination
    ;-------------------------------------------------------------------------
    MOV AH, 4CH
    INT 21H 
CODE ENDS
END START

;=============================================================================
; DECIMAL TO BINARY CONVERSION NOTES:
; - Algorithm: Repeated division by 2
; - Remainder after each division is a binary digit
; - Digits obtained in reverse order (LSB first)
; - Example: 100 = 1100100 (binary)
;=============================================================================
