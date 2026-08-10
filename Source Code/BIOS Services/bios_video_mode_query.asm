; =============================================================================
; TITLE: Asking About the Display
; DESCRIPTION: Reads which video mode is active and how wide the screen is,
;              before assuming anything about where text can go.
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
    MODE_   DB 0
    WIDTH_  DB 0
    PAGE_   DB 0

    M_MODE  DB 'Video mode:   $'
    M_WIDTH DB 'Columns:      $'
    M_PAGE  DB 'Active page:  $'
    M_TEXT  DB 'This is a text mode, so characters can be written.', 0DH, 0AH, '$'
    M_GRAPH DB 'This is a graphics mode.', 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    ; -------------------------------------------------------------------------
    ; SERVICE 0FH REPORTS THE STATE OF THE DISPLAY: THE MODE IN AL, THE NUMBER
    ; OF COLUMNS IN AH, AND WHICH PAGE IS BEING SHOWN IN BH. ASKING IS BETTER
    ; THAN ASSUMING, BECAUSE A PROGRAM MAY HAVE BEEN STARTED FROM ANYTHING.
    ; -------------------------------------------------------------------------
    MOV AH, 0FH
    INT 10H

    ; -------------------------------------------------------------------------
    ; ALL THREE ANSWERS ARRIVE TOGETHER AND ARE PUT SOMEWHERE SAFE AT ONCE.
    ; PRINTING EACH ONE DESTROYS AX, SO ASKING AGAIN BETWEEN REPORTS WOULD
    ; WORK BUT WOULD BE THREE CALLS WHERE ONE WILL DO.
    ; -------------------------------------------------------------------------
    MOV MODE_, AL                       ; The video mode
    MOV WIDTH_, AH                      ; How many columns
    MOV PAGE_, BH                       ; Which display page

    LEA DX, M_MODE
    MOV AH, 09H
    INT 21H
    MOV AL, MODE_
    XOR AH, AH
    CALL PRINT_DECIMAL
    CALL NEWLINE

    LEA DX, M_WIDTH
    MOV AH, 09H
    INT 21H
    MOV AL, WIDTH_
    XOR AH, AH
    CALL PRINT_DECIMAL
    CALL NEWLINE

    LEA DX, M_PAGE
    MOV AH, 09H
    INT 21H
    MOV AL, PAGE_
    XOR AH, AH
    CALL PRINT_DECIMAL
    CALL NEWLINE

    ; -------------------------------------------------------------------------
    ; MODES NOUGHT TO THREE AND SEVEN ARE TEXT. EVERYTHING ELSE IS GRAPHICS,
    ; WHERE WRITING A CHARACTER MEANS DRAWING ITS SHAPE RATHER THAN STORING
    ; ITS CODE.
    ; -------------------------------------------------------------------------
    POP BX
    CMP BL, 3
    JBE TEXT_MODE
    CMP BL, 7
    JE  TEXT_MODE

    LEA DX, M_GRAPH
    JMP REPORT

TEXT_MODE:
    LEA DX, M_TEXT

REPORT:
    MOV AH, 09H
    INT 21H

    MOV AX, 4C00H
    INT 21H

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
; 1. THREE ANSWERS FROM ONE CALL:
;    - The mode, the width and the page all come back together, which is
;    - why a program that needs any of them usually keeps all three.
; 2. MODE 3 IS THE ORDINARY ONE:
;    - Eighty columns by twenty five rows in colour, which is what a DOS
;    - prompt runs in and what almost every program assumes.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
