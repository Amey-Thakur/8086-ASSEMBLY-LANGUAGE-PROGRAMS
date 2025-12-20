;=============================================================================
; Program:     Memory Search (Scan)
; Description: Search for the first occurrence of a specific byte within 
;              a memory block using the SCASB (Scan String Byte) instruction.
; 
; Author:      Amey Thakur
; Repository:  https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
; License:     MIT License
;=============================================================================

.MODEL SMALL
.STACK 100H

;-----------------------------------------------------------------------------
; DATA SEGMENT
;-----------------------------------------------------------------------------
.DATA
    BUFFER DB 10, 20, 30, 40, 50, 60, 70, 80, 90, 100
    B_LEN  EQU 10
    TARGET DB 50                         ; Value to look for
    
    MSG_FOUND DB 'Value located! 1-based index position: $'
    MSG_FAIL  DB 'Value not found in the provided memory block.$'

;-----------------------------------------------------------------------------
; CODE SEGMENT
;-----------------------------------------------------------------------------
.CODE
MAIN PROC
    ; Segment registers
    MOV AX, @DATA
    MOV DS, AX
    MOV ES, AX                          ; ES is required for SCASB
    
    ;-------------------------------------------------------------------------
    ; STRING SCAN SETUP
    ; Pointer: ES:DI
    ; Search Criteria: AL
    ;-------------------------------------------------------------------------
    LEA DI, BUFFER
    MOV AL, TARGET
    MOV CX, B_LEN                       ; Max bytes to scan
    
    CLD                                 ; Increment DI
    
    ; REPNE SCASB: Repeat 'Scan String Byte' While Not Equal AND CX > 0
    ; Compares AL with ES:[DI] and updates flags.
    REPNE SCASB
    
    ; Logic check: If ZF is set, it means a match was found.
    JNE NOT_FOUND
    
    ; Calculate the 1-based position:
    ; (Original Length - Remaining CX)
    MOV AX, B_LEN
    SUB AX, CX                          ; Correct index calculation
    
    ; Print success label
    PUSH AX                             ; Save index
    LEA DX, MSG_FOUND
    MOV AH, 09H
    INT 21H
    POP AX                              ; Restore index
    
    ; Convert numeric position in AL to ASCII and print (assumes index < 10)
    ADD AL, '0'
    MOV DL, AL
    MOV AH, 02H                         ; DOS: Print char
    INT 21H
    JMP EXIT_SUCCESS
    
NOT_FOUND:
    LEA DX, MSG_FAIL
    MOV AH, 09H
    INT 21H
    
EXIT_SUCCESS:
    ; Terminate
    MOV AH, 4CH
    INT 21H
MAIN ENDP
END MAIN

;=============================================================================
; MEMORY SCAN NOTES:
; - SCASB is the basis for the 'strchr' or 'memchr' functions in high-level
;   languages.
; - Since SCASB increments DI *after* a match is found, the CX register
;   contains (Remaining - 1). The formula (Limit - CX) gives the match position.
;=============================================================================
