; =============================================================================
; TITLE: Carry Flag (CF) Demonstration
; DESCRIPTION: Demonstrates how the Carry Flag (CF) is set during unsigned 
;              arithmetic overflow and how to manipulate it manually.
; AUTHOR: Amey Thakur (https://github.com/Amey-Thakur)
; REPOSITORY: https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
; LICENSE: MIT License
; =============================================================================

.MODEL SMALL
.STACK 100H

.DATA
    MSG_START   DB "Testing Carry Flag (CF)...", 0DH, 0AH, "$"
    MSG_SET     DB "CF is SET (CY).", 0DH, 0AH, "$"
    MSG_CLR     DB "CF is CLEAR (NC).", 0DH, 0AH, "$"

.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX
    
    LEA DX, MSG_START
    MOV AH, 09H
    INT 21H
    
    ; --- Case 1: Unsigned Overflow ---
    MOV AL, 255                         ; Max 8-bit value (FFh)
    ADD AL, 1                           ; AL becomes 0, CF becomes 1
    
    JC CF_IS_SET
    JMP CF_IS_CLEAR

CF_IS_SET:
    LEA DX, MSG_SET
    MOV AH, 09H
    INT 21H
    JMP PART_2

CF_IS_CLEAR:
    LEA DX, MSG_CLR
    MOV AH, 09H
    INT 21H

PART_2:
    ; --- Case 2: Manual Manipulation ---
    CLC                                 ; Force CF = 0
    STC                                 ; Force CF = 1
    CMC                                 ; Toggle CF (1 -> 0)
    
    ; Exit
    MOV AH, 4CH
    INT 21H
MAIN ENDP
END MAIN

; =============================================================================
; TECHNICAL NOTES:
; 1. CARRY FLAG (Bit 0):
;    Set when an arithmetic operation generates a carry out of the most 
;    significant bit (MSB). Essential for multi-byte arithmetic (ADC, SBB).
; 2. INSTRUCTIONS:
;    - JC (Jump if Carry): Jump if CF=1.
;    - JNC (Jump if No Carry): Jump if CF=0.
;    - STC/CLC/CMC: Explicit manipulation.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
