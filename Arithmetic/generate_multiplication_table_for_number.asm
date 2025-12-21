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
    TABLE_NUM DB 7                      ; Generate table for this number
    
    ; Formatter Strings
    HEADER    DB '--- Multiplication Table of $'
    CHAR_X    DB ' x $'
    CHAR_EQ   DB ' = $'
    NEWLINE   DB 0DH, 0AH, '$'          ; Carriage return + Line feed

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
MAIN PROC
    ; --- Step 1: Initialize Data Segment ---
    MOV AX, @DATA
    MOV DS, AX
    
    ; --- Step 2: Display Table Header ---
    LEA DX, HEADER
    MOV AH, 09H
    INT 21H
    
    ; Print the base number
    MOV AL, TABLE_NUM
    CALL PRINT_NUM
    
    ; Add spacing/newlines
    LEA DX, NEWLINE
    MOV AH, 09H
    INT 21H
    INT 21H                             ; Double newline for spacing
    
    ; --- Step 3: Main Table Generation Loop ---
    ; CL = Loop counter (10 down to 1)
    ; BL = Current multiplier (1 up to 10)
    MOV CL, 10       
    MOV BL, 1        
    
TABLE_LOOP:
    PUSH CX                             ; Preserve loop counter on stack
    
    ; 3a. Print the base number
    MOV AL, TABLE_NUM
    CALL PRINT_NUM
    
    ; 3b. Print multiplication symbol " x "
    LEA DX, CHAR_X
    MOV AH, 09H
    INT 21H
    
    ; 3c. Print current multiplier (incrementing BL)
    MOV AL, BL
    CALL PRINT_NUM
    
    ; 3d. Print equals symbol " = "
    LEA DX, CHAR_EQ
    MOV AH, 09H
    INT 21H
    
    ; 3e. Calculate Product: Product = TABLE_NUM * BL
    ; Result is stored in AX.
    MOV AL, TABLE_NUM
    MUL BL           
    
    ; 3f. Print calculated product
    CALL PRINT_NUM
    
    ; 3g. Print newline for next entry
    LEA DX, NEWLINE
    MOV AH, 09H
    INT 21H
    
    ; 3h. Update iterator and check loop condition
    INC BL                              ; Increment multiplier
    POP CX                              ; Restore exterior loop counter
    DEC CL                              ; Decrement counter
    JNZ TABLE_LOOP                      ; Repeat until CL = 0
    
    ; --- Step 4: Finalize Program ---
    MOV AH, 4CH
    INT 21H
MAIN ENDP

; -----------------------------------------------------------------------------
; PROCEDURE: PRINT_NUM
; DESCRIPTION: Converts the numeric value in AL (0-255) into its decimal 
;              ASCII representation and prints it to the screen.
; -----------------------------------------------------------------------------
PRINT_NUM PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    
    ; Preparation for division-based conversion
    XOR AH, AH                          ; Clear AH for word division
    XOR CX, CX                          ; CX will count generated digits
    MOV BX, 10                          ; Divisor (for base-10 conversion)
    
DIV_DIGITS:
    ; Divide AX by 10. Remainder (digit) is in DX, Quotient in AX.
    XOR DX, DX
    DIV BX
    PUSH DX                             ; Store digit on stack (Last-In-First-Out)
    INC CX                              ; Increment digit count
    CMP AX, 0                           ; Is quotient 0?
    JNE DIV_DIGITS                      ; If not, continue stripping digits
    
DISPLAY_DIGITS:
    ; Pop digits from stack in reverse order and print them.
    POP DX                              ; Retrieve most significant digit
    ADD DL, '0'                         ; Convert numeric 0-9 to ASCII '0'-'9'
    MOV AH, 02H                         ; DOS Function: Print Character
    INT 21H
    LOOP DISPLAY_DIGITS                 ; Repeat for all digits in CX
    
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
;    Computers store numbers in binary. To display "72", we must:
;    - Divide 72 by 10 -> Quotient 7, Remainder 2.
;    - The remainder (2) is our last digit.
;    - Repeat with quotient 7 -> Divide by 10 -> Quotient 0, Remainder 7.
;    - Using the Stack (LIFO) ensures we print "7" then "2".
;
; 2. STACK PRESERVATION:
;    The program uses PUSH and POP extensively. This is critical for 
;    preventing the 'PRINT_NUM' procedure from corrupting the loop counter (CX) 
;    or the current multiplier (BL) of the main procedure.
;
; 3. DOS INTERRUPT PERFORMANCE:
;    The program uses INT 21H (AH=09H) for strings and (AH=02H) for chars. 
;    While slower than direct video memory writing, this method ensures 
;    compatibility across all 8086 systems.
;
; 4. MUL INSTRUCTION SENSITIVITY:
;    Note that 'MUL BL' automatically uses AL as the first operand and 
;    stores the result in AX. This is an implicit fixed-register instruction.
;
; 5. THE LOOP STRUCTURE:
;    The table generation uses a 'DEC' and 'JNZ' combination. This is 
;    conceptually identical to the 'LOOP' instruction but allows more 
;    flexibility in register usage.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
