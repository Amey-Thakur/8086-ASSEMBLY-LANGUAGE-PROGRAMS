;=============================================================================
; Program:     For Loop Structure
; Description: Implement for loop logic in assembly.
;              Demonstrates initialization, condition, and increment.
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
    MSG DB 'For loop iteration: $'
    NEWLINE DB 0DH, 0AH, '$'

;-----------------------------------------------------------------------------
; CODE SEGMENT
; 
; High-level equivalent:
;   for (i = 1; i <= 5; i++)
;       print i
;-----------------------------------------------------------------------------
.CODE
MAIN PROC
    ; Initialize Data Segment
    MOV AX, @DATA
    MOV DS, AX
    
    ;-------------------------------------------------------------------------
    ; FOR Loop: Initialization
    ; i = 1 (using BL as loop counter)
    ;-------------------------------------------------------------------------
    MOV BL, 1                           ; Initialize counter
    
FOR_START:
    ;-------------------------------------------------------------------------
    ; FOR Loop: Condition Check
    ; i <= 5
    ;-------------------------------------------------------------------------
    CMP BL, 5                           ; Compare i with 5
    JG FOR_END                          ; If i > 5, exit loop
    
    ;-------------------------------------------------------------------------
    ; Loop Body
    ;-------------------------------------------------------------------------
    ; Display message
    LEA DX, MSG
    MOV AH, 09H
    INT 21H
    
    ; Display counter value
    MOV DL, BL
    ADD DL, '0'                         ; Convert to ASCII
    MOV AH, 02H
    INT 21H
    
    ; Newline
    LEA DX, NEWLINE
    MOV AH, 09H
    INT 21H
    
    ;-------------------------------------------------------------------------
    ; FOR Loop: Increment
    ; i++
    ;-------------------------------------------------------------------------
    INC BL                              ; Increment counter
    
    ;-------------------------------------------------------------------------
    ; Jump back to condition check
    ;-------------------------------------------------------------------------
    JMP FOR_START
    
FOR_END:
    ;-------------------------------------------------------------------------
    ; Program Termination
    ;-------------------------------------------------------------------------
    MOV AH, 4CH                         ; DOS: Terminate program
    INT 21H
MAIN ENDP
END MAIN

;=============================================================================
; FOR LOOP PATTERN IN ASSEMBLY
;=============================================================================
; 
; High-level:                      Assembly equivalent:
; ---------------------------      ---------------------
; for (init; cond; incr)           ; init
;     loop_body                FOR_START:
;                                  ; cond check
;                                  Jcc FOR_END      ; Exit if FALSE
;                                  ; loop_body
;                                  ; incr
;                                  JMP FOR_START
;                              FOR_END:
; 
; OPTIMIZATION: Use LOOP instruction when counting down:
;   MOV CX, 5          ; Count
; LOOP_START:
;   ; body
;   LOOP LOOP_START    ; CX--, jump if CX != 0
;=============================================================================
