; =============================================================================
; TITLE: Palindrome String Check
; DESCRIPTION: A program to determine if a given string is a palindrome using 
;              bi-directional pointers (beginning and end).
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
    STR1        DB 'MADAM', '$'
    LEN         EQU 5            ; Length of the string
    
    MSG_YES     DB 'String is a Palindrome$', 0DH, 0AH, '$'
    MSG_NO      DB 'String is NOT a Palindrome$', 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
MAIN PROC
    ; Initialize Data Segment
    MOV AX, @DATA
    MOV DS, AX
    
    ; Setup bi-directional pointers
    LEA SI, STR1          ; SI points to the start of the string
    LEA DI, STR1          ; DI will point to the end of the string
    ADD DI, LEN - 1       ; Adjust DI to point to the last character
    
    ; Loop for half the length of the string
    MOV CX, LEN / 2
    
CHECK_LOOP:
    MOV AL, [SI]          ; Load character from the beginning
    MOV BL, [DI]          ; Load character from the end
    
    CMP AL, BL            ; Compare characters
    JNE NOT_PALINDROME    ; If not equal, it's not a palindrome
    
    INC SI                ; Move start pointer forward
    DEC DI                ; Move end pointer backward
    LOOP CHECK_LOOP       ; Repeat until center reached
    
    ; If loop finishes, it's a palindrome
    LEA DX, MSG_YES
    JMP DISPLAY
    
NOT_PALINDROME:
    LEA DX, MSG_NO
    
DISPLAY:
    ; Use DOS function 09H to print the string
    MOV AH, 09H
    INT 21H
    
    ; Terminate the program
    MOV AH, 4CH
    INT 21H
MAIN ENDP
END MAIN

; =============================================================================
; TECHNICAL NOTES
; =============================================================================
; 1. PALINDROME LOGIC:
;    - A string is a palindrome if it reads the same forwards and backwards.
;    - This program uses a two-pointer approach (SI and DI).
;    - Complexity: O(N/2), as we only need to compare up to the midpoint.
;    - This implementation is case-sensitive (e.g., 'Madam' != 'MADAM').
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
