; Program: Addressing Modes Reference
; Description: Demonstrate all 8086 addressing modes
; Author: Amey Thakur

.MODEL SMALL
.STACK 100H

.DATA
    VAR1 DB 10H
    VAR2 DW 1234H
    ARRAY DB 10H, 20H, 30H, 40H, 50H
    MSG DB 'Addressing Modes Demo$'

.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX
    
    ; ========================================
    ; 1. IMMEDIATE ADDRESSING
    ; Operand is a constant value
    ; ========================================
    MOV AX, 1234H    ; Load immediate value
    MOV BL, 56H      ; Another immediate
    
    ; ========================================
    ; 2. REGISTER ADDRESSING
    ; Operand is a register
    ; ========================================
    MOV AX, BX       ; Register to register
    MOV CL, DL       ; Byte register
    
    ; ========================================
    ; 3. DIRECT ADDRESSING
    ; Operand is a memory location (by name)
    ; ========================================
    MOV AL, VAR1     ; Load from memory
    MOV AX, VAR2     ; Load word
    MOV VAR1, 20H    ; Store to memory
    
    ; ========================================
    ; 4. REGISTER INDIRECT ADDRESSING
    ; Address is in a register [BX], [SI], [DI], [BP]
    ; ========================================
    LEA BX, VAR1     ; Load address into BX
    MOV AL, [BX]     ; Access via register
    
    LEA SI, ARRAY
    MOV AL, [SI]     ; First element
    
    ; ========================================
    ; 5. INDEXED ADDRESSING
    ; Base + Index: [BX+SI], [BX+DI], [BP+SI], [BP+DI]
    ; ========================================
    MOV BX, 0
    MOV SI, 2
    LEA DI, ARRAY
    MOV AL, [DI+SI]  ; Access ARRAY[2]
    
    ; ========================================
    ; 6. BASED ADDRESSING
    ; [BX + displacement] or [BP + displacement]
    ; ========================================
    LEA BX, ARRAY
    MOV AL, [BX+1]   ; Access ARRAY[1]
    
    ; ========================================
    ; 7. BASED-INDEXED ADDRESSING
    ; [BX + SI + displacement]
    ; ========================================
    LEA BX, ARRAY
    MOV SI, 1
    MOV AL, [BX+SI+1] ; Access ARRAY[2]
    
    LEA DX, MSG
    MOV AH, 09H
    INT 21H
    
    MOV AH, 4CH
    INT 21H
MAIN ENDP
END MAIN

; ADDRESSING MODES SUMMARY:
; 1. Immediate   : MOV AX, 1234H
; 2. Register    : MOV AX, BX
; 3. Direct      : MOV AX, [1234H] or MOV AX, VAR
; 4. Indirect    : MOV AX, [BX]
; 5. Indexed     : MOV AX, [SI] or MOV AX, [DI]
; 6. Based       : MOV AX, [BX+4] or MOV AX, [BP+4]
; 7. Based-Index : MOV AX, [BX+SI] or MOV AX, [BX+SI+4]
