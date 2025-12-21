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

; -----------------------------------------------------------------------------
; DATA SEGMENT
; -----------------------------------------------------------------------------
DATA SEGMENT
    ; Variables for storing numeric values
    VAL1 DB ?                           ; First number storage
    VAL2 DB ?                           ; Second number storage
    RES  DB ?                           ; Sum storage
    
    ; Display Strings (ASCII 10,13 = New Line and Carriage Return)
    PROMPT1 DB 10,13, "Enter the first single-digit number: $"
    PROMPT2 DB 10,13, "Enter the second single-digit number: $"
    RESULT_MSG DB 10,13, "The sum of the digits is: $"
DATA ENDS   

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
CODE SEGMENT
    ASSUME CS:CODE, DS:DATA

START: 
    ; --- Step 1: Initialize Data Segment ---
    MOV AX, DATA
    MOV DS, AX                   
    
    ; --- Step 2: Read First Digit ---
    ; Display Prompt 1
    LEA DX, PROMPT1             
    MOV AH, 09H                  ; DOS Function: Print String
    INT 21H                      
    
    ; Get Input 1
    MOV AH, 01H                  ; DOS Function: Read Char with Echo
    INT 21H                      ; Character returned in AL
    
    ; ASCII Conversion: '0' is 30H, '9' is 39H.
    ; Subtracting 30H converts the ASCII character to its raw numeric value.
    SUB AL, 30H                  
    MOV VAL1, AL                 
    
    ; --- Step 3: Read Second Digit ---
    ; Display Prompt 2
    LEA DX, PROMPT2             
    MOV AH, 09H                  
    INT 21H                      
    
    ; Get Input 2
    MOV AH, 01H                  
    INT 21H                      
    
    ; Convert Second Input to Numeric
    SUB AL, 30H                  
    MOV VAL2, AL                 
    
    ; --- Step 4: Perform Addition and ASCII Adjustment ---
    ; Add the two numbers in binary.
    ; If Input1=5 and Input2=7, AL becomes 12 (0CH).
    ADD AL, VAL1                 
    MOV RES, AL                  
    
    ; AAA (ASCII Adjust for Addition) works on AL.
    ; It checks if the lower nibble of AL > 9.
    ; If it is, it adds 6 to AL and 1 to AH.
    ; Effectively: 0CH -> AH=01 (Tens), AL=02 (Ones).
    MOV AH, 00H                  ; AAA requires AH to be clear or consistent
    AAA                          
    
    ; Convert the adjusted BCD digits back to ASCII by adding 30H.
    ADD AH, 30H                  ; Tens digit to ASCII
    ADD AL, 30H                  ; Ones digit to ASCII
    
    ; --- Step 5: Display the Final Result ---
    MOV BX, AX                   ; Save result (AH=Tens, AL=Ones) in BX
    
    ; Display result header message
    LEA DX, RESULT_MSG           
    MOV AH, 09H                  
    INT 21H                      
    
    ; Print Tens Digit (e.g., '1')
    MOV AH, 02H                  ; DOS Function: Print Character
    MOV DL, BH                   
    INT 21H                      
    
    ; Print Ones Digit (e.g., '2')
    MOV AH, 02H                  
    MOV DL, BL                   
    INT 21H                      
    
    ; --- Step 6: Finalize Program ---
    MOV AH, 4CH                  
    INT 21H                      
      
CODE ENDS

; =============================================================================
; TECHNICAL NOTES & ARCHITECTURAL INSIGHTS
; =============================================================================
; 1. ASCII vs NUMERIC:
;    Humans use ASCII (American Standard Code for Information Interchange).
;    - Digit '5' = 35H (53 decimal).
;    - To do math, we must "strip" the 30H offset to get the raw value 5.
;
; 2. AAA (ASCII ADJUST FOR ADDITION):
;    AAA is a specialized instruction for Unpacked BCD arithmetic.
;    - It looks at the lower 4 bits of AL.
;    - If it reflects a value > 9, AL = AL + 6, AH = AH + 1, and AF/CF are set.
;    - This turns a binary sum like 0CH (12) into 0102H (Unpacked BCD for 12).
;
; 3. DOS INTERRUPT 21H FUNCTIONS:
;    - AH=01H: Wait for keypress, echo to screen, return char in AL.
;    - AH=02H: Output the single character in DL to the screen.
;    - AH=09H: Output the string pointed to by DS:DX until '$' is reached.
;    - AH=4CH: Return control to the operating system (terminate).
;
; 4. STRING TERMINATION:
;    Note the '$' at the end of all data messages. This is the mandatory 
;    terminator for the AH=09H display function.
;
; 5. UNPACKED BCD:
;    The format where each byte contains exactly one decimal digit in the 
;    lower 4 bits, while the upper 4 bits are typically zero (but ignored).
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

END START
