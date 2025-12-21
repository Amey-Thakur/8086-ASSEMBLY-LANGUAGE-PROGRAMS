; TITLE: 16-bit and 8-bit Addition
; DESCRIPTION: Demonstrates the addition of 8-bit and 16-bit operands using general-purpose registers.
; AUTHOR: Amey Thakur (https://github.com/Amey-Thakur)
; REPOSITORY: https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
; LICENSE: MIT License

DATA SEGMENT
    num8_1 DB 05H                       ; 8-bit operand 1
    num8_2 DB 06H                       ; 8-bit operand 2
    sum8   DB ?                         ; 8-bit result buffer
    
    num16_1 DW 1234H                    ; 16-bit operand 1
    num16_2 DW 0002H                    ; 16-bit operand 2
    sum16   DW ?                        ; 16-bit result buffer
DATA ENDS   

CODE SEGMENT
    ASSUME CS:CODE, DS:DATA
    
START: 
    ; --- Initialize Data Segment ---
    MOV AX, DATA
    MOV DS, AX                   
    
    ; --- 8-bit Addition Example ---
    ; Uses AL (Accumulator Low) for storing the operand and result.
    MOV AL, num8_1                 
    ADD AL, num8_2                 ; AL = 05H + 06H = 0BH
    MOV sum8, AL                  
    
    ; --- 16-bit Addition Example ---
    ; Uses CX (Count Register) as an example of using 16-bit general registers.
    MOV CX, num16_1                
    ADD CX, num16_2                ; CX = 1234H + 0002H = 1236H
    MOV sum16, CX                 
    
    ; --- DOS Termination ---
    MOV AH, 4CH
    INT 21H
    
CODE ENDS

; =============================================================================
; NOTES:
; 1. REGISTER SIZES: 
;    - 8-bit registers: AL, AH, BL, BH, CL, CH, DL, DH.
;    - 16-bit registers: AX, BX, CX, DX, SI, DI, BP, SP.
; 2. OPERAND MATCHING: The ADD instruction requires operands to be of the 
;    same size (e.g., you cannot add an 8-bit memory variable to a 16-bit register).
; 3. FLAG IMPACT: The ADD instruction updates several flags, most importantly:
;    - CF (Carry Flag): Set if result overflows the destination size.
;    - ZF (Zero Flag): Set if the result is 0.
;    - SF (Sign Flag): Set if the MSB of the result is 1 (negative in signed).
; 4. INITIALIZATION: In 8086 programs, DS must be manually initialized to the 
;    start of the DATA SEGMENT.
; =============================================================================

END START
