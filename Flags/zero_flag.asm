; =============================================================================
; TITLE: Zero Flag (ZF) Demonstration
; DESCRIPTION: Demonstrates how the Zero Flag (ZF) indicates the result of 
;              arithmetic or comparison operations.
; AUTHOR: Amey Thakur (https://github.com/Amey-Thakur)
; REPOSITORY: https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
; LICENSE: MIT License
; =============================================================================

.MODEL SMALL
.STACK 100H

.DATA
    MSG_START   DB "Testing Zero Flag (ZF)...", 0DH, 0AH, "$"
    MSG_ZERO    DB "ZF is SET (Result is Zero).", 0DH, 0AH, "$"
    MSG_NOT_0   DB "ZF is CLEAR (Result is Not Zero).", 0DH, 0AH, "$"

.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX
    
    LEA DX, MSG_START
    MOV AH, 09H
    INT 21H
    
    ; --- Case 1: Subtraction resulting in Zero ---
    MOV AX, 1234H
    SUB AX, 1234H                       ; 1234 - 1234 = 0 -> ZF=1
    
    JZ ZF_IS_SET                        ; Jump if Zero (ZF=1)
    JMP ZF_IS_CLEAR

ZF_IS_SET:
    LEA DX, MSG_ZERO
    MOV AH, 09H
    INT 21H
    JMP PART_2

ZF_IS_CLEAR:
    LEA DX, MSG_NOT_0
    MOV AH, 09H
    INT 21H

PART_2:
    ; --- Case 2: Comparison (CMP) ---
    MOV BX, 5
    CMP BX, 5                           ; Internally updates flags like SUB
    JZ ZF_IS_SET_2
    JMP EXIT

ZF_IS_SET_2:
    LEA DX, MSG_ZERO
    MOV AH, 09H
    INT 21H
    
EXIT:
    MOV AH, 4CH
    INT 21H
MAIN ENDP
END MAIN

; =============================================================================
; TECHNICAL NOTES:
; 1. ZERO FLAG (Bit 6):
;    Set (1) if the result of an operation is zero.
;    Clear (0) if the result is non-zero.
;    Note: "JZ" (Jump Zero) is synonymous with "JE" (Jump Equal).
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
