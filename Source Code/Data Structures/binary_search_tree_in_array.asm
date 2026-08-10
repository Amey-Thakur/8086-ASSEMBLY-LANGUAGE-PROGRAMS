; =============================================================================
; TITLE: A Binary Search Tree Held In Arrays
; DESCRIPTION: Insert and traverse a tree whose links are indices rather than addresses, which is how one is built without a heap.
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
    CAPACITY EQU 12
    NOTHING  EQU 0FFFFH                 ; Stands in for a null link

    VALUES  DW CAPACITY DUP (0)
    LEFT_W  DW CAPACITY DUP (NOTHING)
    RIGHT_W DW CAPACITY DUP (NOTHING)

    USED_W  DW 0                        ; How many nodes have been taken
    ROOT_W  DW NOTHING

    TO_ADD  DW 50, 30, 70, 20, 40, 60, 80, 35
    HOWMANY EQU 8

    LOOKING DW 40, 55

    M_TITLE DB 'A binary search tree with indices instead of pointers', 0DH, 0AH, '$'
    M_ADDED DB 0DH, 0AH, 'Inserted: $'
    M_INORD DB 0DH, 0AH, 'In order:  $'
    M_PREORD DB 0DH, 0AH, 'Pre order: $'
    M_FIND  DB 0DH, 0AH, 'Looking for $'
    M_AT    DB '   found at node $'
    M_DEPTH DB ', depth $'
    M_MISS  DB '   not in the tree', 0DH, 0AH, '$'
    M_NL    DB 0DH, 0AH, '$'
    M_SPACE DB ' $'
    M_NODES DB 0DH, 0AH, 0DH, 0AH, 'Nodes used: $'
    M_OF    DB ' of $'
    M_WHY   DB 0DH, 0AH
            DB 'An in order walk of a search tree always comes out sorted. That '
            DB 'is the property that makes it a search tree rather than merely '
            DB 'a tree.', 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA DX, M_TITLE
    CALL PRINT_MESSAGE

    LEA DX, M_ADDED
    CALL PRINT_MESSAGE

    XOR SI, SI
    MOV CX, HOWMANY

INSERT_EACH:
    MOV AX, TO_ADD[SI]
    CALL PRINT_DECIMAL
    PUSH CX
    LEA DX, M_SPACE
    CALL PRINT_MESSAGE
    POP CX

    MOV AX, TO_ADD[SI]
    PUSH CX
    PUSH SI
    CALL INSERT_VALUE
    POP SI
    POP CX

    ADD SI, 2
    LOOP INSERT_EACH

    ; -------------------------------------------------------------------------
    ; AN IN ORDER WALK VISITS THE LEFT SUBTREE, THEN THE NODE, THEN THE RIGHT.
    ; FOR A SEARCH TREE THAT ALWAYS COMES OUT IN ASCENDING ORDER, WHICH IS THE
    ; EASIEST WAY TO CHECK THE TREE WAS BUILT CORRECTLY.
    ; -------------------------------------------------------------------------
    LEA DX, M_INORD
    CALL PRINT_MESSAGE
    MOV AX, ROOT_W
    CALL WALK_IN_ORDER

    LEA DX, M_PREORD
    CALL PRINT_MESSAGE
    MOV AX, ROOT_W
    CALL WALK_PRE_ORDER

    ; ---- searching -----------------------------------------------------------
    MOV SI, 0
    MOV AX, LOOKING[SI]
    CALL REPORT_SEARCH

    MOV SI, 2
    MOV AX, LOOKING[SI]
    CALL REPORT_SEARCH

    LEA DX, M_NODES
    CALL PRINT_MESSAGE
    MOV AX, USED_W
    CALL PRINT_DECIMAL
    LEA DX, M_OF
    CALL PRINT_MESSAGE
    MOV AX, CAPACITY
    CALL PRINT_DECIMAL

    LEA DX, M_WHY
    CALL PRINT_MESSAGE

    MOV AH, 4CH
    INT 21H

; -----------------------------------------------------------------------------
; INSERT_VALUE
;
; Puts AX into the tree, keeping the search property.
;
; The links are indices into three parallel arrays rather than addresses. That
; is what makes a tree possible at all without somewhere to allocate from: a
; node is a row across the three arrays, and a link is a row number.
; -----------------------------------------------------------------------------
INSERT_VALUE PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    PUSH DI

    ; ---- take the next free node --------------------------------------------
    MOV DI, USED_W
    CMP DI, CAPACITY
    JAE INSERT_DONE                     ; Full, so the value is dropped

    MOV BX, DI
    SHL BX, 1
    MOV VALUES[BX], AX
    MOV LEFT_W[BX], NOTHING
    MOV RIGHT_W[BX], NOTHING
    INC USED_W

    ; ---- the first node becomes the root ------------------------------------
    CMP ROOT_W, NOTHING
    JNE FIND_A_PLACE
    MOV ROOT_W, DI
    JMP INSERT_DONE

FIND_A_PLACE:
    MOV SI, ROOT_W                      ; Walk down from the root

DESCEND:
    MOV BX, SI
    SHL BX, 1
    MOV CX, VALUES[BX]                  ; The value at this node

    CMP AX, CX
    JL GO_LEFT

    ; ---- to the right --------------------------------------------------------
    MOV DX, RIGHT_W[BX]
    CMP DX, NOTHING
    JNE FOLLOW_RIGHT
    MOV RIGHT_W[BX], DI
    JMP INSERT_DONE
FOLLOW_RIGHT:
    MOV SI, DX
    JMP DESCEND

