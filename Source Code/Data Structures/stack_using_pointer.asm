; =============================================================================
; TITLE: A Stack Addressed by Pointer
; DESCRIPTION: The same structure written with a moving pointer rather than an
;              index, which is how it is done when speed matters.
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
    CAPACITY EQU 8
    SPACE_   DW CAPACITY DUP(0)
    TOP      DW 0                       ; Offset of the next free slot
    FLOOR    DW 0                       ; Where the stack begins

    M_PUSH   DB 'push $'
    M_POP    DB 'pop  $'
    M_ROOM   DB '   free slots: $'
    M_FULL   DB 'the stack is full', 0DH, 0AH, '$'
    M_EMPTY  DB 'the stack is empty', 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA AX, SPACE_
    MOV TOP, AX
    MOV FLOOR, AX

    MOV AX, 11
    CALL PUSH_WORD
    MOV AX, 22
    CALL PUSH_WORD
    MOV AX, 33
    CALL PUSH_WORD

    CALL POP_WORD
    CALL POP_WORD
    CALL POP_WORD
    CALL POP_WORD

    MOV AH, 4CH
    INT 21H

; -----------------------------------------------------------------------------
; PUSH_WORD
;
; Stores AX and advances the pointer.
; -----------------------------------------------------------------------------
PUSH_WORD PROC
    PUSH AX
    PUSH BX
    PUSH DX

    ; -------------------------------------------------------------------------
    ; THE POINTER IS AN ADDRESS, NOT AN INDEX, SO STORING IS ONE INSTRUCTION
    ; WITH NO SHIFTING OR ADDING. THAT IS EXACTLY HOW THE PROCESSOR'S OWN
    ; STACK POINTER WORKS.
    ; -------------------------------------------------------------------------
    MOV BX, TOP
    MOV DX, FLOOR
    ADD DX, CAPACITY * 2
    CMP BX, DX
    JAE PW_FULL

    MOV [BX], AX
    ADD WORD PTR TOP, 2

    PUSH AX
    LEA DX, M_PUSH
    MOV AH, 09H
    INT 21H
    POP AX
    CALL PRINT_DECIMAL
    CALL SHOW_ROOM
    JMP PW_DONE

PW_FULL:
    LEA DX, M_FULL
    MOV AH, 09H
    INT 21H

PW_DONE:
    POP DX
    POP BX
    POP AX
    RET
PUSH_WORD ENDP

; -----------------------------------------------------------------------------
; POP_WORD
; -----------------------------------------------------------------------------
POP_WORD PROC
    PUSH AX
    PUSH BX
    PUSH DX

    MOV BX, TOP
    CMP BX, FLOOR
    JBE PO_EMPTY

    SUB WORD PTR TOP, 2
    MOV BX, TOP
    MOV AX, [BX]

    PUSH AX
    LEA DX, M_POP
    MOV AH, 09H
    INT 21H
    POP AX
    CALL PRINT_DECIMAL
    CALL SHOW_ROOM
    JMP PO_DONE

PO_EMPTY:
    LEA DX, M_EMPTY
    MOV AH, 09H
    INT 21H

PO_DONE:
    POP DX
    POP BX
    POP AX
    RET
POP_WORD ENDP

; -----------------------------------------------------------------------------
; SHOW_ROOM
;
; How many slots are still free, worked out from the two pointers.
; -----------------------------------------------------------------------------
SHOW_ROOM PROC
    PUSH AX
    PUSH BX
    PUSH DX

    LEA DX, M_ROOM
    MOV AH, 09H
    INT 21H

    MOV AX, TOP
    SUB AX, FLOOR
    SHR AX, 1                           ; Bytes to items
    MOV BX, CAPACITY
    SUB BX, AX
    MOV AX, BX

    CALL PRINT_DECIMAL
    CALL NEWLINE

    POP DX
    POP BX
    POP AX
    RET
SHOW_ROOM ENDP

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
; 1. AN ADDRESS BEATS AN INDEX:
;    - An index has to be doubled and added to a base every time it is
;    - used. A pointer is already the address, which is why the hardware
;    - stack keeps one.
; 2. THE FLOOR IS NEEDED TOO:
;    - With only a top pointer there is no way to tell an empty stack
;    - from a full one, and nothing to measure the depth against.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
