; =============================================================================
; TITLE: A Menu Driven Program
; DESCRIPTION: Shows a menu, reads a choice and dispatches to it, which is the
;              shape of most interactive DOS programs.
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
    MENU    DB 0DH, 0AH, 'Choose:', 0DH, 0AH
            DB '  1  the sum of the two values', 0DH, 0AH
            DB '  2  their product', 0DH, 0AH
            DB '  3  the larger of them', 0DH, 0AH
            DB '  4  quit, or press Enter', 0DH, 0AH
            DB 'Your choice: $'

    FIRST   DW 12
    SECOND  DW 30

    M_SUM   DB 0DH, 0AH, 'The sum is $'
    M_PROD  DB 0DH, 0AH, 'The product is $'
    M_LARGE DB 0DH, 0AH, 'The larger is $'
    M_BAD   DB 0DH, 0AH, 'That is not one of the choices.', 0DH, 0AH, '$'
    M_BYE   DB 0DH, 0AH, 'Finished.', 0DH, 0AH, '$'
    CRLF    DB 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

MENU_LOOP:
    LEA DX, MENU
    MOV AH, 09H
    INT 21H

    ; -------------------------------------------------------------------------
    ; READ ONE KEY AND BRANCH ON IT. THE CHARACTER IS COMPARED AS A CHARACTER,
    ; NOT CONVERTED TO A NUMBER FIRST, WHICH IS SHORTER AND MAKES THE MENU
    ; EASY TO EXTEND WITH LETTERS AS WELL AS DIGITS.
    ; -------------------------------------------------------------------------
    MOV AH, 01H
    INT 21H

    CMP AL, '1'
    JE  DO_SUM
    CMP AL, '2'
    JE  DO_PRODUCT
    CMP AL, '3'
    JE  DO_LARGER
    CMP AL, '4'
    JE  DO_QUIT

    ; -------------------------------------------------------------------------
    ; ENTER ON ITS OWN ALSO LEAVES. WITHOUT THAT, A PROGRAM WHOSE INPUT RUNS
    ; OUT KEEPS BEING HANDED A CARRIAGE RETURN AND ASKS THE SAME QUESTION
    ; FOREVER. ANY MENU THAT READS UNTIL IT IS SATISFIED NEEDS A WAY OUT THAT
    ; DOES NOT DEPEND ON THE RIGHT KEY ARRIVING.
    ; -------------------------------------------------------------------------
    CMP AL, 0DH
    JE  DO_QUIT

    LEA DX, M_BAD
    MOV AH, 09H
    INT 21H
    JMP MENU_LOOP

DO_SUM:
    LEA DX, M_SUM
    MOV AH, 09H
    INT 21H
    MOV AX, FIRST
    ADD AX, SECOND
    CALL PRINT_DECIMAL
    LEA DX, CRLF
    MOV AH, 09H
    INT 21H
    JMP MENU_LOOP

DO_PRODUCT:
    LEA DX, M_PROD
    MOV AH, 09H
    INT 21H
    MOV AX, FIRST
    MUL WORD PTR SECOND
    CALL PRINT_DECIMAL
    LEA DX, CRLF
    MOV AH, 09H
    INT 21H
    JMP MENU_LOOP

DO_LARGER:
    LEA DX, M_LARGE
    MOV AH, 09H
    INT 21H
    MOV AX, FIRST
    CMP AX, SECOND
    JAE HAVE_LARGER
    MOV AX, SECOND

HAVE_LARGER:
    CALL PRINT_DECIMAL
    LEA DX, CRLF
    MOV AH, 09H
    INT 21H
    JMP MENU_LOOP

DO_QUIT:
    LEA DX, M_BYE
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
; 1. COMPARING THE CHARACTER DIRECTLY:
;    - Testing against '1' rather than converting to a number saves the
;    - conversion and lets letters be added to the menu without changing
;    - anything else.
; 2. THE LOOP RETURNS TO THE MENU:
;    - Every branch except quit jumps back, so an unrecognised key simply
;    - asks again rather than ending the program.
; 3. IN THE SIMULATOR:
;    - The choices are read from the queued input, so typing 1234 into
;    - the input field runs the sum, the product, the larger and then
;    - quits.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
