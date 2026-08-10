; =============================================================================
; TITLE: Binary Search by Recursion
; DESCRIPTION: Halves the search range at each call, which is the way the
;              algorithm is usually described.
; AUTHOR: Amey Thakur (https://github.com/Amey-Thakur)
; REPOSITORY: https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
; LICENSE: MIT License
; =============================================================================

.MODEL SMALL
.STACK 200H

; -----------------------------------------------------------------------------
; DATA SEGMENT
; -----------------------------------------------------------------------------
.DATA
    SORTED  DW 3, 8, 15, 22, 31, 44, 57, 68, 79, 90
    HOWMANY EQU 10
    WANTED  DW 57
    M_FOUND DB '57 is at index $'
    M_NONE  DB '57 is not in the array', 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    MOV AX, 0                           ; low
    PUSH AX
    MOV AX, HOWMANY - 1                 ; high
    PUSH AX
    CALL BINARY_SEARCH
    ADD SP, 4

    CMP AX, 0FFFFH
    JE  NOT_PRESENT

    PUSH AX
    LEA DX, M_FOUND
    MOV AH, 09H
    INT 21H
    POP AX
    CALL PRINT_DECIMAL
    CALL NEWLINE
    JMP FINISH

NOT_PRESENT:
    LEA DX, M_NONE
    MOV AH, 09H
    INT 21H

FINISH:
    MOV AH, 4CH
    INT 21H

; -----------------------------------------------------------------------------
; BINARY_SEARCH
;
; [BP+6] is the low index and [BP+4] the high one. Returns the index in AX,
; or FFFFh when the value is not present.
; -----------------------------------------------------------------------------
BINARY_SEARCH PROC
    PUSH BP
    MOV BP, SP
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI

    MOV CX, [BP+6]                      ; low
    MOV DX, [BP+4]                      ; high

    CMP CX, DX
    JG  BS_MISSING                      ; The range closed with nothing in it

    ; -------------------------------------------------------------------------
    ; THE MIDDLE IS THE AVERAGE OF THE TWO ENDS. THE ELEMENT THERE EITHER IS
    ; THE ANSWER, OR TELLS US WHICH HALF TO DISCARD.
    ; -------------------------------------------------------------------------
    MOV AX, CX
    ADD AX, DX
    SHR AX, 1
    MOV BX, AX                          ; The middle index

    MOV SI, BX
    SHL SI, 1                           ; Words, so two bytes each
    MOV AX, SORTED[SI]

    CMP AX, WANTED
    JE  BS_FOUND
    JB  BS_UPPER_HALF

    ; Too large: search below the middle
    PUSH CX
    MOV AX, BX
    DEC AX
    PUSH AX
    CALL BINARY_SEARCH
    ADD SP, 4
    JMP BS_RETURN

BS_UPPER_HALF:
    MOV AX, BX
    INC AX
    PUSH AX
    PUSH DX
    CALL BINARY_SEARCH
    ADD SP, 4
    JMP BS_RETURN

BS_FOUND:
    MOV AX, BX
    JMP BS_RETURN

BS_MISSING:
    MOV AX, 0FFFFH

BS_RETURN:
    POP SI
    POP DX
    POP CX
    POP BX
    POP BP
    RET
BINARY_SEARCH ENDP

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
; 1. THE ARRAY MUST BE SORTED:
;    - Discarding half the range depends entirely on it. On unsorted data
;    - the search returns quickly and is simply wrong.
; 2. TEN ELEMENTS, FOUR COMPARISONS AT MOST:
;    - Each call halves what is left, so the depth is the base two
;    - logarithm of the count. A thousand elements would need ten.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
