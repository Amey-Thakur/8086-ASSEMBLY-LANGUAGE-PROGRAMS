;=============================================================================
; Program:     Decimal to Octal Conversion
; Description: Convert a decimal number entered by user to its octal
;              (base-8) representation and display the result.
; 
; Author:      Amey Thakur
; Repository:  https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
; License:     MIT License
;=============================================================================

;-----------------------------------------------------------------------------
; MACRO: Print String
;-----------------------------------------------------------------------------
PRNSTR MACRO MSG
    MOV AH, 09H
    LEA DX, MSG
    INT 21H
ENDM

;-----------------------------------------------------------------------------
; DATA SEGMENT
;-----------------------------------------------------------------------------
DATA SEGMENT
    BUF1 DB "Enter a decimal number : $"
    BUF2 DB 0AH, "Invalid Decimal Number...$"
    BUF3 DB 0AH, "Equivalent octal number is : $"
    BUF4 DB 6                            ; Max input length
         DB 0                            ; Actual length (filled by DOS)
         DB 6 DUP(0)                     ; Input buffer
    MULTIPLIER DB 0AH                    ; 10 for decimal conversion
DATA ENDS

;-----------------------------------------------------------------------------
; CODE SEGMENT
;-----------------------------------------------------------------------------
CODE SEGMENT
    ASSUME CS:CODE, DS:DATA
    
START:
    ; Initialize Data Segment
    MOV AX, DATA
    MOV DS, AX
    MOV ES, AX

    ;-------------------------------------------------------------------------
    ; Prompt and Read Decimal Number
    ;-------------------------------------------------------------------------
    PRNSTR BUF1                          ; Display prompt

    MOV AH, 0AH                          ; DOS: Buffered input
    LEA DX, BUF4
    INT 21H

    ;-------------------------------------------------------------------------
    ; Validate and Convert ASCII to Numeric
    ;-------------------------------------------------------------------------
    MOV SI, OFFSET BUF4 + 2              ; Point to actual input
    MOV CL, BYTE PTR [SI-1]              ; Get input length
    MOV CH, 00H
    
SUBTRACT:
    MOV AL, BYTE PTR [SI]                ; Get character
    CMP AL, 30H                          ; Check >= '0'
    JNB CONT1
    PRNSTR BUF2                          ; Invalid digit
    JMP STOP
    
CONT1:
    CMP AL, 3AH                          ; Check < ':'(after '9')
    JB CONT2
    PRNSTR BUF2                          ; Invalid digit
    JMP STOP
    
CONT2:
    SUB AL, 30H                          ; Convert ASCII to numeric
    MOV BYTE PTR [SI], AL                ; Store numeric value
    INC SI
    LOOP SUBTRACT

    ;-------------------------------------------------------------------------
    ; Calculate Decimal Value
    ;-------------------------------------------------------------------------
    MOV SI, OFFSET BUF4 + 2
    MOV CL, BYTE PTR [SI-1]
    MOV CH, 00H
    MOV AX, 0000H                        ; Accumulator
    
CALC:
    MUL MULTIPLIER                       ; AX = AX * 10
    MOV BL, BYTE PTR [SI]
    MOV BH, 00H
    ADD AX, BX                           ; Add current digit
    INC SI
    LOOP CALC

    ;-------------------------------------------------------------------------
    ; Convert to Octal (Divide by 8)
    ;-------------------------------------------------------------------------
    MOV SI, OFFSET BUF4 + 2
    MOV BX, AX                           ; BX = decimal number
    MOV DX, 0000H
    MOV AX, 8000H                        ; Start with high place value
    
CONVERT:
    MOV CX, 0000H
    
CONV:
    CMP BX, AX
    JB CONT3
    SUB BX, AX
    INC CX
    JMP CONV
    
CONT3:
    ADD CL, 30H                          ; Convert to ASCII
    MOV BYTE PTR [SI], CL                ; Store octal digit
    INC SI
    MOV CX, 0008H
    DIV CX                               ; Next place value / 8
    CMP AX, 0000H
    JNZ CONVERT

    ;-------------------------------------------------------------------------
    ; Display Result
    ;-------------------------------------------------------------------------
    MOV BYTE PTR [SI], '$'               ; Terminate string
    PRNSTR BUF3                          ; "Equivalent octal number is:"
    PRNSTR BUF4+2                        ; Octal result

STOP:
    ;-------------------------------------------------------------------------
    ; Program Termination
    ;-------------------------------------------------------------------------
    MOV AX, 4C00H
    INT 21H
CODE ENDS
END START

;=============================================================================
; DECIMAL TO OCTAL CONVERSION NOTES:
; - Octal uses digits 0-7 (base 8)
; - Algorithm: Repeatedly divide by 8, remainders are octal digits
; - Example: 100 decimal = 144 octal (1*64 + 4*8 + 4*1)
;=============================================================================
