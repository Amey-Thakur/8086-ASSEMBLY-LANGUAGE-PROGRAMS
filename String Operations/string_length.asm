; Program: String Length Calculation
; Description: Calculate the length of a string
; Author: Amey Thakur

.MODEL SMALL
.STACK 100H

.DATA
    STR1 DB 'Hello World', '$'
    LEN DB ?
    MSG DB 'Length: $'

.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX
    
    LEA SI, STR1
    XOR CX, CX       ; Counter = 0
    
COUNT_LOOP:
    MOV AL, [SI]
    CMP AL, '$'      ; Check for end of string
    JE DONE
    INC CX           ; Increment counter
    INC SI           ; Move to next character
    JMP COUNT_LOOP
    
DONE:
    MOV LEN, CL      ; Store length
    
    ; Display message
    LEA DX, MSG
    MOV AH, 09H
    INT 21H
    
    ; Display length as digit (for small lengths)
    MOV DL, CL
    ADD DL, 30H      ; Convert to ASCII
    MOV AH, 02H
    INT 21H
    
    MOV AH, 4CH      ; Exit to DOS
    INT 21H
MAIN ENDP
END MAIN
