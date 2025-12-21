;=============================================================================
; Program:     Loop Instructions
; Description: Demonstrate LOOP, LOOPE, and LOOPNE instructions.
;              LOOP uses CX as automatic counter.
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
    MSG1 DB 'Counting: $'
    NEWLINE DB 0DH, 0AH, '$'

;-----------------------------------------------------------------------------
; CODE SEGMENT
;-----------------------------------------------------------------------------
.CODE
MAIN PROC
    ; Initialize Data Segment
    MOV AX, @DATA
    MOV DS, AX
    
    ;-------------------------------------------------------------------------
    ; Display Message
    ;-------------------------------------------------------------------------
    LEA DX, MSG1
    MOV AH, 09H
    INT 21H
    
    ;-------------------------------------------------------------------------
    ; LOOP Instruction Demo
    ; LOOP decrements CX and jumps if CX != 0
    ; This counts from 1 to 9
    ;-------------------------------------------------------------------------
    MOV CX, 9                           ; Loop counter (iterations)
    MOV BL, '1'                         ; Starting character
    
COUNT_LOOP:
    ; Display current digit
    MOV DL, BL
    MOV AH, 02H
    INT 21H
    
    ; Display space separator
    MOV DL, ' '
    MOV AH, 02H
    INT 21H
    
    INC BL                              ; Next digit
    LOOP COUNT_LOOP                     ; CX--, if CX != 0, jump
    
    ; Output: 1 2 3 4 5 6 7 8 9
    
    ;-------------------------------------------------------------------------
    ; Newline
    ;-------------------------------------------------------------------------
    LEA DX, NEWLINE
    MOV AH, 09H
    INT 21H
    
    ;-------------------------------------------------------------------------
    ; Program Termination
    ;-------------------------------------------------------------------------
    MOV AH, 4CH                         ; DOS: Terminate program
    INT 21H
MAIN ENDP
END MAIN

;=============================================================================
; LOOP INSTRUCTION REFERENCE
;=============================================================================
; 
; LOOP label
;   - Decrements CX by 1
;   - Jumps to label if CX != 0
;   - Does NOT affect any flags
;   - Equivalent to: DEC CX / JNZ label (but DEC affects flags)
; 
; LOOPE/LOOPZ label (Loop while Equal/Zero)
;   - Decrements CX by 1
;   - Jumps if CX != 0 AND ZF = 1
;   - Useful for searching until mismatch or count exhausted
; 
; LOOPNE/LOOPNZ label (Loop while Not Equal/Not Zero)
;   - Decrements CX by 1
;   - Jumps if CX != 0 AND ZF = 0
;   - Useful for searching until match or count exhausted
; 
; IMPORTANT NOTES:
; - CX must be initialized before LOOP
; - If CX = 0 before LOOP, it loops 65536 times!
; - Use JCXZ before LOOP to skip if CX = 0
;=============================================================================
