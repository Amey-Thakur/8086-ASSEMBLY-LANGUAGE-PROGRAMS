;=============================================================================
; Program:     Division of 16-bit by 8-bit Number
; Description: Divides a 16-bit number by an 8-bit number, stores quotient
;              and remainder. Demonstrates DIV instruction.
; 
; Author:      Amey Thakur
; Repository:  https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
; License:     MIT License
;=============================================================================

;-----------------------------------------------------------------------------
; DATA SEGMENT
;-----------------------------------------------------------------------------
DATA SEGMENT
    var1 DW 6827H                       ; Dividend (16-bit): 26,663 decimal
    var2 DB 0FEH                        ; Divisor (8-bit): 254 decimal
    quo DB ?                            ; Quotient storage
    rem DB ?                            ; Remainder storage
DATA ENDS          

ASSUME CS:CODE, DS:DATA

;-----------------------------------------------------------------------------
; CODE SEGMENT
; DIV instruction for 8-bit divisor:
;   - Dividend in AX (16-bit)
;   - Quotient stored in AL
;   - Remainder stored in AH
;-----------------------------------------------------------------------------
CODE SEGMENT
    START: 
           ; Initialize Data Segment
           MOV AX, DATA
           MOV DS, AX
           
           ;-----------------------------------------------------------------
           ; Load Dividend and Divisor
           ;-----------------------------------------------------------------
           MOV AX, var1                 ; Load 16-bit dividend into AX
           MOV BL, var2                 ; Load 8-bit divisor into BL
           
           ;-----------------------------------------------------------------
           ; Perform Unsigned Division
           ; DIV BL: AL = AX / BL (quotient)
           ;         AH = AX % BL (remainder)
           ; Example: 6827H / 0FEH = 69H quotient, 0D5H remainder
           ;-----------------------------------------------------------------
           DIV BL                       ; Divide AX by BL
           
           ;-----------------------------------------------------------------
           ; Store Results
           ;-----------------------------------------------------------------
           MOV quo, AL                  ; Store quotient (105 decimal)
           MOV rem, AH                  ; Store remainder (213 decimal)
           
           ;-----------------------------------------------------------------
           ; Program Termination
           ;-----------------------------------------------------------------
           MOV AH, 4CH
           INT 21H
           
CODE ENDS
END START

;=============================================================================
; NOTES:
; - DIV performs unsigned division
; - For 8-bit divisor: AX / operand -> AL=quotient, AH=remainder
; - For 16-bit divisor: DX:AX / operand -> AX=quotient, DX=remainder
; - Division by zero causes interrupt (type 0)
; - Use IDIV for signed division
;=============================================================================
