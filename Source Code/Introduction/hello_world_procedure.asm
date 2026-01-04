; =============================================================================
; TITLE: Hello World Procedure
; DESCRIPTION: Demonstrate string printing by passing a string address to a
;              custom procedure called 'PRINT_ME'.
; AUTHOR: Amey Thakur (https://github.com/Amey-Thakur)
; REPOSITORY: https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
; LICENSE: MIT License
; =============================================================================

ORG 100H                            ; COM file entry point

; -----------------------------------------------------------------------------
; MAIN CODE SECTION
; -----------------------------------------------------------------------------
START:
    LEA SI, MSG                     ; Load Effective Address of the string
    CALL PRINT_ME                   ; Call our custom print procedure

    RET                             ; Return to OS

; -----------------------------------------------------------------------------
; PROCEDURE: PRINT_ME
; Description: Prints a null-terminated string (ending with 0).
; Input: SI = Address of the string
; -----------------------------------------------------------------------------
PRINT_ME PROC
    
NEXT_CHAR:
    ; Check for null terminator (0) to stop
    CMP BYTE PTR [SI], 0            ; Compare byte at SI with 0
    JE STOP                         ; If zero, we reached the end
    
    MOV AL, [SI]                    ; Load current ASCII character into AL
    
    ; Display character using BIOS teletype sub-function
    MOV AH, 0EH                     ; BIOS TTY function number
    INT 10H                         ; Call Video Interrupt
    
    INC SI                          ; Move to next character address (SI + 1)
    
    JMP NEXT_CHAR                   ; Loop for next byte
    
STOP:
    RET                             ; Return to caller
PRINT_ME ENDP

; -----------------------------------------------------------------------------
; DATA SECTION
; -----------------------------------------------------------------------------
MSG DB 'Hello World!', 0            ; Null-terminated string

END

; =============================================================================
; TECHNICAL NOTES
; =============================================================================
; 1. STRING PRINTING:
;    - This method uses a custom loop instead of DOS service 09h.
;    - Advantages: Can use any terminator (like 0) instead of restricted '$'.
;    - INT 10h/AH=0Eh provides portable teletype character printing.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
