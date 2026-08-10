; =============================================================================
; TITLE: The Missing Number
; DESCRIPTION: Finds which value is absent from a list of one to n, by
;              comparing the total that should be there with the total that is.
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
    ; The numbers one to ten with one of them left out
    DATA_W  DW 3, 1, 9, 7, 5, 10, 2, 8, 4
    HOWMANY EQU 9
    LIMIT   EQU 10                      ; What the range should run to

    M_ARRAY DB 'The list: $'
    M_SHOULD DB 'One to ten should total $'
    M_ACTUAL DB 'The list totals          $'
    M_MISSING DB 'So the missing number is $'
    M_XOR   DB 'The same answer by exclusive or: $'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA DX, M_ARRAY
    MOV AH, 09H
    INT 21H
    LEA SI, DATA_W
    MOV CX, HOWMANY
    CALL SHOW_RUN

    ; -------------------------------------------------------------------------
    ; THE TOTAL OF ONE TO N IS N TIMES N PLUS ONE, HALVED. WHATEVER THE LIST
    ; FALLS SHORT BY IS THE MISSING VALUE. ONE PASS AND NO EXTRA STORAGE.
    ; -------------------------------------------------------------------------
    MOV AX, LIMIT
    INC AX
    MOV BX, LIMIT
    MUL BX
    SHR AX, 1
    MOV BP, AX                          ; What it should be

    PUSH BP
    LEA DX, M_SHOULD
    MOV AH, 09H
    INT 21H
    POP AX
    PUSH AX
    CALL PRINT_DECIMAL
    CALL NEWLINE
    POP BP

    LEA SI, DATA_W
    MOV CX, HOWMANY
    XOR BX, BX

TOTAL_UP:
    ADD BX, [SI]
    ADD SI, 2
    LOOP TOTAL_UP

    PUSH BX
    LEA DX, M_ACTUAL
    MOV AH, 09H
    INT 21H
    POP AX
    PUSH AX
    CALL PRINT_DECIMAL
    CALL NEWLINE
    POP BX

    MOV AX, BP
    SUB AX, BX

    PUSH AX
    LEA DX, M_MISSING
    MOV AH, 09H
    INT 21H
    POP AX
    CALL PRINT_DECIMAL
    CALL NEWLINE

    ; -------------------------------------------------------------------------
    ; A SECOND METHOD THAT CANNOT OVERFLOW: EXCLUSIVE OR EVERYTHING FROM ONE
    ; TO N TOGETHER WITH EVERY ELEMENT OF THE LIST. EVERY VALUE THAT APPEARS
    ; TWICE CANCELS ITSELF, LEAVING ONLY THE ONE THAT DID NOT.
    ; -------------------------------------------------------------------------
    XOR BX, BX
    MOV CX, LIMIT

XOR_RANGE:
    XOR BX, CX
    LOOP XOR_RANGE

    LEA SI, DATA_W
    MOV CX, HOWMANY

XOR_LIST:
    MOV AX, [SI]
    XOR BX, AX
    ADD SI, 2
    LOOP XOR_LIST

    PUSH BX
    LEA DX, M_XOR
    MOV AH, 09H
    INT 21H
    POP AX
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
    CALL PRINT_DECIMAL
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
; 1. THE SUM METHOD CAN OVERFLOW:
;    - For a range up to 65535 the expected total is over two thousand
;    - million and will not fit in a word. The exclusive or method has no
;    - such limit, because it never grows.
; 2. WHY EXCLUSIVE OR CANCELS:
;    - A value combined with itself gives nought, and the order does not
;    - matter. Everything present twice disappears and only the odd one
;    - out survives.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
