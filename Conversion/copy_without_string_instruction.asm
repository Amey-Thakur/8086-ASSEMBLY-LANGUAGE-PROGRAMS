;=============================================================================
; Program:     Copy String Without String Instructions
; Description: Copy string from one memory location to another using
;              basic MOV instructions (manual loop method).
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
    DEST DB 10 DUP(?)                    ; Destination buffer
DATA ENDS

;-----------------------------------------------------------------------------
; CODE SEGMENT
;-----------------------------------------------------------------------------
CODE SEGMENT
    ASSUME CS:CODE, DS:DATA
    
START:
    ; Initialize Data Segment
    MOV AX, DATA
    MOV DS, AX
    
    ;-------------------------------------------------------------------------
    ; Setup for Manual Copy
    ;-------------------------------------------------------------------------
    MOV SI, OFFSET SOURCE                ; SI points to source
    MOV DI, OFFSET DEST                  ; DI points to destination
    MOV CX, 000AH                        ; Count = 10 characters
    
    ;-------------------------------------------------------------------------
    ; Manual Copy Loop (without string instructions)
    ; Uses MOV to copy byte by byte
    ;-------------------------------------------------------------------------
COPY_LOOP:
    MOV AL, [SI]                         ; Load byte from source
    MOV [DI], AL                         ; Store byte to destination
    INC SI                               ; Next source byte
    INC DI                               ; Next destination byte
    LOOP COPY_LOOP                       ; Decrement CX, loop if not zero
    
    ; Result: "BIOMEDICAL" copied to DEST
            
    ;-------------------------------------------------------------------------
    ; Program Termination
    ;-------------------------------------------------------------------------
    MOV AH, 4CH
    INT 21H
CODE ENDS
END START

;=============================================================================
; COMPARISON WITH STRING INSTRUCTIONS:
; 
; Manual Method:                String Instruction Method:
; -----------------             -------------------------
; COPY_LOOP:                    CLD
;   MOV AL, [SI]                MOV CX, 10
;   MOV [DI], AL                REP MOVSB
;   INC SI
;   INC DI
;   LOOP COPY_LOOP
; 
; String instructions are faster and more compact!
;=============================================================================