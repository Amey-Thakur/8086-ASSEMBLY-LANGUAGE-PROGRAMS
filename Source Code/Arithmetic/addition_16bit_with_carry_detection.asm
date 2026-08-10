; =============================================================================
; TITLE: 16-bit Addition with Carry Detection
; DESCRIPTION: This program performs the addition of two 16-bit unsigned integers 
;              and identifies if the result has exceeded the maximum capacity 
;              of a 16-bit register (FFFFH or 65,535). It emphasizes the use 
;              of conditional jumps for status checking.
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
    ; Inputs (DW = Define Word, 16-bit)
    VAL16_1 DW 1234H                    ; First 16-bit operand
    VAL16_2 DW 5140H                    ; Second 16-bit operand
    
    ; Output Buffers
    RESULT  DW ?                        ; Storage for 16-bit sum
    C_SET   DB 00H                      ; Boolean indicator for carry (01H = TRUE)

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------

    ; Labels for the report at the end of the program.
    RPT_HEAD DB 0DH, 0AH, 'Results:', 0DH, 0AH, '$'
    RPT_NL   DB 0DH, 0AH, '$'
    RPT_N_VAL16_1 DB '  VAL16_1 = ', '$'
    RPT_N_VAL16_2 DB '  VAL16_2 = ', '$'
    RPT_N_RESULT DB '  RESULT = ', '$'
    RPT_N_C_SET DB '  C_SET = ', '$'
.CODE
MAIN PROC
    ; --- Step 1: Initialization ---
    MOV AX, @DATA
    MOV DS, AX
   
    ; --- Step 2: 16-bit Unsigned Addition ---
    ; We load the first word into the accumulator AX and add the second.
    ; If the mathematical sum is > 65,535, the processor sets the Carry Flag.
    MOV AX, VAL16_1                     
    ADD AX, VAL16_2                     ; AX = 1234H + 5140H = 6374H
    
    ; --- Step 3: Status Check (Carry Detection) ---
    ; JNC (Jump if No Carry) checks the state of the CF bit in the FLAGS register.
    ; If CF = 0, the sum fit within 16 bits, and we skip the carry logic.
    JNC L_NO_CARRY               
    
    ; If execution reaches here, CF = 1. We mark our carry indicator variable.
    MOV C_SET, 01H                   
    
L_NO_CARRY:  
    ; Store the 16-bit portion of the result.
    MOV RESULT, AX                   

    ; --- Step 4: Halt & Debug ---
    ; INT 3 acts as a breakpoint for most 8086 emulators and debuggers.
    INT 03H                          
    
    ; --- Step 5: Clean Exit ---
    
    ; -------------------------------------------------------------------------
    ; WHAT THIS PROGRAM COMPUTED
    ;
    ; The work above leaves its answers in the variables below. Printing them
    ; is what makes the program demonstrate itself rather than needing a
    ; debugger to be believed.
    ; -------------------------------------------------------------------------
    LEA DX, RPT_HEAD
    CALL RPT_SAY

    LEA DX, RPT_N_VAL16_1
    CALL RPT_SAY
    MOV AX, VAL16_1
    CALL RPT_DECIMAL
    LEA DX, RPT_NL
    CALL RPT_SAY

    LEA DX, RPT_N_VAL16_2
    CALL RPT_SAY
    MOV AX, VAL16_2
    CALL RPT_DECIMAL
    LEA DX, RPT_NL
    CALL RPT_SAY

    LEA DX, RPT_N_RESULT
    CALL RPT_SAY
    MOV AX, RESULT
    CALL RPT_DECIMAL
    LEA DX, RPT_NL
    CALL RPT_SAY

    LEA DX, RPT_N_C_SET
    CALL RPT_SAY
    XOR AX, AX
    MOV AL, C_SET
    CALL RPT_DECIMAL
    LEA DX, RPT_NL
    CALL RPT_SAY

    MOV AH, 4CH
    INT 21H
MAIN ENDP

; -----------------------------------------------------------------------------
; RPT_DECIMAL
;
; Prints the unsigned value in AX as decimal. Named apart from any helper the
; program already had, so adding this report cannot clash with it.
;
; The digits come out of the division lowest first, which is the wrong order to
; print them in, so they are pushed and then popped back off.
; -----------------------------------------------------------------------------
RPT_DECIMAL PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX

    XOR CX, CX
    MOV BX, 10

RPT_SPLIT:
    XOR DX, DX
    DIV BX
    PUSH DX
    INC CX
    CMP AX, 0
    JNE RPT_SPLIT

RPT_EMIT:
    POP DX
    ADD DL, '0'
    MOV AH, 02H
    INT 21H
    LOOP RPT_EMIT

    POP DX
    POP CX
    POP BX
    POP AX
    RET
RPT_DECIMAL ENDP

; -----------------------------------------------------------------------------
; RPT_SAY
;
; Prints the dollar terminated string at DS:DX without disturbing AX, which
; matters because the caller usually has the value it is about to print there.
; -----------------------------------------------------------------------------
RPT_SAY PROC
    PUSH AX
    MOV AH, 09H
    INT 21H
    POP AX
    RET
RPT_SAY ENDP


END MAIN

; =============================================================================
; TECHNICAL NOTES & ARCHITECTURAL INSIGHTS
; =============================================================================
; 1. RANGE OF 16-BIT INTEGERS:
;    - Unsigned: 0 to 65,535 (FFFFH)
;    - Signed: -32,768 to +32,767
;
; 2. THE CARRY FLAG (CF):
;    The Carry Flag acts as the "17th bit" of a 16-bit addition.
;    - If VAL1 + VAL2 <= FFFFH, CF = 0.
;    - If VAL1 + VAL2 > FFFFH, CF = 1.
;
; 3. CARRY vs OVERFLOW:
;    - CARRY (CF) is used for UNSIGNED numbers to detect range overflow.
;    - OVERFLOW (OF) is used for SIGNED numbers to detect when the sign bit 
;      is erroneously flipped due to a large result.
;
; 4. CONDITIONAL JUMPS:
;    - JNC (Jump if No Carry): Executes jump if CF = 0.
;    - JC (Jump if Carry): Executes jump if CF = 1.
;    - These allow the programmer to handle errors or multi-word arithmetic.
;
; 5. LITTLE-ENDIAN REMINDER:
;    In memory, VAL16_1 (1234H) is actually stored as 34H followed by 12H 
;    (Least Significant Byte first).
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

