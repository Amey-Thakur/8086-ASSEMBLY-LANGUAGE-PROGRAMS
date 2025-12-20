;=============================================================================
; Program:     Array Descending Sort
; Description: Arrange an 8-bit numeric array in descending order using 
;              the bubble-exchange technique.
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
DATA SEGMENT
    VALUES DB 99H, 12H, 56H, 45H, 36H    ; Random input bytes
    V_LEN  EQU 5
    MSG    DB 'Array successfully sorted in Descending order.$'
DATA ENDS

;-----------------------------------------------------------------------------
; CODE SEGMENT
;-----------------------------------------------------------------------------
CODE SEGMENT
    ASSUME CS:CODE, DS:DATA

START:
    ; Setup Segment
    MOV AX, DATA
    MOV DS, AX
    
    MOV CX, V_LEN                       ; Outer loop counter
    DEC CX                              ; N-1 passes

;-------------------------------------------------------------------------
; DESCENDING BUBBLE LOGIC
;-------------------------------------------------------------------------
OUTER_SORT:
    PUSH CX
    LEA SI, VALUES                      ; Start of array
    
COMPARE_DESC:
    MOV AL, [SI]                        ; Element 1
    MOV BL, [SI+1]                      ; Element 2
    
    CMP AL, BL                          ; Compare for Descending (AL > BL)
    JAE NO_ACTION                       ; If AL >= BL, carry on
    
    ; SWAP
    XCHG [SI], BL                       ; Swap in memory directly
    MOV [SI+1], BL

NO_ACTION:
    INC SI                              ; Advance pointer
    LOOP COMPARE_DESC
    
    POP CX
    LOOP OUTER_SORT                     ; Repeat until sorted
    
    ; User Notification
    LEA DX, MSG
    MOV AH, 09H
    INT 21H
    
    ; Exit
    MOV AH, 4CH
    INT 21H

CODE ENDS
END START

;=============================================================================
; SORTING NOTES:
; - This is the mirror of the ascending sort. 
; - The 'JAE' (Jump if Above or Equal) is the key control flow here for 
;   the descending property.
; - Final sorted order will be: 99h, 56h, 45h, 36h, 12h.
;=============================================================================
