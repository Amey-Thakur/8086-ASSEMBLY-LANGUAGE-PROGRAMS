; =============================================================================
; TITLE: BIOS System Time
; DESCRIPTION: Reads the System Clock Tick Counter using BIOS Interrupt 1Ah.
;              The counter increments approximately 18.2 times per second.
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
    MSG_TIME    DB "System Ticks (Hex): $"

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
MAIN PROC
    ; --- Step 1: Initialize DS ---
    MOV AX, @DATA
    MOV DS, AX

    ; --- Step 2: Prompt ---
    LEA DX, MSG_TIME
    MOV AH, 09H
    INT 21H

    ; --- Step 3: Get System Time (INT 1Ah / AH=00h) ---
    ; Returns: CX:DX = Ticks since midnight
    ;          AL = Midnight Flag (1 if midnight passed)
    MOV AH, 00H
    INT 1AH

    ; --- Step 4: Print CX (High Word) ---
    MOV AX, CX
    CALL PRINT_WORD_HEX

    ; --- Step 5: Print DX (Low Word) ---
    MOV AX, DX
    CALL PRINT_WORD_HEX

    ; --- Step 6: Exit ---
    MOV AH, 4CH
    INT 21H
MAIN ENDP

; -----------------------------------------------------------------------------
; PROCEDURE: PRINT_WORD_HEX
; Input: AX (16-bit word)
; -----------------------------------------------------------------------------
PRINT_WORD_HEX PROC
    PUSH AX
    MOV AL, AH
    CALL PRINT_BYTE_HEX                 ; Print High Byte
    POP AX
    CALL PRINT_BYTE_HEX                 ; Print Low Byte
    RET
PRINT_WORD_HEX ENDP

PRINT_BYTE_HEX PROC
    PUSH AX
    MOV BL, AL
    SHR AL, 4
    CALL PRINT_DIGIT
    MOV AL, BL
    AND AL, 0FH
    CALL PRINT_DIGIT
    POP AX
    RET
PRINT_BYTE_HEX ENDP

PRINT_DIGIT PROC
    CMP AL, 9
    JG L_F
    ADD AL, '0'
    JMP L_P
L_F:
    ADD AL, 'A' - 10
L_P:
    MOV DL, AL
    MOV AH, 02H
    INT 21H
    RET
PRINT_DIGIT ENDP

END MAIN

; =============================================================================
; TECHNICAL NOTES & ARCHITECTURAL INSIGHTS
; =============================================================================
; 1. SYSTEM TIMER (INT 1Ah):
;    - Driven by the Intel 8253/8254 Programmable Interval Timer (PIT).
;    - Channel 0 interrupts the CPU (IRQ0 -> INT 08h) approx 18.2065 times/sec.
;    - BIOS handler for INT 08h updates the tick count in memory (0040:006C).
;    - 1AH simply reads this memory location atomically.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
