; =============================================================================
; TITLE: String Reverse
; DESCRIPTION: A program to reverse a string in-place using two-pointer 
;              swap logic (SI and DI).
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
    STR1    DB 'ASSEMBLY', '$'
    LEN     EQU 8             ; Constant defined for string length
    
    NEWLINE DB 0DH, 0AH, '$' ; String for carriage return and line feed
    MSG1    DB 'Original: $'
    MSG2    DB 'Reversed: $'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
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
    
    ; Print a newline
    LEA DX, NEWLINE
    MOV AH, 09H
    INT 21H
    
    ; --- String Reversal Logic ---
    ; We use SI as a pointer to the start and DI as a pointer to the end.
    LEA SI, STR1          ; SI points to index 0
    LEA DI, STR1
    ADD DI, LEN - 1       ; DI points to index [LEN-1]
    
    ; We only need to loop for half the length
    MOV CX, LEN / 2
    
REVERSE_LOOP:
    ; Swap characters at SI and DI using registers AL and BL
    MOV AL, [SI]          ; Temporarily store [SI] in AL
    MOV BL, [DI]          ; Temporarily store [DI] in BL
    
    MOV [SI], BL          ; Move character from DI to SI position
    MOV [DI], AL          ; Move character from AL (old SI) to DI position
    
    INC SI                ; Move start pointer forward
    DEC DI                ; Move end pointer backward
    LOOP REVERSE_LOOP     ; Decrement CX and repeat if CX != 0
    
    ; --- Output the Result ---
    
    ; Display "Reversed: " message
    LEA DX, MSG2
    MOV AH, 09H
    INT 21H
    
    ; Display the now-reversed string
    LEA DX, STR1
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
; 1. IN-PLACE SWAP:
;    - This program modifies the original memory buffer of STR1.
;    - It is O(1) space complexity.
; 2. TWO-POINTER TECHNIQUE:
;    - SI (Source Index) and DI (Destination Index) work symmetrically.
;    - Loop runs N/2 times. If N is odd, the middle char is untouched.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
