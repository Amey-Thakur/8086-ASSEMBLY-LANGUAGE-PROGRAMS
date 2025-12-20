;=============================================================================
; Program:     BIOS Keyboard Input
; Description: Read keyboard input using BIOS Interrupt 16H. This provides
;              access to both ASCII characters and hardware scan codes.
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
    MSG1 DB 'Press any key (no echo): $'
    MSG2 DB 0DH, 0AH, 'Scan code (hardware): $'
    MSG3 DB 0DH, 0AH, 'ASCII code (character): $'

;-----------------------------------------------------------------------------
; CODE SEGMENT
;-----------------------------------------------------------------------------
.CODE
MAIN PROC
    ; Initialize Data Segment
    MOV AX, @DATA
    MOV DS, AX
    
    ; Display prompt to user
    LEA DX, MSG1
    MOV AH, 09H                         ; DOS: display string
    INT 21H
    
    ;-------------------------------------------------------------------------
    ; WAIT FOR KEYSTOKE (INT 16H, AH=00H)
    ; This function stops program execution until a key is pressed.
    ; Returns: AH = BIOS Scan Code (Keyboard position)
    ;          AL = ASCII Character
    ;-------------------------------------------------------------------------
    MOV AH, 00H                         ; BIOS service: keyboard read
    INT 16H
    
    PUSH AX                             ; Save both AH and AL for later
    
    ; Print Scan Code label
    LEA DX, MSG2
    MOV AH, 09H
    INT 21H
    
    ; Print Scan Code as Hex
    POP AX                              ; Retrieve AX
    PUSH AX                             ; Re-save it
    MOV AL, AH                          ; Work with AH (scan code)
    CALL PRINT_HEX_BYTE
    
    ; Print ASCII Code label
    LEA DX, MSG3
    MOV AH, 09H
    INT 21H
    
    ; Print ASCII Code as Hex
    POP AX                              ; Retrieve AX
    CALL PRINT_HEX_BYTE                 ; AL already contains ASCII code
    
    ; Exit safely
    MOV AH, 4CH
    INT 21H
MAIN ENDP

;-----------------------------------------------------------------------------
; UTILITY: PRINT_HEX_BYTE
; Displays AL as a 2-digit hexadecimal number.
;-----------------------------------------------------------------------------
PRINT_HEX_BYTE PROC
    PUSH AX
    MOV AH, AL                          ; Duplicate AL
    SHR AL, 4                           ; Shift high nibble to low
    CALL PRINT_DIGIT                    ; Print first hex digit
    MOV AL, AH                          ; Restore original AL
    AND AL, 0FH                         ; Mask out high nibble
    CALL PRINT_DIGIT                    ; Print second hex digit
    POP AX
    RET
PRINT_HEX_BYTE ENDP

PRINT_DIGIT PROC
    CMP AL, 9
    JA HEX_LETTER
    ADD AL, '0'                         ; Convert 0-9 to ASCII '0'-'9'
    JMP PRINT_IT
HEX_LETTER:
    ADD AL, 'A' - 10                    ; Convert 10-15 to ASCII 'A'-'F'
PRINT_IT:
    MOV DL, AL
    MOV AH, 02H                         ; DOS: print character
    INT 21H
    RET
PRINT_DIGIT ENDP

END MAIN

;=============================================================================
; BIOS KEYBOARD NOTES:
; - Unlike DOS AH=01h, BIOS AH=00h does NOT automatically show the character
;   on the screen (no echo).
; - Scan codes uniquely identify physical keys, allowing detection of
;   special keys like Arrows, F-keys, and PgUp/PgDn.
;=============================================================================
