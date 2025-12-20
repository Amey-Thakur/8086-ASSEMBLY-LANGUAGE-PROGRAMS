;=============================================================================
; Program:     GCD of Two Numbers
; Description: Find Greatest Common Divisor using Euclidean algorithm.
;              GCD is the largest number that divides both numbers.
; 
; Author:      Amey Thakur
; Repository:  https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
; License:     MIT License
;=============================================================================

;-----------------------------------------------------------------------------
; DATA SEGMENT
;-----------------------------------------------------------------------------
DATA SEGMENT
    NUM1 DW 0017H                       ; First number (23)
    NUM2 DW 0007H                       ; Second number (7)
    GCD DW ?                            ; Result: GCD(23, 7) = 1
DATA ENDS

ASSUME CS:CODE, DS:DATA

;-----------------------------------------------------------------------------
; CODE SEGMENT
; Euclidean Algorithm: GCD(a, b) = GCD(b, a mod b)
;-----------------------------------------------------------------------------
CODE SEGMENT

START: 
       ; Initialize Data Segment
       MOV AX, DATA
       MOV DS, AX
       
       ; Load numbers
       MOV AX, NUM1                     ; AX = 23
       MOV BX, NUM2                     ; BX = 7

       ;---------------------------------------------------------------------
       ; Euclidean Algorithm Loop
       ;---------------------------------------------------------------------
X1:    
       CMP AX, BX                       ; Compare numbers
       JE X4                            ; If equal, GCD found
       JB X3                            ; If AX < BX, swap

       ;---------------------------------------------------------------------
       ; Divide larger by smaller
       ;---------------------------------------------------------------------
X2:    
       MOV DX, 0000H                    ; Clear high word for division
       DIV BX                           ; AX = quotient, DX = remainder
       CMP DX, 0000H                    ; Check if remainder = 0
       JE X4                            ; If remainder = 0, GCD = BX
       MOV AX, DX                       ; AX = remainder
       JMP X1                           ; Repeat

       ;---------------------------------------------------------------------
       ; Swap if needed (AX < BX)
       ;---------------------------------------------------------------------
X3:    
       XCHG AX, BX                      ; Swap AX and BX
       JMP X2

       ;---------------------------------------------------------------------
       ; Store Result
       ;---------------------------------------------------------------------
X4:    
       MOV GCD, BX                      ; Store GCD
       
       ;---------------------------------------------------------------------
       ; Program Termination
       ;---------------------------------------------------------------------
       MOV AH, 4CH
       INT 21H

CODE ENDS
END START

;=============================================================================
; GCD (GREATEST COMMON DIVISOR) NOTES:
; - Also known as HCF (Highest Common Factor)
; - Euclidean Algorithm: Repeatedly divide larger by smaller
; - GCD(a, b) = GCD(b, a mod b)
; - When remainder = 0, divisor is GCD
; - Example: GCD(48, 18) = 6
;   48 mod 18 = 12, GCD(18, 12)
;   18 mod 12 = 6,  GCD(12, 6)
;   12 mod 6 = 0,   GCD = 6
;=============================================================================
