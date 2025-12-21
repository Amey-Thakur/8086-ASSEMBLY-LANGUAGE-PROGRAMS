; =============================================================================
; TITLE: Parity Check (Even/Odd) using Division
; DESCRIPTION: Determines if a user-supplied number is Even or Odd by 
;              checking the remainder of division by 2.
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
    MSG_PROMPT DB 0DH, 0AH, 'Enter a single digit number: $'
    MSG_EVEN   DB 0DH, 0AH, 'Result: EVEN$'
    MSG_ODD    DB 0DH, 0AH, 'Result: ODD$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
MAIN PROC
    ; --- Step 1: Initialize Data Segment ---
    MOV AX, @DATA
    MOV DS, AX
    
    ; --- Step 2: Input ---
    LEA DX, MSG_PROMPT
    MOV AH, 09H
    INT 21H
    
    MOV AH, 01H
    INT 21H
    SUB AL, '0'                         ; Convert ASCII to Integer
    
    ; --- Step 3: Check Parity (Division Method) ---
    MOV AH, 0                           ; Clear heavy byte
    MOV BL, 2
    DIV BL                              ; AX / 2 -> AL=Quotient, AH=Remainder
    
    CMP AH, 0                           ; Remainder == 0?
    JE L_IS_EVEN
    
L_IS_ODD:
    LEA DX, MSG_ODD
    JMP L_DISPLAY
    
L_IS_EVEN:
    LEA DX, MSG_EVEN
    
L_DISPLAY:
    MOV AH, 09H
    INT 21H
    
    ; --- Step 4: Exit ---
    MOV AH, 4CH
    INT 21H
MAIN ENDP

END MAIN

; =============================================================================
; TECHNICAL NOTES & ARCHITECTURAL INSIGHTS
; =============================================================================
; 1. PARITY LOGIC:
;    - Even numbers are divisible by 2 with no remainder.
;    - Odd numbers leave a remainder of 1.
;
; 2. ALTERNATIVE METHOD (BITWISE):
;    A faster way is `TEST AL, 1`. If Zero Flag (ZF) is 0, the LSB is 1 (Odd).
;    If ZF is 1, the LSB is 0 (Even). This avoids the costly DIV instruction.
;    However, this program demonstrates the Division principle.
;
; 3. ASCII ADJUSTMENT:
;    We subtract '0' (30H) to convert the character input to a raw number 
;    before performing arithmetic.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
