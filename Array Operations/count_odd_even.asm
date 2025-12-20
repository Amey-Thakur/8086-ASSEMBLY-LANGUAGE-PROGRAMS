;=============================================================================
; Program:     Count Odd and Even Numbers
; Description: Count the number of odd and even numbers in an array.
;              Demonstrates bitwise testing using TEST instruction.
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
    ARR DB 1, 2, 3, 4, 5, 6, 7, 8, 9, 10   ; Array of numbers 1-10
    LEN EQU 10                              ; Array length
    ODD_COUNT DB 0                          ; Counter for odd numbers
    EVEN_COUNT DB 0                         ; Counter for even numbers
    MSG1 DB 'Odd count: $'
    MSG2 DB 0DH, 0AH, 'Even count: $'

;-----------------------------------------------------------------------------
; CODE SEGMENT
;-----------------------------------------------------------------------------
.CODE
MAIN PROC
    ; Initialize Data Segment
    MOV AX, @DATA
    MOV DS, AX
    
    ;-------------------------------------------------------------------------
    ; Initialize Loop
    ;-------------------------------------------------------------------------
    LEA SI, ARR                         ; SI points to array
    MOV CX, LEN                         ; Loop counter
    
    ;-------------------------------------------------------------------------
    ; Count Loop - Test each number for odd/even
    ; Odd numbers have LSB = 1, Even numbers have LSB = 0
    ;-------------------------------------------------------------------------
COUNT_LOOP:
    MOV AL, [SI]                        ; Load current element
    TEST AL, 1                          ; Test LSB: AND with 1, set flags
                                        ; If LSB=1, ZF=0 (odd)
                                        ; If LSB=0, ZF=1 (even)
    JZ IS_EVEN                          ; Jump if Zero Flag set (even)
    
    INC ODD_COUNT                       ; Increment odd counter
    JMP NEXT_NUM
    
IS_EVEN:
    INC EVEN_COUNT                      ; Increment even counter
    
NEXT_NUM:
    INC SI                              ; Point to next element
    LOOP COUNT_LOOP                     ; Decrement CX, loop if not zero
    
    ;-------------------------------------------------------------------------
    ; Display Results
    ;-------------------------------------------------------------------------
    ; Display odd count
    LEA DX, MSG1
    MOV AH, 09H
    INT 21H
    
    MOV AL, ODD_COUNT                   ; Odd count = 5 (1,3,5,7,9)
    ADD AL, '0'                         ; Convert to ASCII
    MOV DL, AL
    MOV AH, 02H
    INT 21H
    
    ; Display even count
    LEA DX, MSG2
    MOV AH, 09H
    INT 21H
    
    MOV AL, EVEN_COUNT                  ; Even count = 5 (2,4,6,8,10)
    ADD AL, '0'                         ; Convert to ASCII
    MOV DL, AL
    MOV AH, 02H
    INT 21H
    
    ;-------------------------------------------------------------------------
    ; Program Termination
    ;-------------------------------------------------------------------------
    MOV AH, 4CH
    INT 21H
MAIN ENDP
END MAIN

;=============================================================================
; NOTES:
; - TEST performs AND operation but doesn't store result, only sets flags
; - A number is odd if its Least Significant Bit (LSB) is 1
; - A number is even if its LSB is 0
; - TEST AL, 1: If AL=5 (0101), result=0001, ZF=0 (not zero, so odd)
;               If AL=4 (0100), result=0000, ZF=1 (zero, so even)
;=============================================================================
