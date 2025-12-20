; Program: Delay/Timer
; Description: Create a time delay using loop
; Author: Amey Thakur
; Keywords: 8086 delay, timer assembly, wait loop

.MODEL SMALL
.STACK 100H

.DATA
    MSG1 DB 'Starting delay...', 0DH, 0AH, '$'
    MSG2 DB 'Delay complete!', 0DH, 0AH, '$'

.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX
    
    LEA DX, MSG1
    MOV AH, 09H
    INT 21H
    
    ; Call delay (approximately 1 second on 8086)
    CALL DELAY_1SEC
    
    LEA DX, MSG2
    MOV AH, 09H
    INT 21H
    
    MOV AH, 4CH
    INT 21H
MAIN ENDP

; Delay approximately 1 second
; Adjust outer/inner loop values for different CPUs
DELAY_1SEC PROC
    PUSH CX
    PUSH DX
    
    MOV CX, 0FFFFH   ; Outer loop
OUTER:
    MOV DX, 00FFH    ; Inner loop
INNER:
    DEC DX
    JNZ INNER
    LOOP OUTER
    
    POP DX
    POP CX
    RET
DELAY_1SEC ENDP

; More precise delay using BIOS timer
DELAY_BIOS PROC
    PUSH AX
    PUSH CX
    PUSH DX
    
    ; Get current time
    MOV AH, 00H
    INT 1AH
    MOV BX, DX       ; Save current tick count
    
    ; Wait for ~18 ticks (approximately 1 second)
    ADD BX, 18
WAIT_LOOP:
    MOV AH, 00H
    INT 1AH
    CMP DX, BX
    JB WAIT_LOOP
    
    POP DX
    POP CX
    POP AX
    RET
DELAY_BIOS ENDP

END MAIN
