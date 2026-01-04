; =============================================================================
; TITLE: Memory Block Fill
; DESCRIPTION: Initialize a block of memory with a specific constant byte 
;              using the STOSB (Store String Byte) instruction.
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
    BUFFER  DB 20 DUP(?)                ; Uninitialized buffer
    B_LEN   EQU 20
    CHAR    DB '*'                      ; Fill value
    MSG     DB 'Memory buffer successfully initialized with fill pattern.$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
MAIN PROC
    ; Segments setup
    MOV AX, @DATA
    MOV DS, AX
    MOV ES, AX                          ; ES is mandatory for STOSB
    
    ; -------------------------------------------------------------------------
    ; STRING STORE SETUP
    ; Pointer: ES:DI
    ; Value: AL
    ; -------------------------------------------------------------------------
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

; =============================================================================
; TECHNICAL NOTES
; =============================================================================
; 1. ANALOGY:
;    - STOSB is the building block for the 'memset' function found in C.
; 2. VARIATIONS:
;    - STOSW (Word) or STOSD (Double Word - 386+) can be used for faster filling
;      of large areas by processing more bits per cycle.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
