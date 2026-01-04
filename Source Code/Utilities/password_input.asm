; =============================================================================
; TITLE: Secure Password Input with Masking
; DESCRIPTION: A program that reads a password from the keyboard without 
;              echoing it, displaying asterisks instead for privacy.
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
    PROMPT          DB 'Enter password: $'
    CORRECT_PASS    DB 'secret', 0 ; The predefined correct password
    PASS_LEN        EQU 6
    
    ; Buffer to store user input
    INPUT_PASS      DB 20 DUP(0)
    
    MSG_CORRECT     DB 0DH, 0AH, 'Access Granted!$', 0DH, 0AH, '$'
    MSG_WRONG       DB 0DH, 0AH, 'Access Denied!$', 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
MAIN PROC
    ; Initialize the Data Segment
    MOV AX, @DATA
    MOV DS, AX
    
    ; Display password prompt
    LEA DX, PROMPT
    MOV AH, 09H
    INT 21H
    
    ; Setup pointers and counter
    LEA DI, INPUT_PASS   ; DI will point to the input buffer
    XOR CX, CX           ; CX tracks the number of characters entered
    
READ_LOOP:
    ; --- Secure Input Read ---
    ; DOS Interrupt 21H, AH=07H: Direct Character Input without Echo
    ; This function waits for a keypress and returns the character in AL without printing it.
    MOV AH, 07H      
    INT 21H
    
    CMP AL, 0DH          ; Check if 'Enter' key (0DH) was pressed
    JE CHECK_PASS        ; If yes, proceed to verification
    
    CMP AL, 08H          ; Check if 'Backspace' (08H) was pressed
    JE HANDLE_BACKSPACE  
    
    ; --- Store and Mask Character ---
    MOV [DI], AL         ; Store the real character in the buffer
    INC DI
    INC CX               ; Increment character count
    
    ; Print an asterisk '*' to indicate a key was pressed
    MOV DL, '*'
    MOV AH, 02H
    INT 21H
    
    ; Check for buffer limit (prevent overflow)
    CMP CX, 19       
    JL READ_LOOP
    JMP CHECK_PASS
    
HANDLE_BACKSPACE:
    CMP CX, 0            ; If no characters entered, ignore backspace
    JE READ_LOOP
    
    DEC DI               ; Move buffer pointer back
    DEC CX               ; Decrement count
    
    ; --- Visual Backspace ---
    ; To truly "erase" the asterisk from the screen:
    ; 1. Move cursor back (DL=08H)
    ; 2. Print space over character (DL=' ')
    ; 3. Move cursor back again (DL=08H)
    MOV DL, 08H
    MOV AH, 02H
    INT 21H              ; Back cursor
    MOV DL, ' '
    INT 21H              ; Print space
    MOV DL, 08H
    INT 21H              ; Back cursor again
    JMP READ_LOOP
    
CHECK_PASS:
    MOV BYTE PTR [DI], 0 ; Null-terminate the input string for comparison
    
    ; --- String Comparison Logic ---
    LEA SI, CORRECT_PASS ; Pointer to known password
    LEA DI, INPUT_PASS   ; Pointer to user input
    
COMPARE_LOOP:
    MOV AL, [SI]
    MOV BL, [DI]
    CMP AL, BL           ; Compare bytes
    JNE ACCESS_DENIED    ; If any byte differs, fail fast
    
    CMP AL, 0            ; Check for null terminator
    JE ACCESS_GRANTED    ; If both are null, strings match perfectly
    
    INC SI
    INC DI
    JMP COMPARE_LOOP
    
ACCESS_GRANTED:
    LEA DX, MSG_CORRECT
    JMP DISPLAY_RESULT
    
ACCESS_DENIED:
    LEA DX, MSG_WRONG
    
DISPLAY_RESULT:
    ; Use AH=09H to display the final message
    MOV AH, 09H
    INT 21H
    
    ; Clean termination
    MOV AH, 4CH
    INT 21H
MAIN ENDP
END MAIN

; =============================================================================
; TECHNICAL NOTES
; =============================================================================
; 1. SECURITY (NO-ECHO): 
;    - AH=07H or AH=08H is standard for reading secrets.
;    - AH=01H automatically prints the key to the screen.
; 2. VISUAL MASKING: 
;    - Printing '*' provides user feedback without exposing data.
; 3. BACKSPACE HANDLING: 
;    - Requires pointer manipulation + "back-space-back" terminal sequence.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
