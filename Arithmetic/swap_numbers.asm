;=============================================================================
; Program:     Swap Two Numbers
; Description: Swap two numbers using XCHG instruction and XOR method.
;              Demonstrates exchange without temporary variable.
; 
; Author:      Amey Thakur
; Repository:  https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
; License:     MIT License
;=============================================================================

.MODEL SMALL
.STACK 100H

.DATA
    NUM1 DW 10
    NUM2 DW 20
    MSG1 DB 'Before swap: $'
    MSG2 DB 0DH, 0AH, 'After swap (using XCHG): $'
    MSG3 DB 0DH, 0AH, 'After swap (using XOR): $'
    COMMA DB ', $'

.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX
    
    ; Display before
    LEA DX, MSG1
    MOV AH, 09H
    INT 21H
    MOV AX, NUM1
    CALL PRINT_NUM
    LEA DX, COMMA
    MOV AH, 09H
    INT 21H
    MOV AX, NUM2
    CALL PRINT_NUM
    
    ; === Method 1: Using XCHG instruction ===
    MOV AX, NUM1
    MOV BX, NUM2
    XCHG AX, BX      ; Swap AX and BX
    MOV NUM1, AX
    MOV NUM2, BX
    
    LEA DX, MSG2
    MOV AH, 09H
    INT 21H
    MOV AX, NUM1
    CALL PRINT_NUM
    LEA DX, COMMA
    MOV AH, 09H
    INT 21H
    MOV AX, NUM2
    CALL PRINT_NUM
    
    ; === Method 2: Using XOR (no temp variable) ===
    ; Reset values
    MOV NUM1, 10
    MOV NUM2, 20
    
    MOV AX, NUM1
    MOV BX, NUM2
    ; XOR swap: A = A XOR B, B = A XOR B, A = A XOR B
    XOR AX, BX       ; AX = AX XOR BX
    XOR BX, AX       ; BX = BX XOR AX = original AX
    XOR AX, BX       ; AX = AX XOR BX = original BX
    MOV NUM1, AX
    MOV NUM2, BX
    
    LEA DX, MSG3
    MOV AH, 09H
    INT 21H
    MOV AX, NUM1
    CALL PRINT_NUM
    LEA DX, COMMA
    MOV AH, 09H
    INT 21H
    MOV AX, NUM2
    CALL PRINT_NUM
    
    MOV AH, 4CH
    INT 21H
MAIN ENDP

PRINT_NUM PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    XOR CX, CX
    MOV BX, 10
DIV_LOOP:
    XOR DX, DX
    DIV BX
    PUSH DX
    INC CX
    CMP AX, 0
    JNE DIV_LOOP
PRINT_LOOP:
    POP DX
    ADD DL, '0'
    MOV AH, 02H
    INT 21H
    LOOP PRINT_LOOP
    POP DX
    POP CX
    POP BX
    POP AX
    RET
PRINT_NUM ENDP

END MAIN
