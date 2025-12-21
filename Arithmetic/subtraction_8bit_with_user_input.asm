; =============================================================================
; TITLE: 8-bit Interactive Subtraction with ASCII Adjustment
; DESCRIPTION: This program reads two single-digit decimal numbers from the 
;              keyboard, performs subtraction (Minuend - Subtrahend), and 
;              displays the result. It highlights the use of AAS (ASCII 
;              Adjust for Subtraction) to handle multi-digit borrowing logic 
;              in Unpacked BCD format.
; AUTHOR: Amey Thakur (https://github.com/Amey-Thakur)
; REPOSITORY: https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
; LICENSE: MIT License
; =============================================================================

; -----------------------------------------------------------------------------
; DATA SEGMENT
; -----------------------------------------------------------------------------
DATA SEGMENT
    ; Storage for numeric values
    VAL_MINUEND    DB ?                 ; Number to be subtracted from
    VAL_SUBTRAHEND DB ?                 ; Number to subtract
    VAL_DIFFERENCE DB ?                 ; Resulting difference
    
    ; User Prompts
    PROMPT1  DB 10,13, "Enter the first digit (Minuend): $"
    PROMPT2  DB 10,13, "Enter the second digit (Subtrahend): $"
    MSG_RES  DB 10,13, "The result of (A - B) is: $"
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
    
    ; --- Step 2: Read Minuend ---
    LEA DX, PROMPT1             
    MOV AH, 09H                  ; DOS: Display String
    INT 21H          
    
    MOV AH, 01H                  ; DOS: Read Character (echoed to screen)
    INT 21H
    SUB AL, 30H                  ; Convert ASCII '0'-'9' to raw numeric 0-9
    MOV VAL_MINUEND, AL          
    
    ; --- Step 3: Read Subtrahend ---
    LEA DX, PROMPT2             
    MOV AH, 09H                  
    INT 21H          
    
    MOV AH, 01H                  
    INT 21H
    SUB AL, 30H                  ; Convert ASCII to raw numeric
    MOV VAL_SUBTRAHEND, AL       
    
    ; --- Step 4: Perform Subtraction and Adjustment ---
    ; Logic: 5 (AL) - 7 (VAL_SUBTRAHEND) = -2 (in 8-bit binary: FEH)
    MOV AL, VAL_MINUEND          
    SUB AL, VAL_SUBTRAHEND       
    MOV VAL_DIFFERENCE, AL       
    
    ; AAS (ASCII Adjust for Subtraction) corrects the result.
    ; If a borrow was required (AL < 0 or Low Nibble > 9), AAS sets 
    ; AH to FFH (-1) and clears the Carry Flag.
    MOV AH, 00H                  ; Clear AH for clean adjustment
    AAS                          
    
    ; Prepare for display: Convert digits back to ASCII
    ADD AH, 30H                  ; Borrow indicator / Tens digit
    ADD AL, 30H                  ; Ones digit result
    
    ; --- Step 5: Display the Final Difference ---
    MOV BX, AX                   ; Save result (AH=Tens, AL=Ones)
    
    LEA DX, MSG_RES              
    MOV AH, 09H
    INT 21H
    
    ; Print High Digit (Borrow indicator)
    MOV AH, 02H                  ; DOS: Print Character in DL
    MOV DL, BH                                
    INT 21H
    
    ; Print Low Digit
    MOV AH, 02H                  
    MOV DL, BL
    INT 21H
    
    ; --- Step 6: Shutdown ---
    MOV AH, 4CH
    INT 21H
      
CODE ENDS

; =============================================================================
; TECHNICAL NOTES & ARCHITECTURAL INSIGHTS
; =============================================================================
; 1. SUBTRACTION LOGIC:
;    The CPU performs subtraction by adding the Two's Complement of the 
;    subtrahend.
;    A - B  => A + (NOT B + 1).
;
; 2. AAS (ASCII ADJUST FOR SUBTRACTION):
;    AAS is designed for Unpacked BCD. It checks the lower 4 bits of AL.
;    - If (Low Nibble of AL > 9) OR (AF = 1):
;        AL = AL - 6
;        AH = AH - 1
;        AF = 1, CF = 1
;    - Otherwise:
;        AF = 0, CF = 0
;    - The upper 4 bits of AL are cleared to 0.
;
; 3. BORROW DETECTION:
;    If the first digit is smaller than the second (e.g., 5-7), AAS will 
;    adjust AH to FFH. When converted to ASCII (+30H), this results in 
;    character 2FH (the '/' character), which visually indicates a borrow 
;    in this basic implementation.
;
; 4. UNPACKED BCD BOUNDARIES:
;    Unpacked BCD allows digits to occupy a full byte, but only uses the 
;    bottom nibble. This makes I/O conversion extremely fast compared to 
;    Packed BCD.
;
; 5. INTERRUPT OVERHEAD:
;    INT 21H/AH=01H is a "blocking" call; the CPU sits in an idle loop waiting 
;     for user hardware keyboard events before proceeding.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

END START
