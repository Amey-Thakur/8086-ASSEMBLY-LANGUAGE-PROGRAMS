;=============================================================================
; Program:     Memory Block Fill
; Description: Initialize a block of memory with a specific constant byte 
;              using the STOSB (Store String Byte) instruction.
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
    BUFFER DB 20 DUP(?)                  ; Uninitialized buffer
    B_LEN  EQU 20
    CHAR   DB '*'                        ; Fill value
    MSG    DB 'Memory buffer successfully initialized with fill pattern.$'

;-----------------------------------------------------------------------------
; CODE SEGMENT
;-----------------------------------------------------------------------------
.CODE
MAIN PROC
    ; Segments setup
    MOV AX, @DATA
    MOV DS, AX
    MOV ES, AX                          ; ES is mandatory for STOSB
    
    ;-------------------------------------------------------------------------
    ; STRING STORE SETUP
    ; Pointer: ES:DI
    ; Value: AL
    ;-------------------------------------------------------------------------
    LEA DI, BUFFER                      ; Start address in ES
    MOV AL, CHAR                        ; Load filler value into AL
    MOV CX, B_LEN                       ; Count to fill
    
    CLD                                 ; Increment DI
    
    ; REP STOSB: Repeat 'Store String Byte' while CX > 0
    ; Copies AL to ES:[DI] and increments DI.
    REP STOSB
    
    ; Confirmation message
    LEA DX, MSG
    MOV AH, 09H
    INT 21H
    
    ; Final Exit
    MOV AH, 4CH
    INT 21H
MAIN ENDP
END MAIN

;=============================================================================
; MEMORY FILL NOTES:
; - STOSB is the building block for the 'memset' function found in C.
; - STOSW (Word) or STOSD (Double Word - 386+) can be used for faster filling
;   of large areas by processing more bits per cycle.
;=============================================================================
