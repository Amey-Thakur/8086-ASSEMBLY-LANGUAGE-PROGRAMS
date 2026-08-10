; =============================================================================
; TITLE: A Binary Tree Held in an Array
; DESCRIPTION: Stores a complete tree without any pointers, using the fact that
;              a node at index i has its children at 2i+1 and 2i+2.
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
    ; The tree
    ;              50
    ;         30        70
    ;      20   40   60    80
    TREE    DW 50, 30, 70, 20, 40, 60, 80
    NODES   EQU 7

    M_ROOT  DB 'Root:      $'
    M_INORD DB 'In order:  $'
    M_PRE   DB 'Pre order: $'
    M_DEPTH DB 'Depth:     $'
    SPACE   DB ' $'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA DX, M_ROOT
    MOV AH, 09H
    INT 21H
    MOV AX, TREE[0]
    CALL PRINT_DECIMAL
    CALL NEWLINE

    ; -------------------------------------------------------------------------
    ; NO POINTERS ANYWHERE. THE CHILDREN OF NODE I ARE AT 2I+1 AND 2I+2, AND
    ; ITS PARENT IS AT (I-1)/2. A COMPLETE TREE THEREFORE COSTS NOTHING BEYOND
    ; THE VALUES THEMSELVES, WHICH IS WHY A HEAP IS STORED THIS WAY.
    ; -------------------------------------------------------------------------
    LEA DX, M_INORD
    MOV AH, 09H
    INT 21H
    XOR AX, AX
    CALL IN_ORDER
    CALL NEWLINE

    LEA DX, M_PRE
    MOV AH, 09H
    INT 21H
    XOR AX, AX
    CALL PRE_ORDER
    CALL NEWLINE

    LEA DX, M_DEPTH
    MOV AH, 09H
    INT 21H
    XOR AX, AX
    CALL TREE_DEPTH
    CALL PRINT_DECIMAL
    CALL NEWLINE

    MOV AH, 4CH
    INT 21H

; -----------------------------------------------------------------------------
; IN_ORDER
;
; Visits the left subtree, then the node, then the right. For a search tree
; that produces the values in order, which is the point of the traversal.
; -----------------------------------------------------------------------------
IN_ORDER PROC
    PUSH AX
    PUSH BX
    PUSH DX

    CMP AX, NODES
    JAE IO_DONE                         ; Off the end of the tree

    MOV BX, AX

    ; Left child, at twice the index plus one
    SHL AX, 1
    INC AX
    CALL IN_ORDER

    ; This node
    PUSH BX
    SHL BX, 1
    MOV AX, TREE[BX]
    CALL PRINT_DECIMAL
    LEA DX, SPACE
    MOV AH, 09H
    INT 21H
    POP BX

    ; Right child, at twice the index plus two
    MOV AX, BX
    SHL AX, 1
    ADD AX, 2
    CALL IN_ORDER

IO_DONE:
    POP DX
    POP BX
    POP AX
    RET
IN_ORDER ENDP

; -----------------------------------------------------------------------------
; PRE_ORDER
;
; Visits the node first, then its subtrees. This is the order a tree has to be
; written down in if it is to be rebuilt from the list.
; -----------------------------------------------------------------------------
PRE_ORDER PROC
    PUSH AX
    PUSH BX
    PUSH DX

    CMP AX, NODES
    JAE PO_DONE

    MOV BX, AX

    PUSH BX
    SHL BX, 1
    MOV AX, TREE[BX]
    CALL PRINT_DECIMAL
    LEA DX, SPACE
    MOV AH, 09H
    INT 21H
    POP BX

    MOV AX, BX
    SHL AX, 1
    INC AX
    CALL PRE_ORDER

    MOV AX, BX
    SHL AX, 1
    ADD AX, 2
    CALL PRE_ORDER

PO_DONE:
    POP DX
    POP BX
    POP AX
    RET
PRE_ORDER ENDP

; -----------------------------------------------------------------------------
; TREE_DEPTH
;
; Returns in AX how many levels there are below and including node AX.
; -----------------------------------------------------------------------------
TREE_DEPTH PROC
    PUSH BX
    PUSH CX

    CMP AX, NODES
    JAE TD_EMPTY

    MOV BX, AX

    SHL AX, 1
    INC AX
    CALL TREE_DEPTH
    MOV CX, AX                          ; The left depth

    MOV AX, BX
    SHL AX, 1
    ADD AX, 2
    CALL TREE_DEPTH                     ; The right depth

    CMP AX, CX
    JAE TD_HAVE_MAX
    MOV AX, CX

TD_HAVE_MAX:
    INC AX                              ; This level counts too
    JMP TD_DONE

TD_EMPTY:
    XOR AX, AX

TD_DONE:
    POP CX
    POP BX
    RET
TREE_DEPTH ENDP

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
; 1. THE ARITHMETIC REPLACES THE POINTERS:
;    - Both child indices are one shift and one addition, so a traversal
;    - costs no memory reads beyond the values themselves.
; 2. ONLY FOR A COMPLETE TREE:
;    - A tree with gaps wastes a slot for every missing node, and a long
;    - thin tree would need an array exponentially larger than the number
;    - of nodes. Pointers exist for that case.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
