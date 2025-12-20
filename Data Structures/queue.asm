;=============================================================================
; Program:     Queue Implementation (FIFO)
; Description: Implement a circular queue data structure using an array.
;              Demonstrates First-In-First-Out (FIFO) operations.
; 
; Author:      Amey Thakur
; Repository:  https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
; License:     MIT License
;=============================================================================

.MODEL SMALL
.STACK 100H

;-----------------------------------------------------------------------------
; DATA SEGMENT
;-----------------------------------------------------------------------------
.DATA
    QUEUE DB 10 DUP(0)                  ; Queue array (10 elements)
    FRONT DW 0                          ; Index of front element
    REAR DW 0                           ; Index of next insertion point
    SIZE DW 0                           ; Current number of elements
    MAX_SIZE EQU 10                     ; Maximum queue capacity
    
    MSG_FULL DB 'Queue is full!$'
    MSG_EMPTY DB 'Queue is empty!$'
    MSG_ENQUEUE DB 'Element added$'
    MSG_DEQUEUE DB 'Element removed$'
    NEWLINE DB 0DH, 0AH, '$'

;-----------------------------------------------------------------------------
; CODE SEGMENT
;-----------------------------------------------------------------------------
.CODE

;-----------------------------------------------------------------------------
; ENQUEUE: Add element to rear of queue
; Input: AL = element to add
;-----------------------------------------------------------------------------
ENQUEUE PROC
    ; Check if queue is full
    CMP SIZE, MAX_SIZE
    JE QUEUE_FULL
    
    ; Add element at REAR position
    MOV BX, REAR
    MOV QUEUE[BX], AL                   ; Store element
    INC REAR                            ; Move rear pointer
    
    ; Circular wrap-around
    CMP REAR, MAX_SIZE
    JL NO_WRAP_R
    MOV REAR, 0                         ; Wrap to beginning
NO_WRAP_R:
    INC SIZE                            ; Increment count
    
    ; Display confirmation
    LEA DX, MSG_ENQUEUE
    MOV AH, 09H
    INT 21H
    LEA DX, NEWLINE
    MOV AH, 09H
    INT 21H
    RET
    
QUEUE_FULL:
    LEA DX, MSG_FULL
    MOV AH, 09H
    INT 21H
    LEA DX, NEWLINE
    MOV AH, 09H
    INT 21H
    RET
ENQUEUE ENDP

;-----------------------------------------------------------------------------
; DEQUEUE: Remove element from front of queue
; Output: AL = element removed
;-----------------------------------------------------------------------------
DEQUEUE PROC
    ; Check if queue is empty
    CMP SIZE, 0
    JE QUEUE_EMPTY
    
    ; Remove element from FRONT position
    MOV BX, FRONT
    MOV AL, QUEUE[BX]                   ; Get element
    INC FRONT                           ; Move front pointer
    
    ; Circular wrap-around
    CMP FRONT, MAX_SIZE
    JL NO_WRAP_F
    MOV FRONT, 0                        ; Wrap to beginning
NO_WRAP_F:
    DEC SIZE                            ; Decrement count
    
    ; Display confirmation
    LEA DX, MSG_DEQUEUE
    MOV AH, 09H
    INT 21H
    LEA DX, NEWLINE
    MOV AH, 09H
    INT 21H
    RET
    
QUEUE_EMPTY:
    LEA DX, MSG_EMPTY
    MOV AH, 09H
    INT 21H
    LEA DX, NEWLINE
    MOV AH, 09H
    INT 21H
    RET
DEQUEUE ENDP

;-----------------------------------------------------------------------------
; MAIN: Test queue operations
;-----------------------------------------------------------------------------
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX
    
    ; Enqueue elements: 10, 20, 30
    MOV AL, 10
    CALL ENQUEUE
    MOV AL, 20
    CALL ENQUEUE
    MOV AL, 30
    CALL ENQUEUE
    
    ; Dequeue one element (removes 10)
    CALL DEQUEUE
    
    ; Exit to DOS
    MOV AH, 4CH
    INT 21H
MAIN ENDP
END MAIN

;=============================================================================
; QUEUE (FIFO) DATA STRUCTURE:
; - First-In-First-Out ordering
; - ENQUEUE adds to REAR
; - DEQUEUE removes from FRONT
; - Circular implementation: rear wraps around to use freed space
; - Applications: Task scheduling, printer queues, BFS traversal
;=============================================================================
