; =============================================================================
; TITLE: Moving the Zeros to the End
; DESCRIPTION: Pushes every zero to the back while keeping the other elements
;              in their original order, in a single pass.
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
    DATA_W  DW 0, 12, 0, 7, 3, 0, 9, 0
    HOWMANY EQU 8

    M_BEFORE DB 'Before: $'
    M_AFTER  DB 'After:  $'
    M_MOVED  DB 'Zeros moved: $'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA DX, M_BEFORE
    MOV AH, 09H
    INT 21H
    LEA SI, DATA_W
    MOV CX, HOWMANY
    CALL SHOW_RUN

    ; -------------------------------------------------------------------------
    ; TWO POINTERS TRAVELLING THE SAME WAY. SI READS EVERY ELEMENT; DI MARKS
    ; WHERE THE NEXT NON ZERO BELONGS. EVERYTHING BETWEEN THEM IS A ZERO THAT
    ; HAS BEEN PASSED OVER, AND FILLING THE TAIL AT THE END PUTS THEM BACK.
    ; -------------------------------------------------------------------------
    LEA SI, DATA_W
    LEA DI, DATA_W
    MOV CX, HOWMANY

COMPACT:
    MOV AX, [SI]
    OR  AX, AX
    JZ  SKIP_ZERO

    MOV [DI], AX
    ADD DI, 2

SKIP_ZERO:
    ADD SI, 2
    LOOP COMPACT

    ; -------------------------------------------------------------------------
    ; WHATEVER IS LEFT BETWEEN DI AND THE END OF THE ARRAY IS FILLED WITH
    ; ZEROS. HOW MANY THAT IS COMES OUT OF THE POINTERS THEMSELVES RATHER THAN
    ; FROM A COUNTER KEPT DURING THE PASS.
    ; -------------------------------------------------------------------------
    LEA AX, DATA_W
    ADD AX, HOWMANY * 2
    SUB AX, DI
    SHR AX, 1                           ; Bytes to elements
    MOV BP, AX                          ; How many zeros there were
    MOV CX, AX

    JCXZ NO_TAIL

FILL_TAIL:
    MOV WORD PTR [DI], 0
    ADD DI, 2
    LOOP FILL_TAIL

NO_TAIL:
    LEA DX, M_AFTER
    MOV AH, 09H
    INT 21H
    LEA SI, DATA_W
    MOV CX, HOWMANY
    CALL SHOW_RUN

    LEA DX, M_MOVED
    MOV AH, 09H
    INT 21H
    MOV AX, BP
    CALL PRINT_DECIMAL
    CALL NEWLINE

    MOV AX, 4C00H
    INT 21H

; -----------------------------------------------------------------------------
; SHOW_RUN
;
; Prints CX words starting at DS:SI, then a newline.
; -----------------------------------------------------------------------------
SHOW_RUN PROC
    PUSH AX
    PUSH CX
    PUSH DX
    PUSH SI

    JCXZ SR_DONE

SR_LOOP:
    MOV AX, [SI]
    PUSH CX
    PUSH SI
    CALL PRINT_SIGNED
    MOV DL, ' '
    MOV AH, 02H
    INT 21H
    POP SI
    POP CX

    ADD SI, 2
    LOOP SR_LOOP

SR_DONE:
    CALL NEWLINE

    POP SI
    POP DX
    POP CX
    POP AX
    RET
SHOW_RUN ENDP

; -----------------------------------------------------------------------------
; PRINT_SIGNED
;
; Prints AX as a signed value, with a minus sign when it is negative.
; -----------------------------------------------------------------------------
PRINT_SIGNED PROC
    PUSH AX
    PUSH DX

    OR  AX, AX
    JNS PS_POSITIVE                     ; Sign flag clear means not negative

    PUSH AX
    MOV DL, '-'
    MOV AH, 02H
    INT 21H
    POP AX
    NEG AX                              ; Print the magnitude

PS_POSITIVE:
    CALL PRINT_DECIMAL

    POP DX
    POP AX
    RET
PRINT_SIGNED ENDP

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
; 1. ORDER IS PRESERVED:
;    - The non zero elements are written in the order they were read, so
;    - 12 7 3 9 comes out in that sequence. Swapping each zero with the
;    - next non zero would be shorter and would not preserve it.
; 2. THE COUNT COMES FROM THE POINTERS:
;    - Where DI stopped says how many elements survived, so the number of
;    - zeros needs no separate counter and cannot disagree.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
