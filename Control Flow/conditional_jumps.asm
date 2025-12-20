;=============================================================================
; Program:     Conditional Jumps - Complete Reference
; Description: Demonstrate all conditional jump instructions in 8086.
;              Shows signed vs unsigned comparisons and flag-based jumps.
; 
; Author:      Amey Thakur
; Repository:  https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
; License:     MIT License
;=============================================================================

.MODEL SMALL
.STACK 100H

;-----------------------------------------------------------------------------
; DATA SEGMENT
;-----------------------------------------------------------------------------
.DATA
    MSG_EQ DB 'Numbers are equal$'
    MSG_NE DB 'Numbers are not equal$'
    MSG_GT DB 'First is greater$'
    MSG_LT DB 'First is less$'
    NEWLINE DB 0DH, 0AH, '$'
    NUM1 DW 50                          ; First number for comparison
    NUM2 DW 30                          ; Second number for comparison

;-----------------------------------------------------------------------------
; CODE SEGMENT
;-----------------------------------------------------------------------------
.CODE
MAIN PROC
    ; Initialize Data Segment
    MOV AX, @DATA
    MOV DS, AX
    
    ;-------------------------------------------------------------------------
    ; Perform Comparison
    ; CMP sets flags based on (NUM1 - NUM2) without storing result
    ;-------------------------------------------------------------------------
    MOV AX, NUM1                        ; AX = 50
    CMP AX, NUM2                        ; Compare AX with 30
    
    ;-------------------------------------------------------------------------
    ; Check for Equality
    ;-------------------------------------------------------------------------
    JE EQUAL                            ; Jump if Equal (ZF = 1)
    JNE NOT_EQUAL                       ; Jump if Not Equal (ZF = 0)
    
EQUAL:
    LEA DX, MSG_EQ
    JMP DISPLAY
    
NOT_EQUAL:
    ;-------------------------------------------------------------------------
    ; Check Greater or Less (Signed Comparison)
    ;-------------------------------------------------------------------------
    MOV AX, NUM1
    CMP AX, NUM2
    
    JG GREATER                          ; Jump if Greater (signed)
    JL LESS                             ; Jump if Less (signed)
    
GREATER:
    LEA DX, MSG_GT
    JMP DISPLAY
    
LESS:
    LEA DX, MSG_LT
    
DISPLAY:
    ;-------------------------------------------------------------------------
    ; Display Result
    ;-------------------------------------------------------------------------
    MOV AH, 09H
    INT 21H
    
    ;-------------------------------------------------------------------------
    ; Program Termination
    ;-------------------------------------------------------------------------
    MOV AH, 4CH                         ; DOS: Terminate program
    INT 21H
MAIN ENDP
END MAIN

;=============================================================================
; CONDITIONAL JUMP COMPLETE REFERENCE
;=============================================================================
; 
; EQUALITY/ZERO JUMPS:
; JE/JZ    - Jump if Equal / Zero (ZF = 1)
; JNE/JNZ  - Jump if Not Equal / Not Zero (ZF = 0)
; 
; SIGNED COMPARISON JUMPS (for signed numbers):
; JG/JNLE  - Jump if Greater (ZF=0 AND SF=OF)
; JGE/JNL  - Jump if Greater or Equal (SF = OF)
; JL/JNGE  - Jump if Less (SF != OF)
; JLE/JNG  - Jump if Less or Equal (ZF=1 OR SF!=OF)
; 
; UNSIGNED COMPARISON JUMPS (for unsigned numbers):
; JA/JNBE  - Jump if Above (CF=0 AND ZF=0)
; JAE/JNB  - Jump if Above or Equal (CF = 0)
; JB/JNAE  - Jump if Below (CF = 1)
; JBE/JNA  - Jump if Below or Equal (CF=1 OR ZF=1)
; 
; FLAG-BASED JUMPS:
; JC       - Jump if Carry (CF = 1)
; JNC      - Jump if No Carry (CF = 0)
; JO       - Jump if Overflow (OF = 1)
; JNO      - Jump if No Overflow (OF = 0)
; JS       - Jump if Sign/Negative (SF = 1)
; JNS      - Jump if No Sign/Positive (SF = 0)
; JP/JPE   - Jump if Parity Even (PF = 1)
; JNP/JPO  - Jump if Parity Odd (PF = 0)
; 
; COUNTER JUMP:
; JCXZ     - Jump if CX = 0
;=============================================================================
