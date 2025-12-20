;=============================================================================
; Program:     BCD to Hexadecimal Conversion
; Description: Convert a 16-bit BCD (Binary Coded Decimal) number to its
;              equivalent hexadecimal value.
; 
; Author:      Amey Thakur
; Repository:  https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
; License:     MIT License
;=============================================================================

;-----------------------------------------------------------------------------
; DATA SEGMENT
; BCD digits stored in array: 65535 = {6, 5, 5, 3, 5}
;-----------------------------------------------------------------------------
DATA SEGMENT
    BCD DB 06H, 05H, 05H, 03H, 05H     ; BCD digits (65535)
    HEX DW ?                            ; Hexadecimal result
DATA ENDS

ASSUME CS:CODE, DS:DATA

;-----------------------------------------------------------------------------
; CODE SEGMENT
; Algorithm: Multiply each digit by its place value and accumulate
; 65535 = 6*10000 + 5*1000 + 5*100 + 3*10 + 5*1
;-----------------------------------------------------------------------------
CODE SEGMENT
START: 
       ; Initialize Data Segment
       MOV AX, DATA
       MOV DS, AX
       
       ;---------------------------------------------------------------------
       ; Initialize Registers
       ;---------------------------------------------------------------------
       MOV CL, 05H                      ; 5 BCD digits to process
       MOV BP, 000AH                    ; Divisor for place value (10)
       MOV AX, 2710H                    ; Initial place value (10000)
       PUSH AX                          ; Save place value
       MOV DI, 0000H                    ; Accumulator for result
       MOV SI, OFFSET BCD               ; Point to BCD array
       
       ;---------------------------------------------------------------------
       ; Conversion Loop
       ; Multiply each BCD digit by place value and add to result
       ;---------------------------------------------------------------------
X:     
       MOV BL, [SI]                     ; Get BCD digit
       MUL BX                           ; AX = digit * place value
       ADD DI, AX                       ; Add to result
       POP AX                           ; Restore place value
       DIV BP                           ; AX = place value / 10
       PUSH AX                          ; Save new place value
       INC SI                           ; Next BCD digit
       LOOP X                           ; Repeat for all digits
       
       ;---------------------------------------------------------------------
       ; Store Result
       ; 65535 decimal = FFFFH
       ;---------------------------------------------------------------------
       MOV HEX, DI                      ; Store hex result
       
       ;---------------------------------------------------------------------
       ; Program Termination
       ;---------------------------------------------------------------------
       MOV AH, 4CH
       INT 21H
CODE ENDS
END START

;=============================================================================
; BCD TO HEX CONVERSION NOTES:
; - BCD stores each decimal digit in a separate nibble or byte
; - Conversion: Sum of (digit * 10^position)
; - Example: 65535 (BCD) = 6*10000 + 5*1000 + 5*100 + 3*10 + 5 = FFFFH
;=============================================================================
