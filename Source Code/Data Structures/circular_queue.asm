; =============================================================================
; TITLE: Circular Queue
; DESCRIPTION: A fixed buffer used as a queue, where the head and tail wrap
;              round the end so the space is reused instead of running out.
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
    CAPACITY EQU 5
    BUFFER   DW CAPACITY DUP(0)
    HEAD     DW 0                       ; Where the next value leaves
    TAIL     DW 0                       ; Where the next value arrives
    COUNT    DW 0                       ; How many are in it

    M_ADD    DB 'added   $'
    M_TAKE   DB 'removed $'
    M_FULL   DB 'the queue is full, so 60 was refused', 0DH, 0AH, '$'
    M_EMPTY  DB 'the queue is empty', 0DH, 0AH, '$'
    M_STATE  DB '   holding: $'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    ; Fill it to capacity
    MOV AX, 10
    CALL ENQUEUE
    MOV AX, 20
    CALL ENQUEUE
    MOV AX, 30
    CALL ENQUEUE
    MOV AX, 40
    CALL ENQUEUE
    MOV AX, 50
    CALL ENQUEUE

    ; One more than it can hold
    MOV AX, 60
    CALL ENQUEUE

    ; Take two out, which frees the space at the front
    CALL DEQUEUE
    CALL DEQUEUE

    ; -------------------------------------------------------------------------
    ; THE POINT OF THE CIRCLE: THE TWO SLOTS JUST FREED ARE AT THE START OF
    ; THE BUFFER, AND THE TAIL HAS ALREADY REACHED THE END. WRAPPING LETS THEM
    ; BE REUSED WITHOUT MOVING ANYTHING.
    ; -------------------------------------------------------------------------
    MOV AX, 60
    CALL ENQUEUE
    MOV AX, 70
    CALL ENQUEUE

    CALL DEQUEUE
    CALL DEQUEUE
    CALL DEQUEUE
    CALL DEQUEUE
    CALL DEQUEUE
    CALL DEQUEUE

    MOV AH, 4CH
    INT 21H

; -----------------------------------------------------------------------------
; ENQUEUE
;
; Adds AX to the queue, or reports that there was no room.
; -----------------------------------------------------------------------------
ENQUEUE PROC
    PUSH AX
    PUSH BX
    PUSH DX

    MOV BX, COUNT
    CMP BX, CAPACITY
    JAE EQ_FULL

    MOV BX, TAIL
    SHL BX, 1
    MOV BUFFER[BX], AX

    INC WORD PTR TAIL
    MOV BX, TAIL
    CMP BX, CAPACITY
    JB  EQ_NO_WRAP
    MOV WORD PTR TAIL, 0                ; Round the end and back to the start

EQ_NO_WRAP:
    INC WORD PTR COUNT

    PUSH AX
    LEA DX, M_ADD
    MOV AH, 09H
    INT 21H
    POP AX
    CALL PRINT_DECIMAL
    CALL SHOW_CONTENTS
    JMP EQ_DONE

EQ_FULL:
    LEA DX, M_FULL
    MOV AH, 09H
    INT 21H

EQ_DONE:
    POP DX
    POP BX
    POP AX
    RET
ENQUEUE ENDP

; -----------------------------------------------------------------------------
; DEQUEUE
;
; Takes the oldest value out, or reports that there was none.
; -----------------------------------------------------------------------------
DEQUEUE PROC
    PUSH AX
    PUSH BX
    PUSH DX

    CMP WORD PTR COUNT, 0
    JE  DQ_EMPTY

    MOV BX, HEAD
    SHL BX, 1
    MOV AX, BUFFER[BX]

    INC WORD PTR HEAD
    MOV BX, HEAD
    CMP BX, CAPACITY
    JB  DQ_NO_WRAP
    MOV WORD PTR HEAD, 0

DQ_NO_WRAP:
    DEC WORD PTR COUNT

    PUSH AX
    LEA DX, M_TAKE
    MOV AH, 09H
    INT 21H
    POP AX
    CALL PRINT_DECIMAL
    CALL SHOW_CONTENTS
    JMP DQ_DONE

DQ_EMPTY:
    LEA DX, M_EMPTY
    MOV AH, 09H
    INT 21H

DQ_DONE:
    POP DX
    POP BX
    POP AX
    RET
DEQUEUE ENDP

; -----------------------------------------------------------------------------
; SHOW_CONTENTS
;
; Lists what is in the queue, from the head round to the tail.
; -----------------------------------------------------------------------------
SHOW_CONTENTS PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX

    LEA DX, M_STATE
    MOV AH, 09H
    INT 21H

    MOV CX, COUNT
    JCXZ SC_DONE

    MOV BX, HEAD

SC_LOOP:
    PUSH BX
    SHL BX, 1
    MOV AX, BUFFER[BX]
    POP BX

    PUSH BX
    PUSH CX
    CALL PRINT_DECIMAL
    MOV DL, ' '
    MOV AH, 02H
    INT 21H
    POP CX
    POP BX

    INC BX
    CMP BX, CAPACITY
    JB  SC_NO_WRAP
    XOR BX, BX

SC_NO_WRAP:
    LOOP SC_LOOP

SC_DONE:
    CALL NEWLINE

    POP DX
    POP CX
    POP BX
    POP AX
    RET
SHOW_CONTENTS ENDP

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
; 1. WHY A COUNT AS WELL AS TWO POINTERS:
;    - With only a head and a tail, full and empty look identical: both
;    - have the two pointers equal. A count settles it, at the cost of
;    - one word.
; 2. THE WRAP IS A COMPARISON, NOT A DIVISION:
;    - The pointer only ever advances by one, so testing whether it has
;    - reached the capacity is enough. A modulo would be correct and
;    - eighty times slower.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
