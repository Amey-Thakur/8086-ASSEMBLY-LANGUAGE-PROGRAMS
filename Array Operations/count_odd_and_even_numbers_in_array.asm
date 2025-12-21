; =============================================================================
; TITLE: Array-Based Parity Analysis (Odd/Even Distribution)
; DESCRIPTION: This program traverses an array of 8-bit integers and 
;              calculates the count of odd and even numbers. It utilizes 
;              bitwise testing of the Least Significant Bit (LSB) to 
;              efficiently determine parity without division.
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
    ; Data set for analysis
    NUM_ARRAY DB 1, 2, 3, 4, 5, 6, 7, 8, 9, 10   
    
    ; Setup loop constants and counters
    ARRAY_LEN  EQU 10                              
    ODD_COUNT  DB 0                          
    EVEN_COUNT DB 0                         
    
    ; Display Strings
    MSG_ODD  DB 'Statistical Result - Odd Count : $'
    MSG_EVEN DB 0DH, 0AH, 'Statistical Result - Even Count: $'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
MAIN PROC
    ; --- Step 1: Initialize Data Segment ---
    MOV AX, @DATA
    MOV DS, AX
    
    ; --- Step 2: Initialize Analysis Loop ---
    LEA SI, NUM_ARRAY                   ; SI = Pointer to start of array
    MOV CX, ARRAY_LEN                   ; CX = Loop counter (10 iterations)
    
    ; --- Step 3: Parity Determination Loop ---
ANALYZE_LOOP:
    MOV AL, [SI]                        ; Load current candidate into AL
    
    ; Bitwise logic: A number is even if Bit 0 (LSB) is 0, and odd if Bit 0 is 1.
    ; TEST performs an AND without modifying the destination register (AL).
    TEST AL, 01H                        
    
    ; If LSB is 0, ZF is set to 1. If LSB is 1, ZF is cleared to 0.
    JZ INC_EVEN                         ; Jump if Zero Flag is set (Even)
    
    ; Fall-through: Number is ODD
    INC ODD_COUNT                       
    JMP FINISH_CANDIDATE
    
INC_EVEN:
    INC EVEN_COUNT                      
    
FINISH_CANDIDATE:
    INC SI                              ; Increment memory pointer
    LOOP ANALYZE_LOOP                   ; Auto-decrement CX and jump if CX != 0
    
    ; --- Step 4: Formatting and Output ---
    ; Output Odd results
    LEA DX, MSG_ODD
    MOV AH, 09H
    INT 21H
    
    MOV AL, ODD_COUNT                   
    ADD AL, '0'                         ; Numerical value to ASCII char
    MOV DL, AL
    MOV AH, 02H                         ; Print character in DL
    INT 21H
    
    ; Output Even results
    LEA DX, MSG_EVEN
    MOV AH, 09H
    INT 21H
    
    MOV AL, EVEN_COUNT                  
    ADD AL, '0'                         
    MOV DL, AL
    MOV AH, 02H
    INT 21H
    
    ; --- Step 5: Termination ---
    MOV AH, 4CH
    INT 21H
MAIN ENDP

END MAIN

; =============================================================================
; TECHNICAL NOTES & ARCHITECTURAL INSIGHTS
; =============================================================================
; 1. BITWISE PARITY TEST:
;    Dividing by 2 to find a remainder (Modulo) is computationally expensive on 
;    8-bit processors like the 8086. Checking the Least Significant Bit (LSB) 
;    vía 'TEST AL, 1' is the most efficient way to determine parity, requiring 
;    only 3 clock cycles.
;
; 2. TEST vs AND:
;    The TEST instruction performs a bitwise logical AND but only updates flags, 
;    preserving the original data in the register. This is essential here as it 
;    allows the program to check parity without altering the number's value, 
;    making it available for other logic if needed.
;
; 3. THE LOOP INSTRUCTION:
;    'LOOP label' is a micro-coded convenience that combines 'DEC CX' and 
;    'JNZ label'. It assumes CX as the counter and is a hallmark of the 
;    8086 instruction set architecture.
;
; 4. ASCII CONVERSION (ADD AL, '0'):
;    This simple arithmetic trick works for single-digit numbers (0-9) because 
;    their ASCII codes (30H-39H) are exactly 48 ('0') units away from their 
;    binary values.
;
; 5. BRANCH PREDICTION (HISTORICAL):
;    The 8086 does not have modern branch prediction. Every jump taken adds 
;    latency to the instruction pipeline. Balancing the "Odd" and "Even" 
;    code paths ensures consistent performance across various data sets.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
