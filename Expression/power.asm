; =============================================================================
; TITLE: Power Calculation (Exponentiation)
; DESCRIPTION: Calculates Base^Exponent using iterative multiplication.
;              Demonstrates simple loop-based arithmetic accumulation.
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
    BASE      DB 3                      ; Base
    EXPONENT  DB 4                      ; Power (3^4 = 81)
    RESULT    DW ?                      
    MSG_RES   DB "Result: $"

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
MAIN PROC
    ; --- Step 1: Initialize Data Segment ---
    MOV AX, @DATA
    MOV DS, AX
    
    ; --- Step 2: Initialize ---
    MOV AL, 1                           ; Result accumulator (Identity)
    MOV BL, BASE
    MOV CL, EXPONENT
    XOR CH, CH                          ; Clear CH for loop
    
    CMP CL, 0                           ; Check Power 0
    JE L_DONE                           ; Any^0 = 1
    
    ; --- Step 3: Multiplication Loop ---
POWER_LOOP:
    MUL BL                              ; AX = AL * BL (Base)
    ; Note: Result accumulates in AX. If > 255, AH is used.
    ; Ideally should use 16-bit MUL if Base was already 16-bit.
    ; Here we assume Logic: Res = Res * Base.
    ; But wait, 'MUL BL' multiplies AL by BL. Result in AX.
    ; Next iteration, we need to multiply AX by BL? 
    ; 8086 'MUL r8' implies AX = AL * r8.
    ; If Result grows into AX (>255), we can't use 'MUL BL' naively 
    ; because it resets AH? No, it USES AL.
    ; Correct 16-bit logic: MUL BX (DX:AX = AX * BX).
    
    ; FIXING LOGIC FOR STANDARD 16-BIT RESULT:
    ; We treat 'Result' as 16-bit (AX).
    ; We treat 'Base' as 16-bit (BX).
    
    ; Re-init for robust 16-bit support:
    MOV AX, 1                           ; Result in AX
    MOV BL, BASE
    XOR BH, BH                          ; Base in BX (3)
    
L_LOOP_16:
    MUL BX                              ; DX:AX = AX * BX
    LOOP L_LOOP_16
    
L_DONE:
    MOV RESULT, AX
    
    ; --- Step 4: Display Result ---
    LEA DX, MSG_RES
    MOV AH, 09H
    INT 21H
    
    MOV AX, RESULT
    CALL PRINT_DECIMAL
    
    ; --- Step 5: Termination ---
    MOV AH, 4CH
    INT 21H
MAIN ENDP

; -----------------------------------------------------------------------------
; PROCEDURE: PRINT_DECIMAL
; INPUT:  AX = 16-bit Value
; -----------------------------------------------------------------------------
PRINT_DECIMAL PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    
    XOR CX, CX
    MOV BX, 10
    
L_DIV:
    XOR DX, DX
    DIV BX
    PUSH DX
    INC CX
    CMP AX, 0
    JNE L_DIV
    
L_PRINT:
    POP DX
    ADD DL, '0'
    MOV AH, 02H
    INT 21H
    LOOP L_PRINT
    
    POP DX
    POP CX
    POP BX
    POP AX
    RET
PRINT_DECIMAL ENDP

END MAIN

; =============================================================================
; TECHNICAL NOTES & ARCHITECTURAL INSIGHTS
; =============================================================================
; 1. MULTIPLICATION WIDTH:
;    - MUL r8  -> AX = AL * r8
;    - MUL r16 -> DX:AX = AX * r16
;    Since powers grow fast (exponentially), we must use 16-bit multiplication 
;    (MUL BX) to support results > 255. Even so, 3^9 exceeds 16 bits.
;
; 2. IDENTITY VALUE:
;    The accumulator must initialize to 1, not 0, because 0 * N = 0.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