GO_LEFT:
    MOV DX, LEFT_W[BX]
    CMP DX, NOTHING
    JNE FOLLOW_LEFT
    MOV LEFT_W[BX], DI
    JMP INSERT_DONE
FOLLOW_LEFT:
    MOV SI, DX
    JMP DESCEND

INSERT_DONE:
    POP DI
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
INSERT_VALUE ENDP

; -----------------------------------------------------------------------------
; WALK_IN_ORDER
;
; Prints the subtree rooted at AX: left, then this node, then right.
; -----------------------------------------------------------------------------
WALK_IN_ORDER PROC
    PUSH AX
    PUSH BX
    PUSH DX

    CMP AX, NOTHING
    JE WALK_DONE

    MOV BX, AX
    SHL BX, 1

    PUSH AX
    MOV AX, LEFT_W[BX]
    CALL WALK_IN_ORDER
    POP AX

    MOV BX, AX
    SHL BX, 1
    PUSH AX
    MOV AX, VALUES[BX]
    CALL PRINT_DECIMAL
    LEA DX, M_SPACE
    CALL PRINT_MESSAGE
    POP AX

    MOV BX, AX
    SHL BX, 1
    MOV AX, RIGHT_W[BX]
    CALL WALK_IN_ORDER

WALK_DONE:
    POP DX
    POP BX
    POP AX
    RET
WALK_IN_ORDER ENDP

; -----------------------------------------------------------------------------
; WALK_PRE_ORDER
;
; This node, then left, then right. The order an insert sequence would have to
; take to rebuild the same tree.
; -----------------------------------------------------------------------------
WALK_PRE_ORDER PROC
    PUSH AX
    PUSH BX
    PUSH DX

    CMP AX, NOTHING
    JE PRE_DONE

    MOV BX, AX
    SHL BX, 1
    PUSH AX
    MOV AX, VALUES[BX]
    CALL PRINT_DECIMAL
    LEA DX, M_SPACE
    CALL PRINT_MESSAGE
    POP AX

    MOV BX, AX
    SHL BX, 1
    PUSH AX
    MOV AX, LEFT_W[BX]
    CALL WALK_PRE_ORDER
    POP AX

    MOV BX, AX
    SHL BX, 1
    MOV AX, RIGHT_W[BX]
    CALL WALK_PRE_ORDER

PRE_DONE:
    POP DX
    POP BX
    POP AX
    RET
WALK_PRE_ORDER ENDP

; -----------------------------------------------------------------------------
; REPORT_SEARCH
;
; Looks for AX and says where it was found and how deep it lay.
;
; The depth is what a search tree is for: it should be about the logarithm of
; the node count, not the count itself.
; -----------------------------------------------------------------------------
REPORT_SEARCH PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI

    MOV CX, AX                          ; What is being looked for

    LEA DX, M_FIND
    CALL PRINT_MESSAGE
    MOV AX, CX
    CALL PRINT_DECIMAL

    XOR BP, BP                          ; Depth
    MOV SI, ROOT_W

SEARCH_DOWN:
    CMP SI, NOTHING
    JE SEARCH_FAILED

    MOV BX, SI
    SHL BX, 1
    MOV AX, VALUES[BX]

    CMP AX, CX
    JE SEARCH_FOUND

    ; The branch has to be taken before anything else touches the flags. INC
    ; sets the sign and overflow flags, so an increment placed here would leave
    ; JL testing the increment instead of the comparison, and every search would
    ; go the same way regardless of the value.
    JL SEARCH_RIGHT

    INC BP
    MOV SI, LEFT_W[BX]
    JMP SEARCH_DOWN

SEARCH_RIGHT:
    INC BP
    MOV SI, RIGHT_W[BX]
    JMP SEARCH_DOWN

SEARCH_FOUND:
    LEA DX, M_AT
    CALL PRINT_MESSAGE
    MOV AX, SI
    CALL PRINT_DECIMAL
    LEA DX, M_DEPTH
    CALL PRINT_MESSAGE
    MOV AX, BP
    CALL PRINT_DECIMAL
    JMP SEARCH_REPORTED

SEARCH_FAILED:
    LEA DX, M_MISS
    CALL PRINT_MESSAGE

SEARCH_REPORTED:
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
REPORT_SEARCH ENDP

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

; -----------------------------------------------------------------------------
; PRINT_MESSAGE
;
; Prints the dollar terminated string at DS:DX, leaving AX exactly as it was.
;
; Service 09H needs the service number in AH, and AH is the top half of AX. A
; caller that has just computed a result into AX and then sets AH for itself
; destroys that result: 500 becomes 09F4H, which prints as 2548. Doing the call
; in here, around a push and a pop, removes the trap for good.
; -----------------------------------------------------------------------------
PRINT_MESSAGE PROC
    PUSH AX

    MOV AH, 09H
    INT 21H

    POP AX
    RET
PRINT_MESSAGE ENDP

END START

; =============================================================================
; TECHNICAL NOTES
; =============================================================================
; 1. Indices instead of addresses:
;    - A node is a row across three parallel arrays, and a link is a row number.
;    - That removes any need to allocate memory, which an 8086 program has no easy way to do.
;    - FFFFh stands in for a null link, because no index can ever reach it.
; 2. In order comes out sorted:
;    - Left, node, right on a search tree always yields ascending order.
;    - So printing it is the cheapest possible check that the tree was built correctly.
;    - Pre order instead gives the insertion sequence that would rebuild the same shape.
; 3. Depth is the point:
;    - A search tree is worth building only if the depth stays near the logarithm of the size.
;    - These eight values were chosen to give a balanced tree, so the depth is two or three.
;    - Inserting them in ascending order would give a chain of depth seven, and no benefit at all.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
