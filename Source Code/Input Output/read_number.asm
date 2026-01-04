; =============================================================================
; TITLE: Read Decimal Number Input
; DESCRIPTION: Reads a sequence of decimal digit characters mainly from the 
;              keyboard and converts them into a 16-bit integer value in AX.
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
    MSG_PROMPT  DB "Enter a number (0-65535): $"
    MSG_RES     DB 0DH, 0AH, "Value stored in AX.$"
    RESULT      DW ?

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
MAIN PROC
    ; --- Step 1: Initialize DS ---
    MOV AX, @DATA
    MOV DS, AX

    ; --- Step 2: Prompt User ---
    LEA DX, MSG_PROMPT
    MOV AH, 09H
    INT 21H

    ; --- Step 3: Read & Parse ---
    CALL READ_DEC_PROC
    MOV RESULT, AX                      ; Store result

    ; --- Step 4: Confirm & Exit ---
    LEA DX, MSG_RES
    MOV AH, 09H
    INT 21H

    MOV AH, 4CH
    INT 21H
MAIN ENDP

; -----------------------------------------------------------------------------
; PROCEDURE: READ_DEC_PROC
; Returns: AX (16-bit integer)
; -----------------------------------------------------------------------------
READ_DEC_PROC PROC
    PUSH BX
    PUSH CX
    PUSH DX

    XOR BX, BX                          ; Accumulator = 0

L_READ_KEY:
    MOV AH, 01H                         ; DOS Read Char with Echo
    INT 21H
    
    CMP AL, 0DH                         ; Check for ENTER (CR)
    JE L_DONE
    
    ; Validate Digit ('0' <= AL <= '9')
    CMP AL, '0'
    JB L_READ_KEY                       ; Ignore invalid
    CMP AL, '9'
    JA L_READ_KEY                       ; Ignore invalid
    
    AND AX, 000FH                       ; Convert ASCII '0'-'9' to Val 0-9
    
    ; Logic: Accumulator = (Accumulator * 10) + NewDigit
    PUSH AX                             ; Save New Digit
    
    MOV AX, BX
    MOV CX, 10
    MUL CX                              ; AX = Total * 10
    MOV BX, AX                          ; BX = Total * 10
    
    POP AX                              ; Restore New Digit
    ADD BX, AX                          ; BX = (Total * 10) + Digit
    
    JMP L_READ_KEY

L_DONE:
    MOV AX, BX                          ; Move Result to AX
    POP DX
    POP CX
    POP BX
    RET
READ_DEC_PROC ENDP

END MAIN

; =============================================================================
; TECHNICAL NOTES & ARCHITECTURAL INSIGHTS
; =============================================================================
; 1. INPUT PARSING:
;    - The keyboard returns ASCII. The CPU performs Math. We must bridge this gap.
;    - ASCII '0' is 30h. Masking with 0Fh (AND AL, 0Fh) strips the high nibble, 
;      leaving the raw value (0-9).
;
; 2. WEIGHTED SUM:
;    As we type '1', '2', '3', the value evolves:
;    - Input '1': Val = 1
;    - Input '2': Val = (1 * 10) + 2 = 12
;    - Input '3': Val = (12 * 10) + 3 = 123
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
