; =============================================================================
; TITLE: Byte and Word Port Transfers
; DESCRIPTION: Shows that a word transfer touches two consecutive ports, and
;              that a port number above 255 has to travel in DX.
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
    LOW_PORT  EQU 40
    HIGH_PORT EQU 41
    FAR_PORT  EQU 03F8H                 ; The first serial port on a PC

    M_WORD  DB 'Wrote 1234h as a word to port 40.', 0DH, 0AH, '$'
    M_LOW   DB '  port 40 now holds $'
    M_HIGH  DB '  port 41 now holds $'
    M_FAR   DB 'Port 03F8h needs DX, and holds $'
    CRLF    DB 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    ; -------------------------------------------------------------------------
    ; A WORD TRANSFER SENDS THE LOW BYTE TO THE NAMED PORT AND THE HIGH BYTE
    ; TO THE ONE AFTER IT. THAT IS WHY DEVICE DOCUMENTATION LISTS PORTS IN
    ; PAIRS: A SIXTEEN BIT REGISTER OCCUPIES TWO PORT NUMBERS.
    ; -------------------------------------------------------------------------
    MOV AX, 1234H
    OUT LOW_PORT, AX

    LEA DX, M_WORD
    MOV AH, 09H
    INT 21H

    LEA DX, M_LOW
    MOV AH, 09H
    INT 21H
    IN  AL, LOW_PORT
    XOR AH, AH
    CALL PRINT_HEX_BYTE
    LEA DX, CRLF
    MOV AH, 09H
    INT 21H

    LEA DX, M_HIGH
    MOV AH, 09H
    INT 21H
    IN  AL, HIGH_PORT
    XOR AH, AH
    CALL PRINT_HEX_BYTE
    LEA DX, CRLF
    MOV AH, 09H
    INT 21H

    ; -------------------------------------------------------------------------
    ; THE IMMEDIATE FORM OF IN AND OUT HAS EIGHT BITS FOR THE PORT NUMBER, SO
    ; ANYTHING ABOVE 255 MUST BE PLACED IN DX FIRST. NO OTHER REGISTER WILL
    ; SERVE, WHICH IS WHY OUT DX, AL IS SUCH A COMMON SIGHT.
    ; -------------------------------------------------------------------------
    MOV DX, FAR_PORT
    MOV AL, 5AH
    OUT DX, AL

    MOV DX, FAR_PORT
    IN  AL, DX
    MOV BL, AL

    LEA DX, M_FAR
    MOV AH, 09H
    INT 21H
    MOV AL, BL
    CALL PRINT_HEX_BYTE
    LEA DX, CRLF
    MOV AH, 09H
    INT 21H

    MOV AX, 4C00H
    INT 21H

; -----------------------------------------------------------------------------
; PRINT_HEX_BYTE
; -----------------------------------------------------------------------------
PRINT_HEX_BYTE PROC
    PUSH AX
    PUSH CX
    PUSH DX

    MOV CL, AL
    SHR AL, 4
    CALL EMIT_NIBBLE
    MOV AL, CL
    AND AL, 0FH
    CALL EMIT_NIBBLE

    MOV DL, 'h'
    MOV AH, 02H
    INT 21H

    POP DX
    POP CX
    POP AX
    RET
PRINT_HEX_BYTE ENDP

EMIT_NIBBLE PROC
    ADD AL, '0'
    CMP AL, '9'
    JBE EN_EMIT
    ADD AL, 7

EN_EMIT:
    MOV DL, AL
    MOV AH, 02H
    INT 21H
    RET
EMIT_NIBBLE ENDP

END START

; =============================================================================
; TECHNICAL NOTES
; =============================================================================
; 1. LITTLE ENDIAN, HERE TOO:
;    - The low byte goes to the lower port number, exactly as it goes to
;    - the lower address in memory. The convention is the same throughout
;    - the processor.
; 2. ONLY DX CARRIES A LARGE PORT NUMBER:
;    - Not BX, not SI. The instruction encoding provides for DX and
;    - nothing else, which is a restriction worth remembering before
;    - reaching for another register.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
