; =============================================================================
; TITLE: LEA, OFFSET, and the Difference From MOV
; DESCRIPTION: Contrasts loading an address with loading the contents of that
;              address, the distinction that catches almost everyone once.
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
    NUMBER  DW 4660                     ; 1234H
    MSG_ADR DB 'The address of NUMBER: $'
    MSG_VAL DB 'The value at NUMBER:   $'
    MSG_CMP DB 'LEA and OFFSET agreed.', 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    ; -------------------------------------------------------------------------
    ; LEA COMPUTES AN ADDRESS. MOV READS WHAT IS THERE. THE TWO LOOK ALIKE
    ; AND MEAN OPPOSITE THINGS.
    ; -------------------------------------------------------------------------
    LEA BX, NUMBER                      ; BX = where NUMBER lives
    MOV CX, NUMBER                      ; CX = what NUMBER holds

    LEA DX, MSG_ADR
    MOV AH, 09H
    INT 21H
    MOV AX, BX
    CALL PRINT_HEX
    CALL NEWLINE

    LEA DX, MSG_VAL
    MOV AH, 09H
    INT 21H
    MOV AX, CX
    CALL PRINT_HEX
    CALL NEWLINE

    ; -------------------------------------------------------------------------
    ; OFFSET DOES THE SAME AS LEA FOR A PLAIN NAME, BUT THE ASSEMBLER WORKS
    ; IT OUT RATHER THAN THE PROCESSOR. FOR A NAME, EITHER WILL DO.
    ; -------------------------------------------------------------------------
    MOV SI, OFFSET NUMBER
    CMP SI, BX
    JNE FINISH

    LEA DX, MSG_CMP
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
; 1. WHEN ONLY LEA WILL DO:
;    - OFFSET needs an address the assembler can work out at assembly
;    - time. LEA BX, [SI+DI+4] involves registers, so only the processor
;    - can compute it, and only LEA can express it.
; 2. LEA AS ARITHMETIC:
;    - LEA performs an addition and stores the result without touching
;    - the flags. It is sometimes used purely as an add that leaves the
;    - flags alone.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
