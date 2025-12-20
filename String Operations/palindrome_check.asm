; Program: Check Palindrome String
; Description: Check if a string is a palindrome
; Author: Amey Thakur

.MODEL SMALL
.STACK 100H

.DATA
    STR1 DB 'MADAM', '$'
    LEN EQU 5
    MSG_YES DB 'String is a Palindrome$'
    MSG_NO DB 'String is NOT a Palindrome$'

.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX
    
    LEA SI, STR1          ; Start pointer
    LEA DI, STR1
    ADD DI, LEN - 1       ; End pointer
    
    MOV CX, LEN / 2
CHECK_LOOP:
    MOV AL, [SI]
    MOV BL, [DI]
    CMP AL, BL
    JNE NOT_PALINDROME
    INC SI
    DEC DI
    LOOP CHECK_LOOP
    
    ; It's a palindrome
    LEA DX, MSG_YES
    JMP DISPLAY
    
NOT_PALINDROME:
    LEA DX, MSG_NO
    
DISPLAY:
    MOV AH, 09H
    INT 21H
    
    MOV AH, 4CH      ; Exit to DOS
    INT 21H
MAIN ENDP
END MAIN
