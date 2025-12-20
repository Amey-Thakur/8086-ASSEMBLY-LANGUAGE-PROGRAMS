;=============================================================================
; Program:     Memory Block Copy
; Description: Demonstrate efficient memory-to-memory data transfer using 
;              the 8086 specialized string instruction MOVSB.
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
    SOURCE DB 'Hello, World!', 0         ; Null-terminated source string
    SOURCE_LEN EQU $ - SOURCE            ; Automatically calculate length
    
    DEST DB 20 DUP(0)                    ; Destination buffer (initialized to 0)
    MSG  DB 'Memory block transfer successfully completed!$'

;-----------------------------------------------------------------------------
; CODE SEGMENT
;-----------------------------------------------------------------------------
.CODE
MAIN PROC
    ; Initialize Segment Registers
    MOV AX, @DATA
    MOV DS, AX                          ; DS points to Source segment
    MOV ES, AX                          ; ES points to Destination segment (same here)
    
    ;-------------------------------------------------------------------------
    ; STRING INSTRUCTION SETUP
    ; Source Pointer: DS:SI
    ; Destination Pointer: ES:DI
    ; Count: CX
    ;-------------------------------------------------------------------------
    LEA SI, SOURCE                      ; Source offset
    LEA DI, DEST                        ; Destination offset
    MOV CX, SOURCE_LEN                  ; Number of bytes to copy
    
    ; CLD (Clear Direction Flag): Ensures SI and DI increment (forward)
    CLD                                 
    
    ; REP MOVSB: Repeat 'Move String Byte' while CX > 0
    ; Automatically handles: ES:[DI] = DS:[SI]; SI++; DI++; CX--;
    REP MOVSB
    
    ; Verify by printing success message
    LEA DX, MSG
    MOV AH, 09H                         ; DOS: Print string
    INT 21H
    
    ; Return to DOS
    MOV AH, 4CH
    INT 21H
MAIN ENDP
END MAIN

;=============================================================================
; BLOCK COPY NOTES:
; - 'REP MOVSB' is significantly faster than a manual loop and MOV instruction.
; - Always ensure ES is correctly initialized as many string instructions 
;   implicitly use ES for the destination.
; - Direction Flag (DF): 0 (CLD) for forward, 1 (STD) for backward.
;=============================================================================
