; =============================================================================
; TITLE: Table Lookup with XLAT
; DESCRIPTION: Translates a run of values through a lookup table with XLAT,
;              which does an indexed read in a single byte of code.
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
    ; The seven segment pattern for each digit from zero to nine
    SEGMENTS DB 3FH, 06H, 5BH, 4FH, 66H, 6DH, 7DH, 07H, 7FH, 6FH
    WANTED   DB 0, 1, 4, 8, 9
    HOWMANY  EQU 5
    MSG      DB 'Seven segment patterns for 0, 1, 4, 8, 9:', 0DH, 0AH, '$'

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

    ; -------------------------------------------------------------------------
    ; XLAT READS THE BYTE AT DS:BX PLUS AL AND PUTS IT IN AL. BX HOLDS THE
    ; START OF THE TABLE AND AL HOLDS THE INDEX, SO ONE INSTRUCTION DOES THE
    ; WHOLE LOOKUP.
    ; -------------------------------------------------------------------------
    LEA BX, SEGMENTS                    ; BX must point at the table
    LEA SI, WANTED
    MOV CX, HOWMANY

LOOKUP_LOOP:
    MOV AL, [SI]                        ; The index to translate
    XLAT                                ; AL becomes the table entry

    XOR AH, AH
    PUSH CX
    PUSH SI
    CALL PRINT_HEX
    CALL NEWLINE
    POP SI
    POP CX

    INC SI
    LOOP LOOKUP_LOOP

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
; 1. THE FIXED REGISTERS:
;    - XLAT has no operands. It always uses BX for the table and AL for
;    - the index, and always writes its answer to AL. That is what lets
;    - it be a single byte instruction.
; 2. THE TABLE MUST BE 256 BYTES OR THE INDEX BOUNDED:
;    - AL can hold anything up to 255, and XLAT will read that far past
;    - the start of the table. Either provide 256 entries or check the
;    - index before translating.
; 3. WHY PUSH AROUND THE CALL:
;    - Printing calls DOS, which does not promise to preserve SI or CX.
;    - Saving them across the call is what keeps the loop counting.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
