;=============================================================================
; Program:     Prime Number Check
; Description: Check if a given number is prime.
;              Prime numbers are divisible only by 1 and themselves.
; 
; Author:      Amey Thakur
; Repository:  https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
; License:     MIT License
;=============================================================================

.MODEL SMALL
.STACK 100H

;-----------------------------------------------------------------------------
; DATA SEGMENT
;-----------------------------------------------------------------------------
.DATA
    MSG DB "The Given Number is a PRIME Number$"
    NMSG DB "The Given Number is NOT a Prime Number$"
    NUM DB 71H                          ; Number to check (113 decimal - prime)

;-----------------------------------------------------------------------------
; CODE SEGMENT
; Algorithm: Check divisibility from 2 to NUM-1
; If divisible by any number other than 1 and itself, not prime
;-----------------------------------------------------------------------------
.CODE
START:
    ; Initialize Data Segment
    MOV AX, @DATA
    MOV DS, AX

    ;-------------------------------------------------------------------------
    ; Initialize Variables
    ;-------------------------------------------------------------------------
    MOV AL, NUM                         ; AL = number to check
    MOV BL, 02H                         ; Start dividing from 2
    MOV DX, 0000H                       ; Clear DX to avoid overflow
    MOV AH, 00H                         ; Clear AH
    MOV BH, 00H                         ; BH = divisor count

    ;-------------------------------------------------------------------------
    ; Prime Check Loop
    ; Try dividing by all numbers from 2 to NUM-1
    ;-------------------------------------------------------------------------
L1: 
    DIV BL                              ; AL = quotient, AH = remainder
    CMP AH, 00H                         ; Check if remainder = 0
    JNE NEXT                            ; If not divisible, try next
    INC BH                              ; Found a divisor, increment count
    
NEXT:
    CMP BH, 02H                         ; If more than 2 divisors (1 and self)
    JE FALSE                            ; Not prime
    
    INC BL                              ; Try next divisor
    MOV AX, 0000H                       ; Reset for next division
    MOV DX, 0000H
    MOV AL, NUM                         ; Reload number
    
    CMP BL, NUM                         ; Have we checked all divisors?
    JNE L1                              ; Continue if not

    ;-------------------------------------------------------------------------
    ; Number is Prime
    ;-------------------------------------------------------------------------
TRUE: 
    LEA DX, MSG
    MOV AH, 09H
    INT 21H
    JMP EXIT

    ;-------------------------------------------------------------------------
    ; Number is Not Prime
    ;-------------------------------------------------------------------------
FALSE: 
    LEA DX, NMSG
    MOV AH, 09H
    INT 21H

EXIT:
    MOV AH, 4CH
    INT 21H
END START

;=============================================================================
; PRIME NUMBER NOTES:
; - Prime: Divisible only by 1 and itself
; - First primes: 2, 3, 5, 7, 11, 13, 17, 19, 23, 29...
; - 1 is not prime (by definition)
; - 2 is the only even prime number
; - Optimization: Only check up to sqrt(n)
;=============================================================================
