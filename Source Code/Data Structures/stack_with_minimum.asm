; =============================================================================
; TITLE: A Stack That Knows Its Smallest Value
; DESCRIPTION: Keeps the running minimum alongside the values, so the smallest
;              item can be had at any moment without searching.
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
    CAPACITY EQU 10
    VALUES   DW CAPACITY DUP(0)
    MINIMA   DW CAPACITY DUP(0)         ; The smallest value at each depth
    DEPTH    DW 0

    M_PUSH   DB 'push $'
    M_POP    DB 'pop  $'
    M_MIN    DB '   smallest now: $'
    M_NONE   DB '   the stack is empty', 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    MOV AX, 40
    CALL PUSH_ITEM
    MOV AX, 15
    CALL PUSH_ITEM
    MOV AX, 70
    CALL PUSH_ITEM
    MOV AX, 8
    CALL PUSH_ITEM
    MOV AX, 22
    CALL PUSH_ITEM

    CALL POP_ITEM                       ; 22 goes, 8 is still smallest
    CALL POP_ITEM                       ; 8 goes, so 15 becomes smallest again
    CALL POP_ITEM
    CALL POP_ITEM
    CALL POP_ITEM

    MOV AH, 4CH
    INT 21H

; -----------------------------------------------------------------------------
; PUSH_ITEM
;
; Stores AX, and beside it the smallest value anywhere in the stack including
; this one. That second array is what makes the minimum free to read.
; -----------------------------------------------------------------------------
PUSH_ITEM PROC
    PUSH AX
    PUSH BX
    PUSH DX

    MOV BX, DEPTH
    SHL BX, 1
    MOV VALUES[BX], AX

    ; -------------------------------------------------------------------------
    ; THE NEW MINIMUM IS THE SMALLER OF THIS VALUE AND WHATEVER THE MINIMUM
    ; WAS BEFORE. THE FIRST ITEM HAS NOTHING TO COMPARE AGAINST, SO IT IS THE
    ; MINIMUM BY DEFINITION.
    ; -------------------------------------------------------------------------
    CMP WORD PTR DEPTH, 0
    JE  PI_FIRST

    MOV DX, MINIMA[BX-2]                ; The minimum one level down
    CMP AX, DX
    JBE PI_STORE_MIN
    MOV AX, DX                          ; The old minimum is still smaller

PI_STORE_MIN:
    MOV MINIMA[BX], AX
    JMP PI_COUNTED

PI_FIRST:
    MOV MINIMA[BX], AX

PI_COUNTED:
    INC WORD PTR DEPTH

    POP DX
    POP BX
    POP AX

    PUSH AX
    PUSH DX
    LEA DX, M_PUSH
    MOV AH, 09H
    INT 21H
    POP DX
    POP AX
    PUSH AX
    CALL PRINT_DECIMAL
    POP AX
    CALL SHOW_MINIMUM
    RET
PUSH_ITEM ENDP

; -----------------------------------------------------------------------------
; POP_ITEM
; -----------------------------------------------------------------------------
POP_ITEM PROC
    PUSH AX
    PUSH BX
    PUSH DX

    CMP WORD PTR DEPTH, 0
    JE  PO_EMPTY

    DEC WORD PTR DEPTH
    MOV BX, DEPTH
    SHL BX, 1
    MOV AX, VALUES[BX]

    PUSH AX
    LEA DX, M_POP
    MOV AH, 09H
    INT 21H
    POP AX
    CALL PRINT_DECIMAL
    CALL SHOW_MINIMUM
    JMP PO_DONE

PO_EMPTY:
    LEA DX, M_NONE
    MOV AH, 09H
    INT 21H

PO_DONE:
    POP DX
    POP BX
    POP AX
    RET
POP_ITEM ENDP

; -----------------------------------------------------------------------------
; SHOW_MINIMUM
;
; Reads the smallest value straight out of the parallel array. No search.
; -----------------------------------------------------------------------------
SHOW_MINIMUM PROC
    PUSH AX
    PUSH BX
    PUSH DX

    CMP WORD PTR DEPTH, 0
    JE  SM_EMPTY

    LEA DX, M_MIN
    MOV AH, 09H
    INT 21H

    MOV BX, DEPTH
    DEC BX
    SHL BX, 1
    MOV AX, MINIMA[BX]
    CALL PRINT_DECIMAL
    CALL NEWLINE
    JMP SM_DONE

SM_EMPTY:
    LEA DX, M_NONE
    MOV AH, 09H
    INT 21H

SM_DONE:
    POP DX
    POP BX
    POP AX
    RET
SHOW_MINIMUM ENDP

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
; 1. SPACE TRADED FOR TIME:
;    - One extra word per item makes the smallest value free to read.
;    - Searching for it instead would cost a pass over the whole stack
;    - every time it was asked for.
; 2. WHY IT SURVIVES A POP:
;    - Each level records the minimum as it stood then, so removing an
;    - item uncovers the answer that was already correct at that depth.
;    - Nothing has to be recomputed.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
