; =============================================================================
; TITLE: First-In-First-Out (FIFO) Queue Implementation
; DESCRIPTION: This program implements a linear queue data structure using 
;              an array. It provides procedures for ENQUEUE (Insertion) and 
;              DEQUEUE (Deletion), managing FRONT and REAR pointers to track 
;              data flow.
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
    QUEUE_BUF  DB 5 DUP(0)              ; Queue storage (Size: 5 bytes)
    MSG_EMPTY  DB 0DH, 0AH, "Status: Queue is EMPTY!$"
    MSG_FULL   DB 0DH, 0AH, "Status: Queue is FULL!$"
    MSG_ENQ    DB 0DH, 0AH, "Enqueued Value: $"
    MSG_DEQ    DB 0DH, 0AH, "Dequeued Value: $"
    
    ; Pointers (0-based Index)
    ; FRONT: Points to the element to be removed next
    ; REAR:  Points to the last inserted element
    VAR_FRONT  DB -1                    
    VAR_REAR   DB -1                    
    
    VAR_VALUE  DB ?                     ; Temporary buffer for I/O

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
MAIN PROC
    ; --- Step 1: Initialize Segment ---
    MOV AX, @DATA
    MOV DS, AX
    
    ; --- Step 2: Queue Operations Demonstration ---
    
    ; Test 1: Insert 'A' (41H)
    MOV AL, 'A'
    CALL ENQUEUE
    
    ; Test 2: Insert 'B' (42H)
    MOV AL, 'B'
    CALL ENQUEUE
    
    ; Test 3: Remove Item (Should be 'A')
    CALL DEQUEUE
    
    ; Test 4: Remove Item (Should be 'B')
    CALL DEQUEUE
    
    ; Test 5: Remove from Empty Queue (Underflow check)
    CALL DEQUEUE
    
    ; --- Step 3: Shutdown ---
    MOV AH, 4CH
    INT 21H
MAIN ENDP

; -----------------------------------------------------------------------------
; PROCEDURE: ENQUEUE
; INPUT:  AL = Value to insert
; OUTPUT: Updates QUEUE_BUF and REAR. Prints error if FULL.
; -----------------------------------------------------------------------------
ENQUEUE PROC
    PUSH AX
    PUSH BX
    PUSH SI
    
    ; Check Overflow: Is REAR == SIZE - 1?
    MOV BL, VAR_REAR
    CMP BL, 4                           ; Max Index = 4
    JE L_QUEUE_FULL
    
    ; If Empty (FRONT == -1), set FRONT to 0
    CMP VAR_FRONT, -1
    JNE L_INC_REAR
    MOV VAR_FRONT, 0
    
L_INC_REAR:
    INC VAR_REAR                        ; Move REAR forward
    MOV BL, VAR_REAR
    XOR BH, BH                          ; BX = REAR Index
    
    ; Access QUEUE_BUF[REAR]
    LEA SI, QUEUE_BUF
    ADD SI, BX
    
    ; Store Value
    POP SI                              ; Restore SI (Stack trickery avoided by re-loading AL)
    POP BX
    POP AX                              ; Restore original AL value
    PUSH AX                             ; Save again for printing
    
    MOV BX,0                            ; Reset BX for offset calc (simplified above)
    MOV BL, VAR_REAR
    MOV QUEUE_BUF[BX], AL
    
    ; Feedback
    PUSH AX
    LEA DX, MSG_ENQ
    MOV AH, 09H
    INT 21H
    POP AX
    
    MOV DL, AL
    MOV AH, 02H
    INT 21H
    
    JMP L_ENQ_DONE

L_QUEUE_FULL:
    LEA DX, MSG_FULL
    MOV AH, 09H
    INT 21H

L_ENQ_DONE:
    POP SI
    POP BX
    POP AX
    RET
ENQUEUE ENDP

; -----------------------------------------------------------------------------
; PROCEDURE: DEQUEUE
; OUTPUT: Prints value. Updates FRONT. Prints error if EMPTY.
; -----------------------------------------------------------------------------
DEQUEUE PROC
    PUSH AX
    PUSH BX
    
    ; Check Underflow: Is FRONT == -1?
    CMP VAR_FRONT, -1
    JE L_QUEUE_EMPTY
    
    ; Retrieve Value at FRONT
    MOV BL, VAR_FRONT
    XOR BH, BH
    MOV AL, QUEUE_BUF[BX]
    MOV VAR_VALUE, AL
    
    ; Feedback
    LEA DX, MSG_DEQ
    MOV AH, 09H
    INT 21H
    
    MOV DL, VAR_VALUE
    MOV AH, 02H
    INT 21H
    
    ; Check if Queue is now empty (FRONT == REAR)
    MOV BL, VAR_FRONT
    CMP BL, VAR_REAR
    JE L_RESET_QUEUE
    
    INC VAR_FRONT                       ; Move FRONT forward
    JMP L_DEQ_DONE
    
L_RESET_QUEUE:
    ; Reset pointers to initial state
    MOV VAR_FRONT, -1
    MOV VAR_REAR, -1
    JMP L_DEQ_DONE
    
L_QUEUE_EMPTY:
    LEA DX, MSG_EMPTY
    MOV AH, 09H
    INT 21H

L_DEQ_DONE:
    POP BX
    POP AX
    RET
DEQUEUE ENDP

END MAIN 

; =============================================================================
; TECHNICAL NOTES & ARCHITECTURAL INSIGHTS
; =============================================================================
; 1. QUEUE MECHANICS (LINEAR):
;    This is a "Linear Queue".
;    - Insertion happens at the REAR.
;    - Removal happens at the FRONT.
;    - Limitation: Once REAR reaches the end, space freed at the front 
;      cannot be reused without shifting elements (or using a Circular Queue).
;
; 2. POINTER MANAGEMENT:
;    - Initial state: FRONT = -1, REAR = -1.
;    - First Element: FRONT = 0, REAR = 0.
;    - Enqueue: REAR++
;    - Dequeue: FRONT++
;    - Reset: When FRONT == REAR during Dequeue, reset both to -1.
;
; 3. MEMORY ADDRESSING:
;    'QUEUE_BUF[BX]' uses Based Addressing. BX holds the dynamic index (offset 
;    from the start of the array).
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
