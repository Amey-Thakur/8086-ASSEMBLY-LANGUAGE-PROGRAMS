; =============================================================================
; TITLE: Partitioning an Array
; DESCRIPTION: Divides an array in place so that everything below a pivot comes
;              first, which is the step quicksort is built on.
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
    DATA_W  DW 29, 4, 17, 42, 8, 31, 12, 25
    HOWMANY EQU 8
    PIVOT   EQU 20

    M_BEFORE DB 'Before: $'
    M_AFTER  DB 'After:  $'
    M_SPLIT  DB 'Values below 20 occupy the first $'
    M_TAIL   DB ' places', 0DH, 0AH, '$'

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
    ; DI MARKS THE END OF THE REGION THAT SATISFIES THE CONDITION. WHENEVER SI
    ; FINDS ANOTHER ONE, THE TWO ARE EXCHANGED AND THE BOUNDARY MOVES UP. THE
    ; ELEMENT SWAPPED BACK IS ONE THAT FAILED, SO IT LANDS IN THE RIGHT REGION
    ; WITHOUT NEEDING TO BE EXAMINED AGAIN.
    ; -------------------------------------------------------------------------
    LEA SI, DATA_W
    LEA DI, DATA_W
    MOV CX, HOWMANY

PARTITION:
    MOV AX, [SI]
    CMP AX, PIVOT
    JAE LEAVE_IT

    ; Exchange it into the low region
    MOV BX, [DI]
    MOV [DI], AX
    MOV [SI], BX
    ADD DI, 2

LEAVE_IT:
    ADD SI, 2
    LOOP PARTITION

    LEA DX, M_AFTER
    MOV AH, 09H
    INT 21H
    LEA SI, DATA_W
    MOV CX, HOWMANY
    CALL SHOW_RUN

    ; How large the low region turned out to be
    LEA AX, DATA_W
    MOV BX, DI
    SUB BX, AX
    SHR BX, 1

    LEA DX, M_SPLIT
    MOV AH, 09H
    INT 21H
    MOV AX, BX
    CALL PRINT_DECIMAL
    LEA DX, M_TAIL
    MOV AH, 09H
    INT 21H

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
; 1. ORDER IS NOT PRESERVED:
;    - The exchanges move elements past each other, so within each region
;    - the original order is lost. A stable partition needs a second
;    - array, which is the trade every sorting library makes explicit.
; 2. THIS IS THE HEART OF QUICKSORT:
;    - Partition, then sort each half the same way. The partition is the
;    - only part that touches the data; the rest is recursion.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
