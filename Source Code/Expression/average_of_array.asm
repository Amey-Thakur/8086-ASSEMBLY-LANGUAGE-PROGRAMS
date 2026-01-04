; =============================================================================
; TITLE: Array Average Calculation
; DESCRIPTION: This program calculates the integer average of a byte array. 
;              It sums all elements and divides by the count, demonstrating 
;              accumulator usage and division in 8086 assembly.
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
    ; Input Array (Sum = 1+4+2+3+8+6+7+5+9 = 45)
    ARRAY_DATA DB 1, 4, 2, 3, 8, 6, 7, 5, 9 
    ARRAY_LEN  EQU 9                    
    
    ; Output Message
    MSG_AVG    DB "Calculated Average: $"
    
    ; Result Storage
    VAL_AVG    DB ?                     

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
MAIN PROC
    ; --- Step 1: Initialize Data Segment ---
    MOV AX, @DATA
    MOV DS, AX
    
    ; --- Step 2: Calculate Sum ---
    MOV CX, ARRAY_LEN                   ; Loop Counter
    LEA SI, ARRAY_DATA                  ; Pointer to Array
    XOR AX, AX                          ; Clear Accumulator (AX = 0)
    
SUM_LOOP:
    XOR BH, BH
    MOV BL, [SI]                        ; Load Byte to BL
    ADD AX, BX                          ; Add to Accumulator (16-bit to avoid overflow)
    
    INC SI                              ; Move to next element
    LOOP SUM_LOOP                       ; Continue until CX = 0
    
    ; --- Step 3: Calculate Average ---
    ; Average = Sum (AX) / Count (BL)
    ; AX holds Sum (45). BL holds Divisor.
    MOV BL, ARRAY_LEN
    DIV BL                              ; AX / BL -> AL = Quotient, AH = Remainder
    
    MOV VAL_AVG, AL                     ; Store Average (5)
    
    ; --- Step 4: Display Result ---
    LEA DX, MSG_AVG
    MOV AH, 09H
    INT 21H
    
    ; Convert result to ASCII and Print
    MOV AL, VAL_AVG
    ADD AL, 30H                         ; ASCII Offset
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
; 1. ACCUMULATOR WIDTH:
;    We use AX (16-bit) to store the sum even though the elements are 8-bit.
;    This prevents overflow if the sum exceeds 255 (FFh), which is common in
;    array aggregations.
;
; 2. INTEGER DIVISION:
;    The DIV instruction divides AX by the source operand.
;    - If source is 8-bit (BL), result is AL (Quotient), AH (Remainder).
;    - This implies the average is truncated (floor function).
;    - For 45 / 9, Result = 5, Remainder = 0.
;
; 3. LOOP MANAGEMENT:
;    The LOOP instruction uses CX as an implicit counter. It decrements CX
;    and jumps if CX != 0, making it efficient for fixed-iteration loops.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
