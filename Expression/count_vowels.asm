; =============================================================================
; TITLE: Vowel Counter (String Analysis)
; DESCRIPTION: Scans a string and counts the total number of vowels 
;              (A, E, I, O, U), case-insensitive. Demonstrates string traversal 
;              and conditional logic chains.
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
    TARGET_STR DB 0DH, 0AH, "The Quick Brown Fox Jumped Over The Lazy Dog$"
    MSG_RES    DB 0DH, 0AH, "Total Vowels Found: $"
    COUNT      DB 0

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
MAIN PROC
    ; --- Step 1: Initialize Data Segment ---
    MOV AX, @DATA
    MOV DS, AX
    
    ; --- Step 2: Show Input String ---
    LEA DX, TARGET_STR
    MOV AH, 09H
    INT 21H
    
    ; --- Step 3: Analysis Loop ---
    LEA SI, TARGET_STR
    MOV BL, 0                           ; Counter
    
SCAN_LOOP:
    MOV AL, [SI]
    CMP AL, '$'                         ; Check for Terminator
    JE SCAN_DONE
    
    ; Check Vowels (Case Insensitive)
    ; A/a
    CMP AL, 'A'
    JE INC_COUNT
    CMP AL, 'a'
    JE INC_COUNT
    
    ; E/e
    CMP AL, 'E'
    JE INC_COUNT
    CMP AL, 'e'
    JE INC_COUNT
    
    ; I/i
    CMP AL, 'I'
    JE INC_COUNT
    CMP AL, 'i'
    JE INC_COUNT
    
    ; O/o
    CMP AL, 'O'
    JE INC_COUNT
    CMP AL, 'o'
    JE INC_COUNT
    
    ; U/u
    CMP AL, 'U'
    JE INC_COUNT
    CMP AL, 'u'
    JE INC_COUNT
    
    JMP NEXT_CHAR

INC_COUNT:
    INC BL

NEXT_CHAR:
    INC SI
    JMP SCAN_LOOP
    
SCAN_DONE:
    MOV COUNT, BL
    
    ; --- Step 4: Display Result ---
    LEA DX, MSG_RES
    MOV AH, 09H
    INT 21H
    
    ; Print 2-digit number (Count < 100 assumed)
    MOV AL, COUNT
    AAM                                 ; ASCII Adjust for Multiply (Splits AL into AH:AL)
                                        ; Actually, splits AL/10 -> AH=Tens, AL=Units
    
    ADD AX, 3030H                       ; Convert both to ASCII
    MOV CX, AX                          ; Save
    
    MOV DL, CH                          ; Print Tens
    MOV AH, 02H
    INT 21H
    
    MOV DL, CL                          ; Print Units
    MOV AH, 02H
    INT 21H
    
    ; --- Step 5: Exit ---
    MOV AH, 4CH
    INT 21H
MAIN ENDP

END MAIN

; =============================================================================
; TECHNICAL NOTES & ARCHITECTURAL INSIGHTS
; =============================================================================
; 1. STRING TERMINATION:
;    The loop relies on the '$' terminator used by DOS INT 21H/09H. 
;    Scanning continues until this sentinel value is found.
;
; 2. CASE SENSITIVITY:
;    Assembly characters are just byte values. 'A' (65) is not 'a' (97). 
;    We must check both unless we convert the entire string to one case first.
;
; 3. AAM INSTRUCTION:
;    AAM is typically used after multiplication, but it effectively divides 
;    AL by 10 and stores Quotient in AH, Remainder in AL.
;    It is a neat trick for splitting a 2-digit decimal number for printing.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
