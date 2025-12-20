;=============================================================================
; Program:     Hexadecimal to BCD Conversion
; Description: Convert a 16-bit hexadecimal number to its equivalent
;              BCD (Binary Coded Decimal) representation.
; 
; Author:      Amey Thakur
; Repository:  https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
; License:     MIT License
;=============================================================================

;-----------------------------------------------------------------------------
; DATA SEGMENT
;-----------------------------------------------------------------------------
DATA SEGMENT
    HEX DW 0FFFFH                       ; Hex input (65535 decimal)
    BCD DW 5 DUP(0)                     ; BCD output array (5 digits)
DATA ENDS   

ASSUME CS:CODE, DS:DATA  

;-----------------------------------------------------------------------------
; CODE SEGMENT
; Algorithm: Repeatedly divide by 10000, 1000, 100, 10, 1
;-----------------------------------------------------------------------------
CODE SEGMENT
     
START: 
       ; Initialize Data Segment
       MOV AX, DATA
       MOV DS, AX
       
       ;---------------------------------------------------------------------
       ; Initialize Pointers
       ;---------------------------------------------------------------------
       LEA SI, BCD                      ; Point to BCD array
       MOV AX, HEX                      ; Load hex number (FFFFH = 65535)
       
       ;---------------------------------------------------------------------
       ; Extract Ten-thousands digit (6 from 65535)
       ;---------------------------------------------------------------------
       MOV CX, 2710H                    ; Divisor = 10000
       CALL SUB1
       
       ;---------------------------------------------------------------------
       ; Extract Thousands digit (5 from 65535)
       ;---------------------------------------------------------------------
       MOV CX, 03E8H                    ; Divisor = 1000
       CALL SUB1
       
       ;---------------------------------------------------------------------
       ; Extract Hundreds digit (5 from 65535)
       ;---------------------------------------------------------------------
       MOV CX, 0064H                    ; Divisor = 100
       CALL SUB1
       
       ;---------------------------------------------------------------------
       ; Extract Tens digit (3 from 65535)
       ;---------------------------------------------------------------------
       MOV CX, 000AH                    ; Divisor = 10
       CALL SUB1
       
       ;---------------------------------------------------------------------
       ; Store Units digit (5 from 65535)
       ;---------------------------------------------------------------------
       MOV [SI], AL                     ; Remainder is units digit
       
       ;---------------------------------------------------------------------
       ; Program Termination
       ;---------------------------------------------------------------------
       MOV AH, 4CH
       INT 21H

;-----------------------------------------------------------------------------
; SUB1: Extract one BCD digit by repeated subtraction
; Input: AX = number, CX = divisor
; Output: BCD digit stored at [SI], SI incremented
;-----------------------------------------------------------------------------
SUB1 PROC NEAR
       MOV BH, 0FFH                     ; Initialize counter to -1
X1:    
       INC BH                           ; Increment counter
       SUB AX, CX                       ; Subtract divisor
       JNC X1                           ; Repeat while no borrow
       ADD AX, CX                       ; Restore (subtract went too far)
       MOV [SI], BH                     ; Store BCD digit
       INC SI                           ; Point to next BCD position
       RET
SUB1 ENDP

CODE ENDS
END START

;=============================================================================
; HEX TO BCD CONVERSION NOTES:
; - Repeated subtraction method used (alternative to division)
; - More efficient for small divisors
; - Result: FFFFH (65535) -> BCD array {6, 5, 5, 3, 5}
;=============================================================================
