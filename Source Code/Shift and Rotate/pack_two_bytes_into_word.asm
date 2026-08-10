; =============================================================================
; TITLE: Pack Two Bytes into One Word
; DESCRIPTION: Combines two separate bytes into a single word by shifting one
;              into the high half and merging the other in with OR.
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
    HIGH_B DB 0A7H
    LOW_B  DB 3CH
    MSG    DB 'Packed word: $'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    ; -------------------------------------------------------------------------
    ; SHIFT THE HIGH BYTE UP EIGHT PLACES, THEN OR THE LOW BYTE INTO THE GAP.
    ; OR IS USED RATHER THAN ADD BECAUSE THE TWO CANNOT OVERLAP, SO THERE IS
    ; NO CARRY TO WORRY ABOUT AND THE INTENT IS CLEARER.
    ; -------------------------------------------------------------------------
    MOV AL, HIGH_B
    XOR AH, AH                          ; Clear the top before shifting into it
    MOV CL, 8
    SHL AX, CL

    MOV BL, LOW_B
    XOR BH, BH
    OR  AX, BX

    MOV SI, AX

    LEA DX, MSG
    MOV AH, 09H
    INT 21H
    MOV AX, SI
    CALL PRINT_HEX
    CALL NEWLINE

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
; 1. CLEARING BEFORE SHIFTING:
;    - AH has to be cleared first. Whatever it happened to hold would be
;    - shifted off the top and the result would still look plausible.
; 2. THE SHORTER WAY:
;    - On the 8086 a word register is addressable as two bytes, so MOV AH,
;    - HIGH_B and MOV AL, LOW_B builds the same word with no shifting at
;    - all. The long form is shown because it is what a machine without
;    - byte addressable halves would have to do.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
