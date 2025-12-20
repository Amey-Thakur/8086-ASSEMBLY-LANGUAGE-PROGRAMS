; Program: Count Odd and Even Numbers
; Description: Count odd and even numbers in an array
; Author: Amey Thakur
; Keywords: 8086 odd even, count odd even, array odd even

.MODEL SMALL
.STACK 100H

.DATA
    ARR DB 1, 2, 3, 4, 5, 6, 7, 8, 9, 10
    LEN EQU 10
    ODD_COUNT DB 0
    EVEN_COUNT DB 0
    MSG1 DB 'Odd count: $'
    MSG2 DB 0DH, 0AH, 'Even count: $'

.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX
    
    LEA SI, ARR
    MOV CX, LEN
    
COUNT_LOOP:
    MOV AL, [SI]
    TEST AL, 1       ; Check LSB (1 = odd, 0 = even)
    JZ IS_EVEN
    
    INC ODD_COUNT
    JMP NEXT_NUM
    
IS_EVEN:
    INC EVEN_COUNT
    
NEXT_NUM:
    INC SI
    LOOP COUNT_LOOP
    
    ; Display odd count
    LEA DX, MSG1
    MOV AH, 09H
    INT 21H
    
    MOV AL, ODD_COUNT
    ADD AL, '0'
    MOV DL, AL
    MOV AH, 02H
    INT 21H
    
    ; Display even count
    LEA DX, MSG2
    MOV AH, 09H
    INT 21H
    
    MOV AL, EVEN_COUNT
    ADD AL, '0'
    MOV DL, AL
    MOV AH, 02H
    INT 21H
    
    MOV AH, 4CH
    INT 21H
MAIN ENDP
END MAIN
