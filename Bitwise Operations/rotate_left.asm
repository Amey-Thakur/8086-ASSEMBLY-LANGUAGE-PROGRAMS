;=============================================================================
; Program:     Rotate Left (ROL) Operation
; Description: Rotate bits left - bits shifted out from left re-enter at right.
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
    ; Perform Rotate Left Operation
    ; ROL rotates bits left - MSB goes to LSB and to CF
    ; No bits are lost, they wrap around
    ;-------------------------------------------------------------------------
    MOV AL, NUM1                        ; AL = 10000001 (81H)
    MOV CL, ROTATE_COUNT                ; CL = rotate count
    ROL AL, CL                          ; Rotate left by CL positions
    MOV RESULT, AL                      ; Result = 00000110 (06H)
    
    ;-------------------------------------------------------------------------
    ; Program Termination
    ;-------------------------------------------------------------------------
    MOV AH, 4CH                         ; DOS: Terminate program
    INT 21H
MAIN ENDP
END MAIN

;=============================================================================
; ROL (ROTATE LEFT) NOTES:
; - Bits wrap around: MSB goes to LSB
; - MSB also copied to Carry Flag (CF)
; - No bits are lost
; 
; Visual Example:
;   Before ROL 1: [1][0][0][0][0][0][0][1] = 81H
;   After ROL 1:  [0][0][0][0][0][0][1][1] = 03H
;                  |                    ^
;                  `-----> CF and LSB <-'
; 
; After ROL 2:    [0][0][0][0][0][1][1][0] = 06H
; 
; RCL (Rotate through Carry Left) includes CF in the rotation
;=============================================================================
