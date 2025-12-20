;=============================================================================
; Program:     Copy String Using String Instructions
; Description: Copy string from one memory location to another using
;              REP MOVSB instruction for efficient block copy.
; 
; Author:      Amey Thakur
; Repository:  https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
; License:     MIT License
;=============================================================================

;-----------------------------------------------------------------------------
; DATA SEGMENT
;-----------------------------------------------------------------------------
DATA SEGMENT
    SOURCE DB "BIOMEDICAL"               ; Source string (10 chars)
DATA ENDS

;-----------------------------------------------------------------------------
; EXTRA SEGMENT (Destination)
;-----------------------------------------------------------------------------
EXTRA SEGMENT
    DEST DB 10 DUP(?)                    ; Destination buffer
EXTRA ENDS

;-----------------------------------------------------------------------------
; CODE SEGMENT
;-----------------------------------------------------------------------------
CODE SEGMENT
    ASSUME CS:CODE, DS:DATA, ES:EXTRA
    
START:
    ; Initialize Segments
    MOV AX, DATA
    MOV DS, AX                           ; DS points to source
    MOV AX, EXTRA
    MOV ES, AX                           ; ES points to destination
    
    ;-------------------------------------------------------------------------
    ; Setup for String Operation
    ;-------------------------------------------------------------------------
    MOV SI, 00H                          ; Source index (offset in DS)
    MOV DI, 00H                          ; Destination index (offset in ES)
    CLD                                  ; Clear direction flag (forward copy)
    MOV CX, 000AH                        ; Count = 10 characters
    
    ;-------------------------------------------------------------------------
    ; Copy String Using REP MOVSB
    ; MOVSB: Move String Byte from DS:SI to ES:DI
    ; REP: Repeat CX times
    ;-------------------------------------------------------------------------
    REP MOVSB                            ; Copy all 10 bytes
    
    ; Result: "BIOMEDICAL" copied to DEST
            
    ;-------------------------------------------------------------------------
    ; Program Termination
    ;-------------------------------------------------------------------------
    MOV AH, 4CH
    INT 21H
CODE ENDS
END START

;=============================================================================
; STRING INSTRUCTION NOTES:
; - MOVSB: Move String Byte (DS:SI -> ES:DI, then SI++, DI++)
; - MOVSW: Move String Word (moves 2 bytes at a time)
; - REP: Repeat CX times
; - CLD: Clear Direction Flag (forward: SI++, DI++)
; - STD: Set Direction Flag (backward: SI--, DI--)
;=============================================================================