;=============================================================================
; Program:     Copy Array
; Description: Copy contents of one array to another using string instructions.
;              Demonstrates REP MOVSB for efficient block memory copy.
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
    SRC DB 11H, 22H, 33H, 44H, 55H     ; Source array
    DST DB 5 DUP(0)                     ; Destination array (initialized to 0)
    LEN EQU 5                           ; Array length

;-----------------------------------------------------------------------------
; CODE SEGMENT
;-----------------------------------------------------------------------------
.CODE
MAIN PROC
    ; Initialize Data Segment
    MOV AX, @DATA
    MOV DS, AX                          ; Set DS for source
    MOV ES, AX                          ; Set ES for destination (same segment)
    
    ;-------------------------------------------------------------------------
    ; Setup Source and Destination Pointers
    ;-------------------------------------------------------------------------
    LEA SI, SRC                         ; SI = Source Index (points to SRC)
    LEA DI, DST                         ; DI = Destination Index (points to DST)
    MOV CX, LEN                         ; CX = Count (number of bytes to copy)
    
    ;-------------------------------------------------------------------------
    ; Perform Block Copy
    ; CLD: Clear Direction Flag (increment SI/DI after each operation)
    ; REP MOVSB: Repeat MOVe String Byte CX times
    ;-------------------------------------------------------------------------
    CLD                                 ; Clear direction flag (forward copy)
    REP MOVSB                           ; Copy CX bytes from DS:SI to ES:DI
    
    ; Result: DST now contains {11H, 22H, 33H, 44H, 55H}
    
    ;-------------------------------------------------------------------------
    ; Program Termination
    ;-------------------------------------------------------------------------
    MOV AH, 4CH                         ; DOS: Terminate program
    INT 21H
MAIN ENDP
END MAIN

;=============================================================================
; NOTES:
; - REP prefix repeats the string instruction CX times
; - MOVSB: Move String Byte (DS:SI -> ES:DI, then increment/decrement)
; - MOVSW: Move String Word (moves 2 bytes at a time)
; - CLD: Forward direction (SI++, DI++), STD: Backward direction (SI--, DI--)
;=============================================================================
