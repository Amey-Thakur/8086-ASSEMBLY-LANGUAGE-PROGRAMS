; =============================================================================
; TITLE: Shift a 32-bit Value Right Using RCR
; DESCRIPTION: The mirror of the RCL case: shifting a two register value right
;              requires starting at the high half so the carry travels downward.
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
    HIGH_W DW 0003H                     ; The 32-bit value 0003_0000
    LOW_W  DW 0000H
    MSG    DB 'Halving the 32-bit value 00030000H three times:', 0DH, 0AH, '$'
    SEP    DB '_$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA DX, MSG
    MOV AH, 09H
    INT 21H

    MOV BX, HIGH_W
    MOV SI, LOW_W
    MOV CX, 3

SHIFT_LOOP:
    ; -------------------------------------------------------------------------
    ; GOING RIGHT, THE TRAVELLING BIT LEAVES THE BOTTOM OF THE HIGH HALF, SO
    ; THE HIGH HALF IS SHIFTED FIRST AND THE LOW HALF ROTATES THE CARRY IN.
    ; -------------------------------------------------------------------------
    SHR BX, 1                           ; High half; bottom bit leaves into CF
    RCR SI, 1                           ; Low half; CF arrives at the top

    PUSH CX

    MOV AX, BX
    CALL PRINT_HEX
    LEA DX, SEP
    MOV AH, 09H
    INT 21H
    MOV AX, SI
    CALL PRINT_HEX
    CALL NEWLINE

    POP CX
    LOOP SHIFT_LOOP

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
; 1. THE ORDER REVERSES:
;    - Shifting left starts at the least significant word; shifting right
;    - starts at the most significant. In both cases the rule is the same:
;    - shift the word the travelling bit is leaving.
; 2. SIGNED VALUES:
;    - This halves an unsigned 32-bit value. For a signed one the first
;    - instruction has to be SAR, so the sign is copied rather than a zero.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
