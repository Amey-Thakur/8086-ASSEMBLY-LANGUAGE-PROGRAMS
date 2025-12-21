; =============================================================================
; TITLE: 8-bit Addition with Interactive User Input
; DESCRIPTION: This program reads two single-digit decimal numbers from the 
;              keyboard, calculates their sum, and displays the result on 
;              the screen. It demonstrates ASCII-to-Binary conversion, 
;              unpacked BCD arithmetic using AAA, and DOS I/O interrupts.
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
    ; Variables for storing numeric values
    VAL1 DB ?                           
    VAL2 DB ?                           
    RES  DB ?                           
    
    ; Display Strings
    MSG_PROMPT1 DB 0DH, 0AH, "Enter first digit: $"
    MSG_PROMPT2 DB 0DH, 0AH, "Enter second digit: $"
    MSG_RESULT  DB 0DH, 0AH, "Arithmetic Sum: $"

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
MAIN PROC
    ; --- Step 1: Initialize Data Segment ---
    MOV AX, @DATA
    MOV DS, AX                   
    
    ; --- Step 2: Read First Digit ---
    LEA DX, MSG_PROMPT1             
    MOV AH, 09H                  
    INT 21H                      
    
    MOV AH, 01H                  ; Read Char with Echo
    INT 21H                      
    SUB AL, 30H                  ; ASCII to Numeric
    MOV VAL1, AL                 
    
    ; --- Step 3: Read Second Digit ---
    LEA DX, MSG_PROMPT2             
    MOV AH, 09H                  
    INT 21H                      
    
    MOV AH, 01H                  
    INT 21H                      
    SUB AL, 30H                  ; ASCII to Numeric
    MOV VAL2, AL                 
    
    ; --- Step 4: Addition and ASCII Adjustment ---
    ADD AL, VAL1                 
    MOV AH, 00H                  ; AAA requires AH to be clear
    AAA                          ; ASCII Adjust for Addition
    
    ; Convert BCD digits to ASCII
    ADD AH, 30H                  
    ADD AL, 30H                  
    MOV BX, AX                   ; Save AH=Tens, AL=Ones
    
    ; --- Step 5: Display Result ---
    LEA DX, MSG_RESULT           
    MOV AH, 09H                  
    INT 21H                      
    
    MOV AH, 02H                  
    MOV DL, BH                   ; Print Tens
    INT 21H                      
    
    MOV DL, BL                   ; Print Ones
    INT 21H                      
    
    ; --- Step 6: Shutdown ---
    MOV AH, 4CH                  
    INT 21H                      
MAIN ENDP

END MAIN

; =============================================================================
; TECHNICAL NOTES & ARCHITECTURAL INSIGHTS
; =============================================================================
; 1. ASCII vs NUMERIC:
;    Digit '5' = 35H. To perform mathematical addition, we must subtract 30H 
;    to isolate the binary value 5.
;
; 2. AAA (ASCII ADJUST FOR ADDITION):
;    This instruction is key for Unpacked BCD arithmetic. It checks if the 
;    lower nibble of AL > 9. If so, it adjusts AL and increments AH, 
;    turning a binary result like 0CH (12) into 0102H (12 decimal).
;
; 3. DOS INTERRUPT 21H FUNCTIONS:
;    - AH=01H: Input char from keyboard (returns in AL).
;    - AH=09H: Display string ending in '$'.
;    - AH=02H: Display single char in DL.
;
; 4. UNPACKED BCD:
;    A format where a single byte represents exactly one decimal digit (0-9). 
;    Standard BCD arithmetic instructions (AAA, AAS, AAM, AAD) operate on 
;    this format.
;
; 5. TERMINATION SIGNALS:
;    The '$' character is the mandatory EOL sign for DOS string-printing 
;    functions. Missing it causes the CPU to dump garbage memory to screen.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

