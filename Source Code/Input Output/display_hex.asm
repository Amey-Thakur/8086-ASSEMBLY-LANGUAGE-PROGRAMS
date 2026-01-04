; =============================================================================
; TITLE: Display Hexadecimal Representation
; DESCRIPTION: Converts a 16-bit integer into its Hexadecimal (Base 16) ASCII 
;              string using bitwise rotation and lookup logic.
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
    TEST_VAL    DW 0BEEFH               ; Example Value
    MSG_OUT     DB "Hex Output: 0x$"

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

    ; --- Step 3: Print Hex ---
    MOV AX, TEST_VAL
    MOV BX, AX                          ; Copy to BX
    MOV CX, 4                           ; 4 Nibbles in 16 bits (4x4=16)

L_HEX_LOOP:
    ROL BX, 4                           ; Rotate Left 4 to bring high nibble to low
    MOV DL, BL                          ; Move LOW Byte to DL
    AND DL, 0FH                         ; Mask out High Nibble of DL (0000xxxx)
    
    ; Convert 0-15 to ASCII
    CMP DL, 9
    JG L_LETTER
    ADD DL, '0'
    JMP L_PRINT
    
L_LETTER:
    ADD DL, 'A' - 10                    ; Convert 10-15 to A-F

L_PRINT:
    MOV AH, 02H
    INT 21H
    LOOP L_HEX_LOOP

    ; --- Step 4: Exit ---
    MOV AH, 4CH
    INT 21H
MAIN ENDP
END MAIN

; =============================================================================
; TECHNICAL NOTES & ARCHITECTURAL INSIGHTS
; =============================================================================
; 1. NIBBLE PROCESSING:
;    Hexadecimal maps directly to binary 4-bit chunks (nibbles).
;    - A word has 4 nibbles.
;    - ROL BX, 4 brings the next MS-Nibble to the LS-Nibble position sequentially.
;
; 2. ASCII CONVERSION:
;    - Values 0-9 map to '0'-'9' (0x30-0x39).
;    - Values 10-15 map to 'A'-'F' (0x41-0x46).
;    - 'A' is 65 (0x41). 10 + ('A'-10) = 65 correctly aligns the offset.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
