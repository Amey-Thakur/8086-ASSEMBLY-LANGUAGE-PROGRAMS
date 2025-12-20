;=============================================================================
; Program:     Water Level Controller (Simulation)
; Description: Emulate an automated pump system for an overhead tank. 
;              Simulates motor switching, water level monitoring (8 levels), 
;              and overflow protection logic.
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
    MSG_LEVEL    DB 10,13,"Monitoring: Tank water level is: $"
    MSG_MOTOR_ON DB 10,13,"[AUTO] Level Critical. Switching ON Motor... $"
    MSG_MOTOR_OFF DB 10,13,"[AUTO] Level High. Switching OFF Motor... $"
    MSG_OVERFLOW  DB 10,13,07,"!!! WARNING: WATER OVERFLOW DETECTED !!! $"

;-----------------------------------------------------------------------------
; CODE SEGMENT
;-----------------------------------------------------------------------------
.CODE
MAIN PROC
    ; Initialize System
    MOV AX, @DATA
    MOV DS, AX
    
    MOV CL, 1                           ; Starting Level (1)
    
MONITOR_CYCLE:
    ; 1. Display Status
    LEA DX, MSG_LEVEL
    MOV AH, 09H
    INT 21H
    
    MOV DL, CL
    ADD DL, '0'                         ; ASCII translation
    MOV AH, 02H
    INT 21H
    
    ;-------------------------------------------------------------------------
    ; CONTROL LOGIC (State machine)
    ;-------------------------------------------------------------------------
    
    CMP CL, 8                           ; Check for Max Level
    JE STOP_PUMP
    
    CMP CL, 1                           ; Check for Min Level
    JE START_PUMP
    
RESUME_SENSING:
    INC CL                              ; Simulating water filling the tank
    
    ; Loop condition: Max 8 levels
    CMP CL, 8
    JLE MONITOR_CYCLE
    
    JMP SYSTEM_EXIT

;-------------------------------------------------------------------------
; SYSTEM ACTIONS
;-------------------------------------------------------------------------

START_PUMP:
    LEA DX, MSG_MOTOR_ON
    MOV AH, 09H
    INT 21H
    JMP RESUME_SENSING

STOP_PUMP:
    LEA DX, MSG_MOTOR_OFF
    MOV AH, 09H
    INT 21H
    
    LEA DX, MSG_OVERFLOW
    MOV AH, 09H
    INT 21H
    JMP RESUME_SENSING

SYSTEM_EXIT:
    MOV AH, 4CH
    INT 21H
MAIN ENDP
END MAIN

;=============================================================================
; CONTROLLER NOTES:
; - This models a simple logic gate controller (PLC-like behavior).
; - Level 1 is the 'Low-Water' trigger (Switch ON).
; - Level 8 is the 'Full' trigger (Switch OFF + Alarm).
; - 07h is sent to standard output to simulate the physical buzzer.
;=============================================================================