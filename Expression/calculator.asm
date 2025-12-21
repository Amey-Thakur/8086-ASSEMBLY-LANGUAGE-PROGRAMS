; =============================================================================
; TITLE: Interactive 8086 Calculator
; DESCRIPTION: A menu-driven integer calculator supporting Addition, 
;              Subtraction, Multiplication, and Division. It demonstrates 
;              switch-case logic, string I/O, and procedure-based architecture.
; AUTHOR: Amey Thakur (https://github.com/Amey-Thakur)
; REPOSITORY: https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
; LICENSE: MIT License
; =============================================================================

.MODEL SMALL
.STACK 100H

; -----------------------------------------------------------------------------
; DATA SEGMENT
; -----------------------------------------------------------------------------
.DATA
    ; Menu Strings
    STR_MENU   DB 0DH, 0AH, 0DH, 0AH, '=== 8086 CALCULATOR ===', 0DH, 0AH
               DB '1. Addition', 0DH, 0AH
               DB '2. Subtraction', 0DH, 0AH
               DB '3. Multiplication', 0DH, 0AH
               DB '4. Division', 0DH, 0AH
               DB '5. Exit', 0DH, 0AH
               DB 'Enter Choice: $'
               
    STR_NUM1   DB 0DH, 0AH, 'Enter First Number:  $'
    STR_NUM2   DB 0DH, 0AH, 'Enter Second Number: $'
    STR_RES    DB 0DH, 0AH, 'Result: $'
    STR_ERR    DB 0DH, 0AH, 'Error: Division by Zero!$'
    
    ; Storage
    VAL_NUM1   DW ?
    VAL_NUM2   DW ?
    VAL_RES    DW ?

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
MAIN PROC
    ; --- Step 1: Initialize Data Segment ---
    MOV AX, @DATA
    MOV DS, AX
    
APP_LOOP:
    ; --- Step 2: Show Menu ---
    LEA DX, STR_MENU
    MOV AH, 09H
    INT 21H
    
    ; --- Step 3: Get User Choice ---
    MOV AH, 01H
    INT 21H
    
    ; --- Step 4: Dispatcher (Switch-Case) ---
    CMP AL, '5'
    JE L_EXIT
    
    CMP AL, '1'
    JL APP_LOOP                         ; Ignore invalid low input
    CMP AL, '4'
    JG APP_LOOP                         ; Ignore invalid high input
    
    PUSH AX                             ; Save Choice
    
    ; --- Step 5: Get Operands ---
    CALL GET_OPERANDS
    
    POP AX                              ; Restore Choice
    
    ; Dispatch Execution
    CMP AL, '1'
    JE OP_ADD
    CMP AL, '2'
    JE OP_SUB
    CMP AL, '3'
    JE OP_MUL
    CMP AL, '4'
    JE OP_DIV
    JMP APP_LOOP
    
OP_ADD:
    MOV AX, VAL_NUM1
    ADD AX, VAL_NUM2
    MOV VAL_RES, AX
    JMP DISPLAY_RESULT
    
OP_SUB:
    MOV AX, VAL_NUM1
    SUB AX, VAL_NUM2
    MOV VAL_RES, AX
    JMP DISPLAY_RESULT
    
OP_MUL:
    MOV AX, VAL_NUM1
    MUL VAL_NUM2
    MOV VAL_RES, AX
    JMP DISPLAY_RESULT

OP_DIV:
    CMP VAL_NUM2, 0
    JE L_DIV_ERR
    
    MOV AX, VAL_NUM1
    XOR DX, DX                          ; Clear DX for 32/16 division prep
    DIV VAL_NUM2
    MOV VAL_RES, AX
    JMP DISPLAY_RESULT

L_DIV_ERR:
    LEA DX, STR_ERR
    MOV AH, 09H
    INT 21H
    JMP APP_LOOP

DISPLAY_RESULT:
    LEA DX, STR_RES
    MOV AH, 09H
    INT 21H
    
    MOV AX, VAL_RES
    CALL PRINT_DECIMAL
    JMP APP_LOOP
    
L_EXIT:
    MOV AH, 4CH
    INT 21H
MAIN ENDP

; -----------------------------------------------------------------------------
; PROCEDURE: GET_OPERANDS
; DESCRIPTION: Prompts for and reads two 16-bit decimal numbers.
; -----------------------------------------------------------------------------
GET_OPERANDS PROC
    ; Input Number 1
    LEA DX, STR_NUM1
    MOV AH, 09H
    INT 21H
    CALL READ_DECIMAL
    MOV VAL_NUM1, AX
    
    ; Input Number 2
    LEA DX, STR_NUM2
    MOV AH, 09H
    INT 21H
    CALL READ_DECIMAL
    MOV VAL_NUM2, AX
    
    RET
GET_OPERANDS ENDP

; -----------------------------------------------------------------------------
; PROCEDURE: READ_DECIMAL
; OUTPUT: AX = 16-bit Value
; DESCRIPTION: Reads ASCII digits until CR, converts to binary.
; -----------------------------------------------------------------------------
READ_DECIMAL PROC
    PUSH BX
    PUSH CX
    PUSH DX
    
    XOR BX, BX                          ; BX = Total
    
L_READ_CHAR:
    MOV AH, 01H
    INT 21H
    
    CMP AL, 0DH                         ; Check for Enter (CR)
    JE L_READ_DONE
    
    SUB AL, '0'                         ; ASCII to Int
    XOR AH, AH
    
    PUSH AX
    MOV AX, BX
    MOV CX, 10
    MUL CX                              ; Total * 10
    MOV BX, AX
    POP AX
    
    ADD BX, AX                          ; Total + Digit
    JMP L_READ_CHAR
    
L_READ_DONE:
    MOV AX, BX
    
    POP DX
    POP CX
    POP BX
    RET
READ_DECIMAL ENDP

; -----------------------------------------------------------------------------
; PROCEDURE: PRINT_DECIMAL
; INPUT: AX = 16-bit Value
; DESCRIPTION: Converts binary to ASCII and prints to standard output.
; -----------------------------------------------------------------------------
PRINT_DECIMAL PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    
    XOR CX, CX
    MOV BX, 10
    
L_DIV_STACK:
    XOR DX, DX
    DIV BX
    PUSH DX                             ; Save Remainder
    INC CX                              ; Count Digits
    CMP AX, 0
    JNE L_DIV_STACK
    
L_PRINT_STACK:
    POP DX
    ADD DL, '0'
    MOV AH, 02H
    INT 21H
    LOOP L_PRINT_STACK
    
    POP DX
    POP CX
    POP BX
    POP AX
    RET
PRINT_DECIMAL ENDP

END MAIN 

; =============================================================================
; TECHNICAL NOTES & ARCHITECTURAL INSIGHTS
; =============================================================================
; 1. MODULAR DESIGN:
;    Breaking the program into procedures (READ_DECIMAL, PRINT_DECIMAL) makes 
;    the MAIN loop clean and readable. This is "Structured Programming".
;
; 2. INPUT CONVERSION (ASCII to BINARY):
;    The CPU deals in binary. User input '1', '2' comes as 31H, 32H. 
;    Algorithm: Total = (Total * 10) + (Input - 30H).
;
; 3. OUTPUT CONVERSION (BINARY to ASCII):
;    To print 123, we repeatedly divide by 10.
;    123 / 10 = 12 R 3
;    12 / 10  = 1  R 2
;    1 / 10   = 0  R 1
;    Push Remainders: 3, 2, 1. Pop & Print: "1", "2", "3".
;
; 4. DIVISION SAFETY:
;    Checking for zero divisor prevents the dreaded "Divide Overflow" interrupt, 
;    which crashes 8086 programs instantly.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
