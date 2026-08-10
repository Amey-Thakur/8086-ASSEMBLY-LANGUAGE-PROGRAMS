; =============================================================================
; TITLE: Moving and Reading the Cursor
; DESCRIPTION: Places the cursor at a chosen row and column, and asks where it
;              is, which is how text is put anywhere on the screen.
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
    LABEL_A DB 'placed at row 5 column 20'
    LABEL_ALEN EQU $ - LABEL_A

    M_WHERE DB 'The cursor is now at row $'
    M_COL   DB ', column $'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    ; -------------------------------------------------------------------------
    ; SERVICE 02H SETS THE POSITION. DH IS THE ROW AND DL THE COLUMN, BOTH
    ; COUNTING FROM NOUGHT AT THE TOP LEFT. BH CHOOSES WHICH DISPLAY PAGE,
    ; AND ON A TEXT SCREEN THAT IS ALWAYS NOUGHT.
    ; -------------------------------------------------------------------------
    MOV AH, 02H
    MOV BH, 0
    MOV DH, 5                           ; Row
    MOV DL, 20                          ; Column
    INT 10H

    LEA SI, LABEL_A
    MOV CX, LABEL_ALEN
    CALL BIOS_PRINT

    ; -------------------------------------------------------------------------
    ; SERVICE 03H READS IT BACK. THE POSITION COMES OUT IN THE SAME REGISTERS
    ; IT WENT IN, AND CX DESCRIBES THE SHAPE OF THE CURSOR ITSELF.
    ; -------------------------------------------------------------------------
    MOV AH, 03H
    MOV BH, 0
    INT 10H

    PUSH DX

    MOV AH, 02H
    MOV BH, 0
    MOV DH, 8
    MOV DL, 0
    INT 10H

    LEA DX, M_WHERE
    MOV AH, 09H
    INT 21H
    POP DX
    PUSH DX
    MOV AL, DH
    XOR AH, AH
    CALL PRINT_DECIMAL

    LEA DX, M_COL
    MOV AH, 09H
    INT 21H
    POP DX
    MOV AL, DL
    XOR AH, AH
    CALL PRINT_DECIMAL
    CALL NEWLINE

    MOV AX, 4C00H
    INT 21H

; -----------------------------------------------------------------------------
; BIOS_PRINT
;
; Prints CX characters from DS:SI using the BIOS teletype service.
; -----------------------------------------------------------------------------
BIOS_PRINT PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH SI

BP_LOOP:
    JCXZ BP_DONE
    MOV AL, [SI]
    MOV AH, 0EH
    MOV BH, 0
    INT 10H
    INC SI
    LOOP BP_LOOP

BP_DONE:
    POP SI
    POP CX
    POP BX
    POP AX
    RET
BIOS_PRINT ENDP

; -----------------------------------------------------------------------------
; PRINT_DECIMAL
;
; Prints the unsigned value in AX as decimal, with no leading zeros.
; Every register it touches is restored, so a caller can rely on it.
; -----------------------------------------------------------------------------
PRINT_DECIMAL PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX

    XOR CX, CX                          ; How many digits have been stacked
    MOV BX, 10

PD_DIVIDE:
    XOR DX, DX                          ; DX:AX is the dividend, so clear DX
    DIV BX                              ; AX = quotient, DX = this digit
    PUSH DX                             ; Digits arrive lowest first
    INC CX
    OR  AX, AX
    JNZ PD_DIVIDE                       ; Keep going until the quotient is zero

PD_EMIT:
    POP DX                              ; Unstacking reverses them into order
    ADD DL, '0'
    MOV AH, 02H
    INT 21H
    LOOP PD_EMIT

    POP DX
    POP CX
    POP BX
    POP AX
    RET
PRINT_DECIMAL ENDP

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
; 1. ROW AND COLUMN, NOT X AND Y:
;    - DH is the row and DL the column, so the vertical coordinate comes
;    - first. Writing them the other way round is the usual mistake and
;    - puts the text somewhere plausible but wrong.
; 2. COUNTING FROM NOUGHT:
;    - The top left is row nought, column nought. On an eighty by
;    - twenty five screen the last position is row 24, column 79.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
