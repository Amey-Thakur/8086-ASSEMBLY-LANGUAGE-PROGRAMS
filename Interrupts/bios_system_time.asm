;=============================================================================
; Program:     BIOS System Time (Ticks)
; Description: Access the BIOS Clock Tick counter using Interrupt 1AH.
;              The PC clock increments 18.2 times per second.
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
    MSG DB 'System ticks since midnight: $'
    NEWLINE DB 0DH, 0AH, '$'

;-----------------------------------------------------------------------------
; CODE SEGMENT
;-----------------------------------------------------------------------------
.CODE
MAIN PROC
    ; Initialize Data Segment
    MOV AX, @DATA
    MOV DS, AX
    
    ; Display header message
    LEA DX, MSG
    MOV AH, 09H
    INT 21H
    
    ;-------------------------------------------------------------------------
    ; GET SYSTEM TIME (INT 1AH, AH=00H)
    ; Returns: CX:DX = Total 32-bit ticks since midnight
    ;          AL = Midnight flag (reset if midnight passed since last read)
    ;-------------------------------------------------------------------------
    MOV AH, 00H                         ; BIOS service: get clock ticks
    INT 1AH                             ; 
    
    ; Display High Word (CX)
    MOV AX, CX
    CALL PRINT_HEX_WORD
    
    ; Display Low Word (DX)
    MOV AX, DX
    CALL PRINT_HEX_WORD
    
    ; Exit to DOS
    MOV AH, 4CH
    INT 21H
MAIN ENDP

;-----------------------------------------------------------------------------
; UTILITY PROCEDURES
;-----------------------------------------------------------------------------

; Print AX as 4 hex digits
PRINT_HEX_WORD PROC
    PUSH AX
    MOV AL, AH
    CALL PRINT_HEX_BYTE                 ; Print high byte
    POP AX
    CALL PRINT_HEX_BYTE                 ; Print low byte
    RET
PRINT_HEX_WORD ENDP

; Print AL as 2 hex digits
PRINT_HEX_BYTE PROC
    PUSH AX
    SHR AL, 4
    CALL PRINT_DIGIT
    POP AX
    AND AL, 0FH
    CALL PRINT_DIGIT
    RET
PRINT_HEX_BYTE ENDP

; Print single hex nibble in AL
PRINT_DIGIT PROC
    CMP AL, 9
    JA HEX_LETTER
    ADD AL, '0'
    JMP PRINT_IT
HEX_LETTER:
    ADD AL, 'A' - 10
PRINT_IT:
    MOV DL, AL
    MOV AH, 02H
    INT 21H
    RET
PRINT_DIGIT ENDP

END MAIN

;=============================================================================
; SYSTEM TIME NOTES:
; - The counter starts at 0 at midnight.
; - Ticks per second: ~18.2065
; - To calculate seconds from ticks, divide the result by 18.
; - Total ticks in a day: approx. 1,573,040 (about 1800B0h).
;=============================================================================
