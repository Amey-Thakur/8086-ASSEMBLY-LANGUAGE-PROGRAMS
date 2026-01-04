; =============================================================================
; TITLE: Hello World Procedure (Advanced)
; DESCRIPTION: Refined version of the string-printing procedure demonstration, 
;              focusing on the use of SI as a source pointer and null-termination.
; AUTHOR: Amey Thakur (https://github.com/Amey-Thakur)
; REPOSITORY: https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
; LICENSE: MIT License
; =============================================================================

ORG 100H                            ; COM file entry point

; -----------------------------------------------------------------------------
; MAIN CODE SECTION
; -----------------------------------------------------------------------------
START:
    ; Load the memory address of the string into the Source Index register
    LEA SI, MSG                     
    
    ; Execute the print routine
    CALL PRINT_STRING               

    RET                             ; Standard COM exit

; -----------------------------------------------------------------------------
; PROCEDURE: PRINT_STRING
; Description: Iteratively prints characters from the address in SI until
;               a binary zero (null) is encountered.
; -----------------------------------------------------------------------------
PRINT_STRING PROC
    
CHARACTER_LOOP:
        ; Check if the byte at the current SI address is 0
        CMP BYTE PTR [SI], 0       
        JE FINISHED                 ; Exit loop if null terminator found
        
        MOV AL, [SI]                ; Fetch ASCII char into AL
        
        ; Using BIOS Video TTY Service
        MOV AH, 0EH                 
        INT 10H                     
        
        INC SI                      ; Point to next memory location
        
        JMP CHARACTER_LOOP          ; Continue to next character
      
FINISHED:
    RET                             ; Pop return address and jump back
PRINT_STRING ENDP

; -----------------------------------------------------------------------------
; DATA SECTION
; -----------------------------------------------------------------------------
MSG DB 'Hello World!', 0            ; The string to be printed

END

; =============================================================================
; TECHNICAL NOTES
; =============================================================================
; 1. POINTERS:
;    - 'BYTE PTR' is used to tell the assembler we are comparing a single byte.
;    - This pattern is common in C-style string processing.
;    - SI (Source Index) is the standard register for scanning memory data.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
