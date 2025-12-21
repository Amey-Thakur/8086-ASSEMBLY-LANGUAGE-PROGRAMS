;=============================================================================
; Program:     While Loop Structure
; Description: Implement while loop logic in assembly.
;              Loop continues while condition is true.
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
    COUNT DW 0                          ; Counter variable
    LIMIT DW 5                          ; Loop limit
    MSG DB 'While loop iteration: $'
    NEWLINE DB 0DH, 0AH, '$'

;-----------------------------------------------------------------------------
; CODE SEGMENT
; 
; High-level equivalent:
;   count = 0
;   while (count < limit)
;       print count
;       count++
;-----------------------------------------------------------------------------
.CODE
MAIN PROC
    ; Initialize Data Segment
    MOV AX, @DATA
    MOV DS, AX
    
WHILE_START:
    ;-------------------------------------------------------------------------
    ; WHILE Condition Check (at START of loop)
    ; If condition is FALSE, exit loop
    ;-------------------------------------------------------------------------
    MOV AX, COUNT                       ; Load counter
    CMP AX, LIMIT                       ; Compare with limit
    JGE WHILE_END                       ; If count >= limit, exit loop
    
    ;-------------------------------------------------------------------------
    ; Loop Body
    ;-------------------------------------------------------------------------
    ; Display message
    LEA DX, MSG
    MOV AH, 09H
    INT 21H
    
    ; Display counter value
    MOV AX, COUNT
    ADD AL, '0'                         ; Convert to ASCII
    MOV DL, AL
    MOV AH, 02H
    INT 21H
    
    ; Newline
    LEA DX, NEWLINE
    MOV AH, 09H
    INT 21H
    
    ;-------------------------------------------------------------------------
    ; Update Counter
    ;-------------------------------------------------------------------------
    INC COUNT                           ; count++
    
    ;-------------------------------------------------------------------------
    ; Jump back to condition check
    ;-------------------------------------------------------------------------
    JMP WHILE_START
    
WHILE_END:
    ;-------------------------------------------------------------------------
    ; Program Termination
    ;-------------------------------------------------------------------------
    MOV AH, 4CH                         ; DOS: Terminate program
    INT 21H
MAIN ENDP
END MAIN

;=============================================================================
; WHILE LOOP PATTERN IN ASSEMBLY
;=============================================================================
; 
; High-level:              Assembly equivalent:
; -------------------      ---------------------
; while (condition)    WHILE_START:
;     loop_body            CMP operand1, operand2
;                          Jcc WHILE_END    ; Exit if FALSE
;                          ; loop_body code
;                          JMP WHILE_START
;                      WHILE_END:
; 
; Key difference from DO-WHILE:
; - WHILE checks condition BEFORE executing body
; - DO-WHILE checks condition AFTER executing body
; - WHILE may execute 0 times, DO-WHILE executes at least once
;=============================================================================
