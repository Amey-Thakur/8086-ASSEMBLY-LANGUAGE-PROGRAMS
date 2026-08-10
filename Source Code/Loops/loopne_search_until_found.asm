; =============================================================================
; TITLE: LOOPNE: Repeat Until a Match
; DESCRIPTION: Searches an array for a value, leaving as soon as it is found or
;              when every element has been examined.
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
    VALUES  DB 12, 45, 7, 88, 23, 61
    HOWMANY EQU 6
    WANTED  DB 88
    M_FOUND DB 'Found at position $'
    M_NONE  DB 'Not present.', 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA SI, VALUES
    MOV CX, HOWMANY
    MOV AL, WANTED
    XOR BX, BX                          ; Position being examined

    ; -------------------------------------------------------------------------
    ; LOOPNE CONTINUES WHILE CX IS NON ZERO AND THE ZERO FLAG IS CLEAR, SO
    ; IT KEEPS GOING WHILE THE COMPARISONS KEEP FAILING AND STOPS ON THE
    ; FIRST MATCH.
    ; -------------------------------------------------------------------------
SEARCH:
    CMP AL, [SI]
    JE  FOUND

    INC SI
    INC BX
    CMP AL, [SI]                        ; Set ZF for LOOPNE
    LOOPNE SEARCH

    ; Falling out here means the count ran out
    CMP AL, [SI]
    JNE NOT_PRESENT

FOUND:
    LEA DX, M_FOUND
    MOV AH, 09H
    INT 21H
    MOV AX, BX
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
; 1. DISTINGUISHING THE TWO EXITS:
;    - After the loop, the comparison has to be made once more to tell a
;    - match on the last element from having run out of elements.
; 2. REPNE SCASB IS THE SHORTER WAY:
;    - The string instructions do this whole search in two instructions,
;    - and leave CX holding how many elements were left. This form is
;    - shown because it works on any comparison, not only equality.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
