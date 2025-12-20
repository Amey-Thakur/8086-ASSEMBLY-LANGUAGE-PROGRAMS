; Program: Nested Macros
; Description: Macros that call other macros
; Author: Amey Thakur

.MODEL SMALL
.STACK 100H

; Basic macro: Print character
PRINT_CHAR MACRO CHAR
    MOV DL, CHAR
    MOV AH, 02H
    INT 21H
ENDM

; Macro that uses PRINT_CHAR: Print a line of characters
PRINT_LINE MACRO CHAR, COUNT
    LOCAL LOOP_START
    MOV CX, COUNT
LOOP_START:
    PRINT_CHAR CHAR
    LOOP LOOP_START
ENDM

; Macro: Print border
PRINT_BORDER MACRO
    PRINT_LINE '*', 40
    PRINT_CHAR 0DH
    PRINT_CHAR 0AH
ENDM

.DATA
    MSG DB 'Nested Macros Demo$'

.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX
    
    PRINT_BORDER
    
    LEA DX, MSG
    MOV AH, 09H
    INT 21H
    
    PRINT_CHAR 0DH
    PRINT_CHAR 0AH
    
    PRINT_BORDER
    
    MOV AH, 4CH      ; Exit to DOS
    INT 21H
MAIN ENDP
END MAIN
