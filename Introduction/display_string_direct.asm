;=============================================================================
; Program:     Display String Direct
; Description: Direct string output demonstration using the DOS 09H service
;              with a standard segment layout.
; 
; Author:      Amey Thakur
; Repository:  https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
; License:     MIT License
;=============================================================================

;-----------------------------------------------------------------------------
; DATA SEGMENT - Constant storage
;-----------------------------------------------------------------------------
DATA SEGMENT
    MESSAGE DB "Hello World - This is a direct string test!$"
DATA ENDS

;-----------------------------------------------------------------------------
; CODE SEGMENT - Implementation
;-----------------------------------------------------------------------------
CODE SEGMENT
    ASSUME CS:CODE, DS:DATA

START:
    ; Point data segment register to our data area
    MOV AX, DATA
    MOV DS, AX
    
    ; Setup Display String function
    MOV AH, 09H                     ; Function 09h: Print string at DS:DX
    LEA DX, MESSAGE                 ; Pointer to the string
    INT 21H                         ; Call DOS kernel
    
    ; Exit safely
    MOV AX, 4C00H
    INT 21H

CODE ENDS

END START

;=============================================================================
; STRING NOTES:
; - The string must exist in a segment pointed to by DS.
; - LEA (Load Effective Address) is a highly efficient way to get the
;   offset of a memory label.
;=============================================================================
