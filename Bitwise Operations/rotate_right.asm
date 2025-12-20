;=============================================================================
; Program:     Rotate Right (ROR) Operation
; Description: Rotate bits right - bits shifted out from right re-enter at left.
;              No bits are lost, they just rotate around.
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
    NUM1 DB 81H                         ; Number: 10000001 (129)
    ROTATE_COUNT DB 2                   ; Rotate by 2 positions
    RESULT DB ?                         ; Result storage

;-----------------------------------------------------------------------------
; CODE SEGMENT
;-----------------------------------------------------------------------------
.CODE
MAIN PROC
    ; Initialize Data Segment
    MOV AX, @DATA
    MOV DS, AX
    
    ;-------------------------------------------------------------------------
    ; Perform Rotate Right Operation
    ; ROR rotates bits right - LSB goes to MSB and to CF
    ; No bits are lost, they wrap around
    ;-------------------------------------------------------------------------
    MOV AL, NUM1                        ; AL = 10000001 (81H)
    MOV CL, ROTATE_COUNT                ; CL = rotate count
    ROR AL, CL                          ; Rotate right by CL positions
    MOV RESULT, AL                      ; Result = 01100000 (60H)
    
    ;-------------------------------------------------------------------------
    ; Program Termination
    ;-------------------------------------------------------------------------
    MOV AH, 4CH                         ; DOS: Terminate program
    INT 21H
MAIN ENDP
END MAIN

;=============================================================================
; ROR (ROTATE RIGHT) NOTES:
; - Bits wrap around: LSB goes to MSB
; - LSB also copied to Carry Flag (CF)
; - No bits are lost
; 
; Visual Example:
;   Before ROR 1: [1][0][0][0][0][0][0][1] = 81H
;   After ROR 1:  [1][1][0][0][0][0][0][0] = C0H
;                  ^                    |
;                  `--> from LSB <-----'  (also to CF)
; 
; After ROR 2:    [0][1][1][0][0][0][0][0] = 60H
; 
; RCR (Rotate through Carry Right) includes CF in the rotation
;=============================================================================
