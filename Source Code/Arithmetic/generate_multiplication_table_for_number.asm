; =============================================================================
; TITLE: Dynamic Multiplication Table Generator
; DESCRIPTION: This program generates and displays a formatted multiplication 
;              table (from 1 to 10) for a given number. It demonstrates 
;              complex loop construction, nested procedure calls, and a 
;              robust binary-to-decimal conversion algorithm.
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
    VAL_TABLE_NUM DB 7                  ; Table base number
    
    ; Formatter Strings
    MSG_HEADER    DB '--- Multiplication Table of $'
    MSG_CHAR_X    DB ' x $'
    MSG_CHAR_EQ   DB ' = $'
    MSG_NEWLINE   DB 0DH, 0AH, '$'          

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
MAIN PROC
    ; --- Step 1: Initialize Data Segment ---
    MOV AX, @DATA
    MOV DS, AX
    
    ; --- Step 2: Display Table Header ---
    LEA DX, MSG_HEADER
    MOV AH, 09H
    INT 21H
    
    XOR AH, AH                          ; Clear AH for 8-bit value
    MOV AL, VAL_TABLE_NUM
    CALL PRINT_NUM
    
    LEA DX, MSG_NEWLINE
    MOV AH, 09H
    INT 21H
    INT 21H                             
    
    ; --- Step 3: Main Table Loop ---
    ; CL = Loop counter (10 down to 1), BL = Current multiplier
    MOV CL, 10       
    MOV BL, 1        
    
L_TABLE_LOOP:
    ; (A) Print Base Number
    ; Debug: Print 'D' to check if this section runs
    PUSH DX
    MOV DL, 'D'
    MOV AH, 02H
    INT 21H
    POP DX
    
    XOR AH, AH                          ; Clear AH to ensures 16-bit AX is 0007h
    MOV AL, 7                           ; FORCE IMMEDIATE 7 (Debug)
    CALL PRINT_NUM                      ; Prints '7'
    
    ; (B) Print " x "
    LEA DX, MSG_CHAR_X
    MOV AH, 09H
    INT 21H
    
    ; (C) Print Multiplier
    XOR AH, AH                          ; Clear AH for 8-bit value
    MOV AL, BL
    CALL PRINT_NUM
    
    ; (D) Print " = "
    LEA DX, MSG_CHAR_EQ
    MOV AH, 09H
    INT 21H
    
    ; (E) Calculate and Print Product
    MOV AL, VAL_TABLE_NUM
    MUL BL                              ; AX = AL * BL
    CALL PRINT_NUM
    
    ; (F) Newline
    LEA DX, MSG_NEWLINE
    MOV AH, 09H
    INT 21H
    
    INC BL                              
    DEC CL                              
    JNZ L_TABLE_LOOP                      
    
    ; --- Step 4: Finalize ---
    MOV AH, 4CH
    INT 21H
MAIN ENDP

; -----------------------------------------------------------------------------
; PROCEDURE: PRINT_NUM
; DESCRIPTION: Converts AL (0-255) to decimal and prints it via Stack LIFO.
; -----------------------------------------------------------------------------
PRINT_NUM PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    ; Note: AH is NOT cleared here to allow printing 16-bit values (AX).
    ; Callers must clear AH if printing only AL.
    XOR CX, CX                          
    MOV BX, 10                          
    
L_DIV_DIGITS:
    XOR DX, DX
    DIV BX
    PUSH DX                             
    INC CX                              
    CMP AX, 0                           
    JNE L_DIV_DIGITS                      
    
L_DISPLAY_DIGITS:
    POP DX                              
    ADD DL, '0'                         
    MOV AH, 02H                         
    INT 21H
    LOOP L_DISPLAY_DIGITS                 
    
    POP DX
    POP CX
    POP BX
    POP AX
    RET
PRINT_NUM ENDP

END MAIN

; =============================================================================
; TECHNICAL NOTES & ARCHITECTURAL INSIGHTS
; =============================================================================
; 1. BINARY-TO-DECIMAL ALGORITHM:
;    Computers store numbers in binary. To display "72", we divide by 10 
;    repeatedly and store remainders on the stack to reverse the order for 
;    human-readable output.
;
; 2. STACK PRESERVATION:
;    The program uses PUSH/POP extensively to prevent procedures from 
;    clobbering the main loop registers.
;
; 3. DOS INTERRUPT PERFORMANCE:
;    INT 21H (AH=09H) is used for strings and (AH=02H) for characters. 
;
; 4. MUL INSTRUCTION SENSITIVITY:
;    'MUL BL' implicitly uses AL as the first operand and stores the 16-bit 
;    result in AX.
;
; 5. THE LOOP STRUCTURE:
;    The generator uses 'DEC' and 'JNZ' which provides manual control 
;    over the iterator compared to the hardware 'LOOP' instruction.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
