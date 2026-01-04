; =============================================================================
; TITLE: Sign Flag (SF) Demonstration
; DESCRIPTION: Demonstrates how the Sign Flag (SF) reflects the Most Significant 
;              Bit (MSB) of the result, indicating negative numbers in signed 
;              arithmetic.
; AUTHOR: Amey Thakur (https://github.com/Amey-Thakur)
; REPOSITORY: https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
; LICENSE: MIT License
; =============================================================================

.MODEL SMALL
.STACK 100H

.DATA
    MSG_START   DB "Testing Sign Flag (SF)...", 0DH, 0AH, "$"
    MSG_NEG     DB "SF is SET (Negative).", 0DH, 0AH, "$"
    MSG_POS     DB "SF is CLEAR (Positive/Zero).", 0DH, 0AH, "$"

.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX
    
    LEA DX, MSG_START
    MOV AH, 09H
    INT 21H
    
    ; --- Case 1: Result becomes Negative ---
    MOV AL, 5
    SUB AL, 10                          ; 5 - 10 = -5 (FBh) -> MSB is 1 -> SF=1
    
    JS SF_IS_SET                        ; JS = Jump if Sign (SF=1)
    JMP SF_IS_CLEAR

SF_IS_SET:
    LEA DX, MSG_NEG
    MOV AH, 09H
    INT 21H
    JMP EXIT

SF_IS_CLEAR:
    LEA DX, MSG_POS
    MOV AH, 09H
    INT 21H

EXIT:
    MOV AH, 4CH
    INT 21H
MAIN ENDP
END MAIN

; =============================================================================
; TECHNICAL NOTES:
; 1. SIGN FLAG (Bit 7):
;    Simply a copy of the high bit (MSB) of the destination operand after 
;    an operation. 
;    - For 8-bit: Bit 7.
;    - For 16-bit: Bit 15.
;    It indicates the algebraic sign of the number if treated as signed.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
