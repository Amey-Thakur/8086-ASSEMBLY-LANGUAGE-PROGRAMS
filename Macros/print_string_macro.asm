; Program: Simple Macro - Print String
; Description: Define and use a macro to print strings
; Author: Amey Thakur

.MODEL SMALL
.STACK 100H

; Macro definition: Print a string
PRINT_STR MACRO STRING
    LEA DX, STRING
    MOV AH, 09H
    INT 21H
ENDM

; Macro definition: Print newline
NEWLINE MACRO
    MOV DL, 0DH
    MOV AH, 02H
    INT 21H
    MOV DL, 0AH
    MOV AH, 02H
    INT 21H
ENDM

.DATA
    MSG1 DB 'Hello from Macro!$'
    MSG2 DB 'This is line 2$'
    MSG3 DB 'Macros are powerful!$'

.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX
    
    PRINT_STR MSG1   ; Use macro
    NEWLINE          ; Use macro
    PRINT_STR MSG2   ; Use macro
    NEWLINE          ; Use macro
    PRINT_STR MSG3   ; Use macro
    
    MOV AH, 4CH      ; Exit to DOS
    INT 21H
MAIN ENDP
END MAIN
