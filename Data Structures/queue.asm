; Program: Queue Implementation
; Description: Implement a simple queue (FIFO) data structure
; Author: Amey Thakur

.MODEL SMALL
.STACK 100H

.DATA
    QUEUE DB 10 DUP(0)
    FRONT DW 0
    REAR DW 0
    SIZE DW 0
    MAX_SIZE EQU 10
    MSG_FULL DB 'Queue is full!$'
    MSG_EMPTY DB 'Queue is empty!$'
    MSG_ENQUEUE DB 'Element added$'
    MSG_DEQUEUE DB 'Element removed$'

.CODE
; Enqueue Procedure
; Input: AL = element to add
ENQUEUE PROC
    CMP SIZE, MAX_SIZE
    JE QUEUE_FULL
    
    MOV BX, REAR
    MOV QUEUE[BX], AL
    INC REAR
    CMP REAR, MAX_SIZE
    JL NO_WRAP_R
    MOV REAR, 0      ; Circular wrap
NO_WRAP_R:
    INC SIZE
    
    LEA DX, MSG_ENQUEUE
    MOV AH, 09H
    INT 21H
    RET
    
QUEUE_FULL:
    LEA DX, MSG_FULL
    MOV AH, 09H
    INT 21H
    RET
ENQUEUE ENDP

; Dequeue Procedure
; Output: AL = element removed
DEQUEUE PROC
    CMP SIZE, 0
    JE QUEUE_EMPTY
    
    MOV BX, FRONT
    MOV AL, QUEUE[BX]
    INC FRONT
    CMP FRONT, MAX_SIZE
    JL NO_WRAP_F
    MOV FRONT, 0     ; Circular wrap
NO_WRAP_F:
    DEC SIZE
    
    LEA DX, MSG_DEQUEUE
    MOV AH, 09H
    INT 21H
    RET
    
QUEUE_EMPTY:
    LEA DX, MSG_EMPTY
    MOV AH, 09H
    INT 21H
    RET
DEQUEUE ENDP

MAIN PROC
    MOV AX, @DATA
    MOV DS, AX
    
    ; Enqueue some elements
    MOV AL, 10
    CALL ENQUEUE
    MOV AL, 20
    CALL ENQUEUE
    MOV AL, 30
    CALL ENQUEUE
    
    ; Dequeue an element
    CALL DEQUEUE
    
    MOV AH, 4CH      ; Exit to DOS
    INT 21H
MAIN ENDP
END MAIN
