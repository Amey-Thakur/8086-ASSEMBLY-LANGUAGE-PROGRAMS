; =============================================================================
; TITLE: Jump Search
; DESCRIPTION: Strides through a sorted array in fixed blocks and then walks
;              back, which needs fewer comparisons than a linear scan.
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
    SORTED  DW 2, 5, 9, 14, 20, 27, 35, 44, 54, 65, 77, 90, 104, 119, 135, 152
    HOWMANY EQU 16
    STRIDE  EQU 4                       ; The square root of sixteen

    WANTED  DW 77
    ABSENT  DW 100

    M_ARRAY DB 'Sorted: $'
    M_LOOK  DB 'Looking for $'
    M_AT    DB '   at index $'
    M_NONE  DB '   not present$'
    M_STEPS DB '   comparisons: $'

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
    LEA SI, SORTED
    MOV CX, HOWMANY
    CALL SHOW_RUN

    MOV AX, WANTED
    CALL JUMP_SEARCH

    MOV AX, ABSENT
    CALL JUMP_SEARCH

    MOV AX, 4C00H
    INT 21H

; -----------------------------------------------------------------------------
; JUMP_SEARCH
;
; Looks for AX in SORTED. The stride is the square root of the length, which
; is the value that minimises the total work.
; -----------------------------------------------------------------------------
JUMP_SEARCH PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX

    PUSH AX
    LEA DX, M_LOOK
    MOV AH, 09H
    INT 21H
    POP AX
    PUSH AX
    CALL PRINT_DECIMAL
    POP AX

    MOV BP, AX                          ; What is sought
    XOR BX, BX                          ; The block boundary
    XOR DI, DI                          ; Comparisons made

    ; -------------------------------------------------------------------------
    ; STRIDE FORWARD UNTIL THE BLOCK THAT COULD CONTAIN THE VALUE IS FOUND,
    ; WHICH IS THE FIRST BLOCK WHOSE LAST ELEMENT IS NOT SMALLER. THEN WALK
    ; BACKWARD THROUGH THAT BLOCK ALONE.
    ; -------------------------------------------------------------------------
FIND_BLOCK:
    MOV CX, BX
    ADD CX, STRIDE
    DEC CX                              ; The last index of this block
    CMP CX, HOWMANY
    JB  BLOCK_INSIDE
    MOV CX, HOWMANY
    DEC CX                              ; The final block may be short

BLOCK_INSIDE:
    INC DI
    MOV SI, CX
    SHL SI, 1
    MOV AX, SORTED[SI]
    CMP AX, BP
    JAE BLOCK_FOUND

    ADD BX, STRIDE
    CMP BX, HOWMANY
    JB  FIND_BLOCK
    JMP JS_ABSENT                       ; Past the end of the array

BLOCK_FOUND:
    ; -------------------------------------------------------------------------
    ; WALK BACK FROM THE END OF THE BLOCK. AT MOST STRIDE COMPARISONS, AND THE
    ; FIRST VALUE SMALLER THAN THE TARGET PROVES IT IS NOT THERE.
    ; -------------------------------------------------------------------------
WALK_BACK:
    INC DI
    MOV SI, CX
    SHL SI, 1
    MOV AX, SORTED[SI]

    CMP AX, BP
    JE  JS_FOUND
    JB  JS_ABSENT                       ; Gone past where it would be

    CMP CX, BX
    JBE JS_ABSENT                       ; Reached the start of the block
    DEC CX
    JMP WALK_BACK

JS_FOUND:
    PUSH DI
    LEA DX, M_AT
    MOV AH, 09H
    INT 21H
    MOV AX, CX
    CALL PRINT_DECIMAL
    POP DI
    JMP JS_STEPS

JS_ABSENT:
    PUSH DI
    LEA DX, M_NONE
    MOV AH, 09H
    INT 21H
    POP DI

JS_STEPS:
    PUSH DI
    LEA DX, M_STEPS
    MOV AH, 09H
    INT 21H
    POP AX
    CALL PRINT_DECIMAL
    CALL NEWLINE

    POP DX
    POP CX
    POP BX
    POP AX
    RET
JUMP_SEARCH ENDP

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
; 1. WHY THE STRIDE IS THE SQUARE ROOT:
;    - Striding costs the length divided by the stride, and walking back
;    - costs the stride. Their sum is least when the two are equal, which
;    - is at the square root.
; 2. WHEN IT BEATS BINARY SEARCH:
;    - It does not, on comparisons. It wins where jumping backward is
;    - expensive and going forward is cheap, such as a singly linked list
;    - or a tape.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
