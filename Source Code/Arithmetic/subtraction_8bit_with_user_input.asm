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

.MODEL SMALL
.STACK 100H

; -----------------------------------------------------------------------------
; DATA SEGMENT
; -----------------------------------------------------------------------------
.DATA
    VAL_MINUEND    DB ?                 
    VAL_SUBTRAHEND DB ?                 
    VAL_DIFFERENCE DB ?                 
    
    ; User Prompts
    MSG_PROMPT1  DB 0DH, 0AH, "Enter minuend: $"
    MSG_PROMPT2  DB 0DH, 0AH, "Enter subtrahend: $"
    MSG_RESULT   DB 0DH, 0AH, "Result (A - B): $"

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
MAIN PROC
    ; --- Step 1: Initialize Data Segment ---
    MOV AX, @DATA
    MOV DS, AX                   
    
    ; --- Step 2: Read Minuend ---
    LEA DX, MSG_PROMPT1             
    MOV AH, 09H                  
    INT 21H          
    
    MOV AH, 01H                  
    INT 21H
    SUB AL, 30H                  
    MOV VAL_MINUEND, AL          
    
    ; --- Step 3: Read Subtrahend ---
    LEA DX, MSG_PROMPT2             
    MOV AH, 09H                  
    INT 21H          
    
    MOV AH, 01H                  
    INT 21H
    SUB AL, 30H                  
    MOV VAL_SUBTRAHEND, AL       
    
    ; --- Step 4: Subtraction and Adjustment ---
    MOV AL, VAL_MINUEND          
    SUB AL, VAL_SUBTRAHEND       
    MOV AH, 00H                  
    AAS                          ; ASCII Adjust for Subtraction
    
    ; Prepare for display
    ADD AH, 30H                  ; Borrow indicator / Tens digit
    ADD AL, 30H                  ; Ones digit
    MOV BX, AX                   
    
    ; --- Step 5: Display Result ---
    LEA DX, MSG_RESULT              
    MOV AH, 09H
    INT 21H
    
    MOV AH, 02H                  
    MOV DL, BH                                
    INT 21H
    
    MOV DL, BL
    INT 21H
    
    ; --- Step 6: Shutdown ---
    MOV AH, 4CH
    INT 21H
MAIN ENDP

END MAIN

; =============================================================================
; TECHNICAL NOTES & ARCHITECTURAL INSIGHTS
; =============================================================================
; 1. SUBTRACTION LOGIC:
;    The CPU performs subtraction by adding the Two's Complement of the 
;    subtrahend.
;
; 2. AAS (ASCII ADJUST FOR SUBTRACTION):
;    Checks the lower 4 bits of AL. If bit 4 borrow occurred (AF=1) or 
;    digit > 9, it subtracts 6 from AL and 1 from AH.
;
; 3. BORROW DETECTION:
;    If the first digit is smaller than the second (e.g., 5-7), AAS adjusts 
;    AH to FFH. When converted to ASCII (+30H), this results in character 
;    2FH ('/'), signaling a negative wrap.
;
; 4. UNPACKED BCD:
;    A format where one digit occupies a full byte. Highly efficient 
;    for character-based I/O.
;
; 5. INTERRUPT OVERHEAD:
;    INT 21H/AH=01H is a blocking call; the CPU sits in an idle loop waiting 
;    for keyboard input.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
