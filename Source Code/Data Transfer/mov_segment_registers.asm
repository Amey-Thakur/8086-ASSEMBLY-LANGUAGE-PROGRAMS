; =============================================================================
; TITLE: Loading the Segment Registers
; DESCRIPTION: Sets up DS and ES, reads them back, and explains why a segment
;              register cannot be loaded with a constant directly.
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
    MSG_DS DB 'DS = $'
    MSG_ES DB 'ES = $'
    MSG_EQ DB 'DS and ES point at the same segment.', 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    ; -------------------------------------------------------------------------
    ; @DATA IS THE SEGMENT THE ASSEMBLER PLACED THE DATA IN. IT HAS TO GO
    ; THROUGH A GENERAL REGISTER, BECAUSE THERE IS NO INSTRUCTION THAT PUTS
    ; AN IMMEDIATE STRAIGHT INTO A SEGMENT REGISTER.
    ; -------------------------------------------------------------------------
    MOV AX, @DATA
    MOV DS, AX
    MOV ES, AX                          ; String destinations need ES

    LEA DX, MSG_DS
    MOV AH, 09H
    INT 21H
    MOV AX, DS                          ; A segment register can be read out
    CALL PRINT_HEX
    CALL NEWLINE

    LEA DX, MSG_ES
    MOV AH, 09H
    INT 21H
    MOV AX, ES
    CALL PRINT_HEX
    CALL NEWLINE

    MOV AX, DS
    MOV BX, ES
    CMP AX, BX
    JNE FINISH

    LEA DX, MSG_EQ
    MOV AH, 09H
    INT 21H

FINISH:
    MOV AH, 4CH
    INT 21H

; -----------------------------------------------------------------------------
; PRINT_HEX
;
; Prints the value in AX as four hexadecimal digits followed by H.
; -----------------------------------------------------------------------------
PRINT_HEX PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX

    MOV BX, AX                          ; Keep the value; AX is needed for DOS
    MOV CX, 4                           ; Four nibbles, most significant first

PH_NEXT:
    ROL BX, 4                           ; Bring the next nibble to the bottom
    MOV DL, BL
    AND DL, 0FH

    ADD DL, '0'                         ; 0 to 9 sit just after '0'
    CMP DL, '9'
    JBE PH_EMIT
    ADD DL, 7                           ; A to F sit seven further on

PH_EMIT:
    MOV AH, 02H
    INT 21H
    LOOP PH_NEXT

    MOV DL, 'H'
    MOV AH, 02H
    INT 21H

    POP DX
    POP CX
    POP BX
    POP AX
    RET
PRINT_HEX ENDP

; -----------------------------------------------------------------------------
; NEWLINE
;
; Moves to the start of the next line. DOS needs both characters: the return
; moves the cursor to column zero and the feed moves it down a line.
; -----------------------------------------------------------------------------
NEWLINE PROC
    PUSH AX
    PUSH DX

    MOV DL, 0DH
    MOV AH, 02H
    INT 21H
    MOV DL, 0AH
    MOV AH, 02H
    INT 21H

    POP DX
    POP AX
    RET
NEWLINE ENDP

END START

; =============================================================================
; TECHNICAL NOTES
; =============================================================================
; 1. NO IMMEDIATE FORM:
;    - The instruction encoding has no room for a constant destined for a
;    - segment register, so every program loads one through AX.
; 2. WHY ES IS SET TOO:
;    - Every string instruction writes to ES:DI and no override changes
;    - that. A program that uses MOVSB or STOSB without setting ES writes
;    - somewhere it did not intend.
; 3. CS IS NOT WRITEABLE THIS WAY:
;    - MOV CS, AX is not allowed. Changing which segment the code runs in
;    - has to change IP at the same instant, which only a far jump or a
;    - far return can do.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
