;=============================================================================
; Program:     Stack Implementation (Using Array)
; Description: Implement a stack data structure using an array.
;              Demonstrates Last-In-First-Out (LIFO) operations.
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
    STACK_ARR DB 10 DUP(0)              ; Stack array (10 elements)
    TOP DW -1                           ; Top pointer (-1 = empty)
    MAX_SIZE EQU 10                     ; Maximum stack capacity
    
    MSG_PUSH DB 'Element pushed$'
    MSG_POP DB 'Element popped$'
    MSG_FULL DB 'Stack Overflow!$'
    MSG_EMPTY DB 'Stack Underflow!$'
    NEWLINE DB 0DH, 0AH, '$'

;-----------------------------------------------------------------------------
; CODE SEGMENT
;-----------------------------------------------------------------------------
.CODE

;-----------------------------------------------------------------------------
; STACK_PUSH: Push element onto stack
; Input: AL = element to push
;-----------------------------------------------------------------------------
STACK_PUSH PROC
    ; Check for overflow
    CMP TOP, MAX_SIZE - 1
    JGE STACK_OVERFLOW
    
    ; Increment TOP and store element
    INC TOP
    MOV BX, TOP
    MOV STACK_ARR[BX], AL               ; Push element
    
    ; Display confirmation
    LEA DX, MSG_PUSH
    MOV AH, 09H
    INT 21H
    LEA DX, NEWLINE
    MOV AH, 09H
    INT 21H
    RET
    
STACK_OVERFLOW:
    LEA DX, MSG_FULL
    MOV AH, 09H
    INT 21H
    LEA DX, NEWLINE
    MOV AH, 09H
    INT 21H
    RET
STACK_PUSH ENDP

;-----------------------------------------------------------------------------
; STACK_POP: Pop element from stack
; Output: AL = element popped
;-----------------------------------------------------------------------------
STACK_POP PROC
    ; Check for underflow
    CMP TOP, -1
    JLE STACK_UNDERFLOW
    
    ; Get element and decrement TOP
    MOV BX, TOP
    MOV AL, STACK_ARR[BX]               ; Pop element
    DEC TOP
    
    ; Display confirmation
    LEA DX, MSG_POP
    MOV AH, 09H
    INT 21H
    LEA DX, NEWLINE
    MOV AH, 09H
    INT 21H
    RET
    
STACK_UNDERFLOW:
    LEA DX, MSG_EMPTY
    MOV AH, 09H
    INT 21H
    LEA DX, NEWLINE
    MOV AH, 09H
    INT 21H
    RET
STACK_POP ENDP

;-----------------------------------------------------------------------------
; MAIN: Test stack operations
;-----------------------------------------------------------------------------
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX
    
    ; Push elements: 10, 20, 30
    MOV AL, 10
    CALL STACK_PUSH
    MOV AL, 20
    CALL STACK_PUSH
    MOV AL, 30
    CALL STACK_PUSH
    
    ; Pop one element (removes 30 - last in, first out)
    CALL STACK_POP
    
    ; Exit to DOS
    MOV AH, 4CH
    INT 21H
MAIN ENDP
END MAIN

;=============================================================================
; STACK (LIFO) DATA STRUCTURE:
; - Last-In-First-Out ordering
; - PUSH adds to TOP
; - POP removes from TOP
; - TOP = -1 indicates empty stack
; - Applications: Expression evaluation, function calls, undo operations
; 
; Note: This is different from the 8086's hardware stack (SS:SP)
;       This is an application-level stack using array
;=============================================================================
