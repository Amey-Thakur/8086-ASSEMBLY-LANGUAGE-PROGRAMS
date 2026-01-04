; =============================================================================
; TITLE: BIOS Keyboard Input (Raw)
; DESCRIPTION: Reads keyboard input using BIOS Interrupt 16H. This provides
;              access to both ASCII characters and hardware scan codes.
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
    MSG_WAIT    DB "Press any key (BIOS INT 16h)...", 0DH, 0AH, "$"
    MSG_SCAN    DB 0DH, 0AH, "Scan Code (Hex): $"
    MSG_ASCII   DB 0DH, 0AH, "ASCII Code (Hex): $"

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
MAIN PROC
    ; --- Step 1: Initialize DS ---
    MOV AX, @DATA
    MOV DS, AX

    ; --- Step 2: Prompt ---
    LEA DX, MSG_WAIT
    MOV AH, 09H
    INT 21H

    ; --- Step 3: Wait for Key (INT 16h / AH=00h) ---
    ; Returns: AH = Scan Code, AL = ASCII Code
    MOV AH, 00H
    INT 16H
    
    PUSH AX                             ; Save Result

    ; --- Step 4: Print Scan Code (AH) ---
    LEA DX, MSG_SCAN
    MOV AH, 09H
    INT 21H
    
    POP AX                              ; Restore
    PUSH AX                             ; Save Again
    MOV AL, AH                          ; Move Scan Code to AL for printing
    CALL PRINT_HEX_BYTE_PROC

    ; --- Step 5: Print ASCII Code (AL) ---
    LEA DX, MSG_ASCII
    MOV AH, 09H
    INT 21H
    
    POP AX                              ; Restore original AL (ASCII)
    CALL PRINT_HEX_BYTE_PROC

    ; --- Step 6: Exit ---
    MOV AH, 4CH
    INT 21H
MAIN ENDP

; -----------------------------------------------------------------------------
; PROCEDURE: PRINT_HEX_BYTE_PROC
; Input: AL (Byte to print)
; -----------------------------------------------------------------------------
PRINT_HEX_BYTE_PROC PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    
    MOV BL, AL                          ; Save Byte
    
    ; High Nibble
    SHR AL, 4
    CALL PRINT_NIBBLE
    
    ; Low Nibble
    MOV AL, BL
    AND AL, 0FH
    CALL PRINT_NIBBLE
    
    POP DX
    POP CX
    POP BX
    POP AX
    RET
PRINT_HEX_BYTE_PROC ENDP

PRINT_NIBBLE PROC
    CMP AL, 9
    JG L_HEX
    ADD AL, '0'
    JMP L_OUT
L_HEX:
    ADD AL, 'A' - 10
L_OUT:
    MOV DL, AL
    MOV AH, 02H
    INT 21H
    RET
PRINT_NIBBLE ENDP

END MAIN

; =============================================================================
; TECHNICAL NOTES & ARCHITECTURAL INSIGHTS
; =============================================================================
; 1. BIOS VS DOS KEYBOARD:
;    - DOS (INT 21h) is higher level, handles CTRL-C, and often echoes output.
;    - BIOS (INT 16h) is raw. It returns the Hardware Scan Code (Physical Key) 
;      and the ASCII translation.
;
; 2. SCAN CODES:
;    Useful for games or detecting non-ASCII keys (Arrows, F1-F12, etc.).
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
