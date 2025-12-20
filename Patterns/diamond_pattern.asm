; Program: Diamond Pattern
; Description: Print a diamond pattern using asterisks
; Author: Amey Thakur
; Keywords: 8086 diamond pattern, star diamond

.MODEL SMALL
.STACK 100H

.DATA
    ROWS DB 5        ; Half height of diamond
    MSG DB 'Diamond Pattern:', 0DH, 0AH, '$'

.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX
    
    LEA DX, MSG
    MOV AH, 09H
    INT 21H
    
    ; Upper half (including middle)
    MOV CL, 1        ; Stars count
    MOV BL, ROWS     ; Row counter
    
UPPER_HALF:
    PUSH BX
    PUSH CX
    
    ; Print leading spaces
    MOV AL, ROWS
    SUB AL, CL
    MOV CH, AL
SPACE_LOOP1:
    CMP CH, 0
    JE PRINT_STARS1
    MOV DL, ' '
    MOV AH, 02H
    INT 21H
    DEC CH
    JMP SPACE_LOOP1
    
PRINT_STARS1:
    POP CX
    PUSH CX
    MOV CH, CL
STAR_LOOP1:
    MOV DL, '*'
    MOV AH, 02H
    INT 21H
    MOV DL, ' '
    MOV AH, 02H
    INT 21H
    DEC CH
    JNZ STAR_LOOP1
    
    ; Newline
    MOV DL, 0DH
    MOV AH, 02H
    INT 21H
    MOV DL, 0AH
    MOV AH, 02H
    INT 21H
    
    POP CX
    POP BX
    INC CL
    DEC BL
    JNZ UPPER_HALF
    
    ; Lower half
    MOV CL, ROWS
    DEC CL           ; Start from ROWS-1
    
LOWER_HALF:
    CMP CL, 0
    JE DONE
    
    PUSH CX
    
    ; Print leading spaces
    MOV AL, ROWS
    SUB AL, CL
    MOV CH, AL
SPACE_LOOP2:
    CMP CH, 0
    JE PRINT_STARS2
    MOV DL, ' '
    MOV AH, 02H
    INT 21H
    DEC CH
    JMP SPACE_LOOP2
    
PRINT_STARS2:
    POP CX
    PUSH CX
    MOV CH, CL
STAR_LOOP2:
    MOV DL, '*'
    MOV AH, 02H
    INT 21H
    MOV DL, ' '
    MOV AH, 02H
    INT 21H
    DEC CH
    JNZ STAR_LOOP2
    
    ; Newline
    MOV DL, 0DH
    MOV AH, 02H
    INT 21H
    MOV DL, 0AH
    MOV AH, 02H
    INT 21H
    
    POP CX
    DEC CL
    JMP LOWER_HALF
    
DONE:
    MOV AH, 4CH
    INT 21H
MAIN ENDP
END MAIN
