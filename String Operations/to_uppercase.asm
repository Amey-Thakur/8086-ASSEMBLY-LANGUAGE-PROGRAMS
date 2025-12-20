; TITLE: String to Uppercase Conversion
; DESCRIPTION: A program that iterates through a string and converts all lowercase characters (a-z) to uppercase (A-Z).
; AUTHOR: Amey Thakur (https://github.com/Amey-Thakur)
; REPOSITORY: https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
; LICENSE: MIT License

.MODEL SMALL
.STACK 100H

.DATA
    ; Source string with mixed or lowercase letters
    STR1 DB 'hello world', '$'
    
    NEWLINE DB 0DH, 0AH, '$' ; String for carriage return and line feed
    MSG1 DB 'Original: $'
    MSG2 DB 'Uppercase: $'

.CODE
MAIN PROC
    ; Initialize the Data Segment
    MOV AX, @DATA
    MOV DS, AX
    
    ; Display "Original: " message
    LEA DX, MSG1
    MOV AH, 09H
    INT 21H
    
    ; Display the original string
    LEA DX, STR1
    MOV AH, 09H
    INT 21H
    
    ; Print a newline for better formatting
    LEA DX, NEWLINE
    MOV AH, 09H
    INT 21H
    
    ; --- Case Conversion Logic ---
    LEA SI, STR1          ; SI points to the start of the string
    
CONVERT_LOOP:
    MOV AL, [SI]          ; Load current character into AL
    CMP AL, '$'           ; Check if it is the terminator character
    JE DISPLAY            ; If yes, we are done
    
    ; Range Check: Only convert characters between 'a' (61H) and 'z' (7AH)
    CMP AL, 'a'           
    JB NEXT               ; If less than 'a', skip
    CMP AL, 'z'
    JA NEXT               ; If greater than 'z', skip
    
    ; Conversion: SUB 20H to convert Lower to Upper
    ; 'a' is 61H (0110 0001)
    ; 'A' is 41H (0100 0001)
    SUB AL, 20H           
    MOV [SI], AL          ; Update the character in memory
    
NEXT:
    INC SI                ; Move to the next memory location
    JMP CONVERT_LOOP      ; Repeat for the next character
    
DISPLAY:
    ; Display "Uppercase: " message
    LEA DX, MSG2
    MOV AH, 09H
    INT 21H
    
    ; Display the modified string
    LEA DX, STR1
    MOV AH, 09H
    INT 21H
    
    ; Clean termination
    MOV AH, 4CH           
    INT 21H
MAIN ENDP

; =============================================================================
; NOTES:
; 1. ASCII RELATIONSHIP: Uppercase and lowercase letters in ASCII differ by 
;    exactly 32 (20H). Bit 5 (the "32" bit) is 1 for Lower and 0 for Upper.
; 2. LOGIC: SUB AL, 20H is equivalent to AND AL, 11011111B. It effectively 
;    forces the 5th bit to be cleared.
; 3. RANGE VALIDATION: It is critical to check if the character is actually 
;    within 'a'-'z' to avoid corrupting symbols, numbers, or already uppercase chars.
; 4. IN-PLACE MODIFICATION: This program modifies the string directly in the 
;    Data Segment buffer.
; =============================================================================

END MAIN
