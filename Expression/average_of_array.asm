;=============================================================================
; Program:     Average of Array Elements
; Description: Calculate the average of numbers in an array.
;              Demonstrates array traversal and arithmetic.
; 
; Author:      Amey Thakur
; Repository:  https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
; License:     MIT License
;=============================================================================

;-----------------------------------------------------------------------------
; DATA SEGMENT
;-----------------------------------------------------------------------------
DATA SEGMENT
    ARRAY DB 1, 4, 2, 3, 8, 6, 7, 5, 9  ; Array elements (sum = 45)
    LEN EQU 9                            ; Number of elements
    AVG DB ?                             ; Average result
    MSG DB "AVERAGE = $"
DATA ENDS

;-----------------------------------------------------------------------------
; CODE SEGMENT
; Algorithm: Average = Sum / Count
;-----------------------------------------------------------------------------
CODE SEGMENT
    ASSUME DS:DATA, CS:CODE
    
START:
    ; Initialize Data Segment
    MOV AX, DATA
    MOV DS, AX

    ;-------------------------------------------------------------------------
    ; Display Message
    ;-------------------------------------------------------------------------
    LEA SI, ARRAY
    LEA DX, MSG
    MOV AH, 9
    INT 21H

    ;-------------------------------------------------------------------------
    ; Calculate Sum of Array Elements
    ;-------------------------------------------------------------------------
    MOV AX, 00                          ; Clear accumulator
    MOV BL, LEN                         ; Divisor for average
    MOV CX, LEN                         ; Loop counter
    
LOOP1:
    ADD AL, ARRAY[SI]                   ; Add element to sum
    INC SI                              ; Next element
    LOOP LOOP1

    ;-------------------------------------------------------------------------
    ; Calculate Average: Sum / Count
    ; Sum = 45, Count = 9, Average = 5
    ;-------------------------------------------------------------------------
    DIV BL                              ; AL = quotient (average)

    ;-------------------------------------------------------------------------
    ; Display Result
    ;-------------------------------------------------------------------------
    ADD AL, 30H                         ; Convert to ASCII
    MOV DL, AL
    MOV AH, 2
    INT 21H

    ;-------------------------------------------------------------------------
    ; Program Termination
    ;-------------------------------------------------------------------------
    MOV AH, 4CH
    INT 21H     
CODE ENDS
END START

;=============================================================================
; AVERAGE CALCULATION NOTES:
; - Average = Sum of all elements / Number of elements
; - Array: {1,4,2,3,8,6,7,5,9} -> Sum=45, Count=9 -> Avg=5
; - Integer division truncates remainder
;=============================================================================
