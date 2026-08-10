; =============================================================================
; TITLE: Overriding the Source Segment
; DESCRIPTION: Copies from a segment other than DS, which the source of a string
;              operation permits and the destination does not.
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
    ORIGIN  DB 'Overridden!'
    LENGTH  EQU 11
    LANDING DB 12 DUP('$')
    M_DONE  DB 'Copied through an override: $'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX
    MOV ES, AX

    ; -------------------------------------------------------------------------
    ; THE SOURCE OF A STRING OPERATION IS DS:SI AND MAY BE OVERRIDDEN TO ANY
    ; SEGMENT REGISTER. THE DESTINATION IS ES:DI AND MAY NOT BE. HERE THE
    ; SOURCE IS TAKEN THROUGH ES DELIBERATELY, WHICH IS LEGAL AND WORKS.
    ; -------------------------------------------------------------------------
    LEA SI, ORIGIN
    LEA DI, LANDING
    MOV CX, LENGTH
    CLD

COPY_LOOP:
    MOV AL, ES:[SI]                     ; The override, written explicitly
    MOV [DI], AL
    INC SI
    INC DI
    LOOP COPY_LOOP

    MOV BYTE PTR [DI], '$'

    LEA DX, M_DONE
    MOV AH, 09H
    INT 21H
    LEA DX, LANDING
    MOV AH, 09H
    INT 21H
    CALL NEWLINE

    MOV AH, 4CH
    INT 21H

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
; 1. WHAT AN OVERRIDE COSTS:
;    - One extra byte in front of the instruction, and on an 8086 two
;    - extra clock cycles. It is a prefix, not a separate instruction.
; 2. THE ASYMMETRY IS DELIBERATE:
;    - A copy between two segments needs one of the pair fixed, or the
;    - instruction would need two segment fields and no room for them.
;    - The destination was chosen as the fixed one.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
