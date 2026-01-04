; =============================================================================
; TITLE: String Length Calculation
; DESCRIPTION: A program to calculate the length of a '$' terminated string 
;              in 8086 Assembly.
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
    STR1    DB 'Hello World', '$'
    LEN     DB ?              ; Variable to store the calculated length
    
    MSG     DB 'Length: $'    ; Descriptive message for output

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
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
END MAIN

; =============================================================================
; TECHNICAL NOTES
; =============================================================================
; 1. TERMINATION:
;    - In 8086 DOS programming, '$' is the standard terminator for INT 21H/09H.
;    - This program scans specifically for '$'.
; 2. OPTIMIZATION:
;    - XOR CX, CX is a standard idiom to zero out a register efficiently.
; 3. LIMITATION:
;    - Calculating and displaying multi-digit numbers requires a separate routine
;      (dividing by 10 repeatedly), which is omitted here for simplicity.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
