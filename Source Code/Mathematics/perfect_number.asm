; =============================================================================
; TITLE: Perfect Number Check
; DESCRIPTION: Determine if a 16-bit number is "Perfect".
;              A Perfect number is equal to the sum of its proper divisors.
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
    NUM     DW 28                       ; 28 = 1 + 2 + 4 + 7 + 14 (Perfect Number)
    SUM     DW 0                        ; Accumulator for divisors
    MSG_YES DB 'The number is PERFECT.$'
    MSG_NO  DB 'The number is NOT perfect.$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
MAIN PROC
    ; Setup Data Segment
    MOV AX, @DATA
    MOV DS, AX
    
    ; We iterate from 1 up to (NUM - 1) to find proper divisors
    MOV BX, 1                           ; Starting divisor
    
DIVISOR_SEARCH:
    ; Check if BX is a divisor: (NUM % BX == 0)
    MOV AX, NUM
    XOR DX, DX
    DIV BX                              ; AX = Quotient, DX = Remainder
    
    CMP DX, 0                           ; Is it a divisor?
    JNE NEXT_ITERATION
    
    ADD SUM, BX                         ; Add BX to our running sum
    
NEXT_ITERATION:
    INC BX                              ; Next candidate
    CMP BX, NUM                         ; Stop before reaching NUM itself
    JL DIVISOR_SEARCH
    
    ; -------------------------------------------------------------------------
    ; VALIDATION
    ; -------------------------------------------------------------------------
    MOV AX, SUM
    CMP AX, NUM                         ; Does Sum of Divisors equal original?
    JE SUCCESS
    
    LEA DX, MSG_NO
    JMP DISPLAY_RESULT
    
SUCCESS:
    LEA DX, MSG_YES
    
DISPLAY_RESULT:
    MOV AH, 09H                         ; DOS: Print string
    INT 21H
    
    ; Exit
    MOV AH, 4CH
    INT 21H
MAIN ENDP
END MAIN

; =============================================================================
; TECHNICAL NOTES
; =============================================================================
; 1. EXAMPLES:
;    - 6 (1+2+3=6)
;    - 28 (1+2+4+7+14=28)
; 2. OPTIMIZATION:
;    - A divisor will never be greater than NUM/2. 
;    - Starting with BX=1 and checking till NUM/2 is faster.
;    - This implementation uses the fundamental definition for clarity.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
