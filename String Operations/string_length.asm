; TITLE: String Length Calculation
; DESCRIPTION: A program to calculate the length of a '$' terminated string in 8086 Assembly.
; AUTHOR: Amey Thakur (https://github.com/Amey-Thakur)
; REPOSITORY: https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
; LICENSE: MIT License

.MODEL SMALL
.STACK 100H

.DATA
    ; Input string (must be terminated with '$' for this logic)
    STR1 DB 'Hello World', '$'
    LEN DB ?              ; Variable to store the calculated length
    
    MSG DB 'Length: $'    ; Descriptive message for output

.CODE
MAIN PROC
    ; Initialize the Data Segment
    MOV AX, @DATA
    MOV DS, AX
    
    ; Load the effective address of the string into SI
    LEA SI, STR1
    XOR CX, CX            ; Initialize counter CX = 0
    
COUNT_LOOP:
    MOV AL, [SI]          ; Load the current character into AL
    CMP AL, '$'           ; Check if it is the terminator character '$'
    JE DONE               ; If terminator reached, jump to DONE
    
    INC CX                ; Increment the character counter
    INC SI                ; Move SI to point to the next character
    JMP COUNT_LOOP        ; Continue the loop
    
DONE:
    MOV LEN, CL           ; Store the lower byte of the count (length) in LEN
    
    ; Display the "Length: " message
    LEA DX, MSG
    MOV AH, 09H
    INT 21H
    
    ; Display the calculated length as a single digit
    ; Note: This simple display only works for lengths 0-9
    MOV DL, CL
    ADD DL, 30H           ; Convert numeric value to ASCII ('0' = 30H)
    MOV AH, 02H           ; DOS function to display a single character
    INT 21H
    
    ; Clean termination
    MOV AH, 4CH           ; DOS function: Exit to DOS
    INT 21H
MAIN ENDP

; =============================================================================
; NOTES:
; 1. STRING TERMINATION: In 8086 DOS programming, '$' is the standard string 
;    terminator used by INT 21H, AH=09H. This program scans for '$' to find length.
; 2. XOR CX, CX: Using XOR is a common and efficient way to zero out a register
;    compared to 'MOV CX, 0', as it is typically a smaller and faster instruction.
; 3. ASCII CONVERSION: To display a number as a character, we add 30H (48).
;    E.g., 5 + 30H = 35H, which is the ASCII code for '5'.
; 4. LIMITATION: This program's display logic handles lengths only up to 9. 
;    For larger strings, a more complex number-to-string conversion is needed.
; =============================================================================

END MAIN
