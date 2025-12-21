; =============================================================================
; TITLE: Parity Flag (PF) Demonstration
; DESCRIPTION: Demonstrates the Parity Flag (PF), which is set if the lower 
;              8 bits of the result contain an even number of 1s (Even Parity).
; AUTHOR: Amey Thakur (https://github.com/Amey-Thakur)
; REPOSITORY: https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
; LICENSE: MIT License
; =============================================================================

.MODEL SMALL
.STACK 100H

.DATA
    MSG_START   DB "Testing Parity Flag (PF)...", 0DH, 0AH, "$"
    MSG_PE      DB "PF is SET (Parity Even).", 0DH, 0AH, "$"
    MSG_PO      DB "PF is CLEAR (Parity Odd).", 0DH, 0AH, "$"

.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX
    
    LEA DX, MSG_START
    MOV AH, 09H
    INT 21H
    
    ; --- Case 1: Even Parity ---
    ; AL = 3 (0000 0011b) -> Two 1s -> Even Parity -> PF=1
    MOV AL, 3
    OR AL, 0                            ; Update flags
    
    JP PF_IS_SET                        ; JP (Jump Parity) = JPE (Jump Parity Even)
    JMP PF_IS_CLEAR

PF_IS_SET:
    LEA DX, MSG_PE
    MOV AH, 09H
    INT 21H
    JMP NEXT_TEST

PF_IS_CLEAR:
    LEA DX, MSG_PO
    MOV AH, 09H
    INT 21H

NEXT_TEST:
    ; --- Case 2: Odd Parity ---
    ; AL = 7 (0000 0111b) -> Three 1s -> Odd Parity -> PF=0
    MOV AL, 7
    OR AL, 0
    JNP PF_IS_CLEAR_2                   ; JNP = Jump No Parity (Odd)
    JMP EXIT

PF_IS_CLEAR_2:
    LEA DX, MSG_PO
    MOV AH, 09H
    INT 21H

EXIT:
    MOV AH, 4CH
    INT 21H
MAIN ENDP
END MAIN

; =============================================================================
; TECHNICAL NOTES:
; 1. PARITY FLAG (Bit 2):
;    - Set (1) if the least significant byte of the result has an EVEN number of 1s.
;    - Clear (0) if it has an ODD number of 1s.
;    - Historically used for error checking in data transmission.
; 2. SCOPE:
;    PF ONLY considers the lower 8 bits (AL), even in 16-bit operations.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
