; =============================================================================
; TITLE: Overflow Flag (OF) Demonstration
; DESCRIPTION: Demonstrates the conditions that set the Overflow Flag (OF), 
;              which indicates an error in Signed Arithmetic (result too large).
; AUTHOR: Amey Thakur (https://github.com/Amey-Thakur)
; REPOSITORY: https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
; LICENSE: MIT License
; =============================================================================

.MODEL SMALL
.STACK 100H

.DATA
    MSG_START   DB "Testing Overflow Flag (OF)...", 0DH, 0AH, "$"
    MSG_OF_SET  DB "OF is SET (Signed Overflow).", 0DH, 0AH, "$"
    MSG_OF_CLR  DB "OF is CLEAR (No Overflow).", 0DH, 0AH, "$"

.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX
    
    LEA DX, MSG_START
    MOV AH, 09H
    INT 21H
    
    ; --- Case 1: Signed Overflow (Positive + Positive = Negative) ---
    MOV AL, 127                         ; AL = +127 (7Fh) - Max Positive
    ADD AL, 1                           ; AL = -128 (80h) - Max Negative
    
    ; 127 + 1 should be 128. But 128 cannot fit in 8-bit signed (-128 to +127).
    ; So the CPU sets OF=1 because the sign bit changed unexpectedly.
    
    JO OF_IS_SET                        ; JO = Jump if Overflow
    JMP OF_IS_CLEAR

OF_IS_SET:
    LEA DX, MSG_OF_SET
    MOV AH, 09H
    INT 21H
    JMP EXIT

OF_IS_CLEAR:
    LEA DX, MSG_OF_CLR
    MOV AH, 09H
    INT 21H

EXIT:
    MOV AH, 4CH
    INT 21H
MAIN ENDP
END MAIN

; =============================================================================
; TECHNICAL NOTES:
; 1. OVERFLOW FLAG (Bit 11):
;    Set when a signed arithmetic operation produces a result that exceeds 
;    the capacity of the destination.
;    - 8-bit range: -128 to +127
;    - 16-bit range: -32768 to +32767
;    Technically: OF = CarryIn_to_MSB XOR CarryOut_from_MSB.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
