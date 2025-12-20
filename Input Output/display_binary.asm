;=============================================================================
; Program:     Display Binary
; Description: Convert a 16-bit word or 8-bit byte into its ASCII binary 
;              representation and display it on the screen.
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
    NUM DW 0A5H                         ; Example: 10100101b
    MSG DB 'Binary Representation: $'

;-----------------------------------------------------------------------------
; CODE SEGMENT
;-----------------------------------------------------------------------------
.CODE
MAIN PROC
    ; Initialize Data Segment
    MOV AX, @DATA
    MOV DS, AX
    
    ; Display descriptive message
    LEA DX, MSG
    MOV AH, 09H
    INT 21H
    
    ; Load number and call print routine
    MOV AX, NUM
    CALL PRINT_BINARY
    
    ; Print 'b' suffix for clarity
    MOV DL, 'b'
    MOV AH, 02H
    INT 21H
    
    ; Exit to DOS
    MOV AH, 4CH
    INT 21H
MAIN ENDP

;-----------------------------------------------------------------------------
; PROCEDURE: PRINT_BINARY
; Input: AL (8-bit value to print)
; Logic: Uses bitwise rotation (ROL) to extract bits into the Carry Flag.
;-----------------------------------------------------------------------------
PRINT_BINARY PROC
    PUSH AX
    PUSH CX
    PUSH DX
    
    MOV CX, 8                           ; Process 8 bits for a byte
    
BIT_LOOP:
    ROL AL, 1                           ; Rotate Left: MSB moves to Carry Flag (CF)
    JC PRINT_ONE                        ; If CF=1, print '1'
    
    MOV DL, '0'                         ; Otherwise print '0'
    JMP PRINT_BIT
    
PRINT_ONE:
    MOV DL, '1'
    
PRINT_BIT:
    PUSH AX                             ; Save AL during syscall
    MOV AH, 02H                         ; DOS: Display character in DL
    INT 21H
    POP AX                              ; Restore AL
    
    LOOP BIT_LOOP                       ; Repeat for all bits
    
    POP DX
    POP CX
    POP AX
    RET
PRINT_BINARY ENDP

END MAIN

;=============================================================================
; BINARY DISPLAY NOTES:
; - ROL (Rotate Left) is ideal for MSB-first display.
; - SHR/SHL could also be used, but ROL preserves the original value in AL
;   after 8 rotations.
; - Base 2 conversion is the most fundamental digit extraction technique.
;=============================================================================
