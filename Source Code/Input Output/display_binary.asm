; =============================================================================
; TITLE: Display Binary Representation
; DESCRIPTION: Converts a 16-bit integer into its 8-bit or 16-bit Binary ASCII 
;              string and displays it on the console.
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
    TEST_VAL    DW 1010101011000011B    ; Example Value (AA C3)
    MSG_OUT     DB "Binary Output: $"

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
MAIN PROC
    ; --- Step 1: Initialize DS ---
    MOV AX, @DATA
    MOV DS, AX

    ; --- Step 2: Display Header ---
    LEA DX, MSG_OUT
    MOV AH, 09H
    INT 21H

    ; --- Step 3: Print Binary ---
    MOV AX, TEST_VAL
    MOV CX, 16                          ; Loop 16 times (for 16-bit word)

L_PRINT_BIT:
    ROL AX, 1                           ; Rotate Left: MSB moves to Carry Flag
    JC L_ONE
    
    PUSH AX                             ; Save AX (Rotated Value)
    MOV DL, '0'
    JMP L_DISPLAY

L_ONE:
    PUSH AX
    MOV DL, '1'

L_DISPLAY:
    MOV AH, 02H                         ; DOS Print Char
    INT 21H
    POP AX                              ; Restore AX
    
    LOOP L_PRINT_BIT                    ; Decrement CX, Jump if not 0

    ; --- Step 4: Exit ---
    MOV AH, 4CH
    INT 21H
MAIN ENDP
END MAIN

; =============================================================================
; TECHNICAL NOTES & ARCHITECTURAL INSIGHTS
; =============================================================================
; 1. BIT EXTRACTION:
;    - ROL (Rotate Left) shifts the Most Significant Bit (MSB) into the Carry 
;      Flag (CF) and also wraps it around to the LSB.
;    - This preserves the number after 16 rotations (unlike SHL which destroys 
;      bits).
;
; 2. DISPLAY LOGIC:
;    We iterate 16 times for a DW (Word) or 8 times for a DB (Byte).
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
