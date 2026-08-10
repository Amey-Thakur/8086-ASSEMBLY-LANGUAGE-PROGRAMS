; =============================================================================
; TITLE: A Linked List Built in Memory
; DESCRIPTION: Builds a chain of nodes that each hold a value and the offset of
;              the next, then walks it and inserts into the middle.
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
    ; Each node is four bytes: a word of value and a word holding the offset
    ; of the next node. An offset of zero means there is no next node, which
    ; is why node zero is never used for data.
    NODES    DW 40 DUP(0)
    FREE     DW 4                       ; The first unused node, in bytes
    LIST     DW 0                       ; The offset of the first node

    M_BUILT  DB 'The list:          $'
    M_AFTER  DB 'After inserting:   $'
    M_LENGTH DB 'Nodes: $'
    ARROW    DB ' -> $'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    ; Build 10, 20, 40
    MOV AX, 10
    CALL APPEND
    MOV AX, 20
    CALL APPEND
    MOV AX, 40
    CALL APPEND

    LEA DX, M_BUILT
    MOV AH, 09H
    INT 21H
    CALL WALK

    ; -------------------------------------------------------------------------
    ; INSERTING AFTER A NODE IS TWO WRITES AND NO MOVEMENT: THE NEW NODE
    ; POINTS WHERE THE OLD ONE DID, AND THE OLD ONE POINTS AT THE NEW. THAT IS
    ; THE ADVANTAGE A LIST HAS OVER AN ARRAY.
    ; -------------------------------------------------------------------------
    MOV AX, 20                          ; Find the node holding 20
    CALL FIND
    MOV BX, AX                          ; Its offset
    MOV AX, 30
    CALL INSERT_AFTER

    LEA DX, M_AFTER
    MOV AH, 09H
    INT 21H
    CALL WALK

    MOV AH, 4CH
    INT 21H

; -----------------------------------------------------------------------------
; APPEND
;
; Adds AX to the end of the list.
; -----------------------------------------------------------------------------
APPEND PROC
    PUSH AX
    PUSH BX
    PUSH SI

    ; Take a node from the free space
    MOV BX, FREE
    MOV NODES[BX], AX                   ; The value
    MOV WORD PTR NODES[BX+2], 0         ; No next node yet
    ADD WORD PTR FREE, 4

    CMP WORD PTR LIST, 0
    JNE AP_FIND_END

    MOV LIST, BX                        ; The list was empty
    JMP AP_DONE

AP_FIND_END:
    MOV SI, LIST

AP_WALK:
    CMP WORD PTR NODES[SI+2], 0
    JE  AP_LINK
    MOV SI, NODES[SI+2]
    JMP AP_WALK

AP_LINK:
    MOV NODES[SI+2], BX

AP_DONE:
    POP SI
    POP BX
    POP AX
    RET
APPEND ENDP

; -----------------------------------------------------------------------------
; FIND
;
; Returns in AX the offset of the first node holding the value in AX, or zero.
; -----------------------------------------------------------------------------
FIND PROC
    PUSH BX
    PUSH SI

    MOV BX, AX
    MOV SI, LIST

F_LOOP:
    OR  SI, SI
    JZ  F_MISSING

    CMP NODES[SI], BX
    JE  F_FOUND

    MOV SI, NODES[SI+2]
    JMP F_LOOP

F_FOUND:
    MOV AX, SI
    JMP F_DONE

F_MISSING:
    XOR AX, AX

F_DONE:
    POP SI
    POP BX
    RET
FIND ENDP

; -----------------------------------------------------------------------------
; INSERT_AFTER
;
; Puts AX into a new node placed after the node whose offset is in BX.
; -----------------------------------------------------------------------------
INSERT_AFTER PROC
    PUSH AX
    PUSH BX
    PUSH SI

    OR  BX, BX
    JZ  IA_DONE                         ; Nothing to insert after

    MOV SI, FREE
    MOV NODES[SI], AX                   ; The new node's value
    ADD WORD PTR FREE, 4

    MOV AX, NODES[BX+2]                 ; Whatever came next
    MOV NODES[SI+2], AX                 ; now follows the new node
    MOV NODES[BX+2], SI                 ; and the new node follows this one

IA_DONE:
    POP SI
    POP BX
    POP AX
    RET
INSERT_AFTER ENDP

; -----------------------------------------------------------------------------
; WALK
;
; Prints every value in the list, following the links.
; -----------------------------------------------------------------------------
WALK PROC
    PUSH AX
    PUSH CX
    PUSH DX
    PUSH SI

    MOV SI, LIST
    XOR CX, CX                          ; How many nodes were seen

W_LOOP:
    OR  SI, SI
    JZ  W_END

    MOV AX, NODES[SI]
    PUSH SI
    PUSH CX
    CALL PRINT_DECIMAL
    LEA DX, ARROW
    MOV AH, 09H
    INT 21H
    POP CX
    POP SI

    INC CX
    MOV SI, NODES[SI+2]
    JMP W_LOOP

W_END:
    PUSH CX
    LEA DX, M_LENGTH
    MOV AH, 09H
    INT 21H
    POP AX
    CALL PRINT_DECIMAL
    CALL NEWLINE

    POP SI
    POP DX
    POP CX
    POP AX
    RET
WALK ENDP

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
; 1. ZERO STANDS FOR NOTHING:
;    - There is no null on this processor, so a convention is needed. Node
;    - zero is left unused so that an offset of zero can safely mean the
;    - end of the chain.
; 2. THE COST OF THE FLEXIBILITY:
;    - Every node carries a pointer, so a list of words uses twice the
;    - memory of an array. Reaching the tenth element takes ten steps
;    - rather than one calculation. Insertion is what it buys.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
