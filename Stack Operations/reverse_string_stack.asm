;=============================================================================
; Program:     Reverse String (Stack Implementation)
; Description: Utilize the stack's LIFO property to reverse a string's
;              character order.
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
    STR1    DB 'HELLO', '$'
    STR_LEN EQU 5
    NEWLINE DB 0DH, 0AH, '$'
    MSG_ORIG DB 'Original: $'
    MSG_REV  DB 'Reversed: $'

;-----------------------------------------------------------------------------
; CODE SEGMENT
;-----------------------------------------------------------------------------
.CODE
MAIN PROC
    ; Setup Segment
    MOV AX, @DATA
    MOV DS, AX
    
    ; 1. Display Header
    LEA DX, MSG_ORIG
    MOV AH, 09H
    INT 21H
    LEA DX, STR1
    INT 21H
    
    ; 2. PUSH PHASE
    ; Push each character of the string onto the stack.
    LEA SI, STR1
    MOV CX, STR_LEN
PUSHING:
    MOV AL, [SI]                        ; Fetch char
    XOR AH, AH                          ; Clear high byte (Stack needs 16-bit)
    PUSH AX                             ; Push Word
    INC SI
    LOOP PUSHING
    
    ; Newline
    LEA DX, NEWLINE
    MOV AH, 09H
    INT 21H
    
    ; Label
    LEA DX, MSG_REV
    INT 21H
    
    ; 3. POP PHASE
    ; Pop values back. Since the stack is LIFO, the last char comes out first.
    MOV CX, STR_LEN
POPPING:
    POP AX                              ; Get char back (reversed order)
    MOV DL, AL
    MOV AH, 02H                         ; Print char in DL
    INT 21H
    LOOP POPPING
    
    ; Termination
    MOV AH, 4CH
    INT 21H
MAIN ENDP
END MAIN

;=============================================================================
; REVERSAL LOGIC NOTES:
; - Stack is the ideal data structure for any "Reverse" operation.
; - Pushing 'H', 'E', 'L', 'L', 'O' results in 'O' being at the top.
; - Popping 'O', 'L', 'L', 'E', 'H' effectively reverses the sequence.
;=============================================================================
