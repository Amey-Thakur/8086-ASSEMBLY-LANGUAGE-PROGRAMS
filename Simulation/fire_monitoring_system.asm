;=============================================================================
; Program:     Fire Monitoring System (Simulation)
; Description: Emulate a temperature-based fire alarm system. The program 
;              monitors ambient temperature against user-defined thresholds
;              for two distinct rooms and triggers an alarm if exceeded.
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
    LIMIT1 DB ?                          ; Threshold for Room 1
    LIMIT2 DB ?                          ; Threshold for Room 2
    
    MSG_LIMIT1  DB 10,13,"Set Threshold for Room 1: $"
    MSG_LIMIT2  DB 10,13,"Set Threshold for Room 2: $"
    MSG_ALARM   DB 10,13,07,"!!! ALARM ON !!! Threshold exceeded! $" ; 07 is bell
    MSG_RESTART DB 10,13,"Press '1' to reset system or any key to exit: $"
    MSG_STATUS  DB 10,13,"Current Temperature: $"

;-----------------------------------------------------------------------------
; CODE SEGMENT
;-----------------------------------------------------------------------------
.CODE
MAIN PROC
    ; Initialize Segment
    MOV AX, @DATA
    MOV DS, AX
    
    ; 1. System Setup - Internalize Thresholds
    LEA DX, MSG_LIMIT1
    MOV AH, 09H
    INT 21H
    CALL READ_BCD_DIGIT
    MOV LIMIT1, AL

    LEA DX, MSG_LIMIT2
    MOV AH, 09H
    INT 21H
    CALL READ_BCD_DIGIT
    MOV LIMIT2, AL

;-------------------------------------------------------------------------
; MONITORING LOOP
;-------------------------------------------------------------------------
START_MONITOR:
    MOV CL, 0                           ; Starting temperature at 0 degrees
    
INC_TEMP:
    LEA DX, MSG_STATUS
    MOV AH, 09H
    INT 21H
    
    ; Display current CL as digit
    MOV DL, CL
    ADD DL, '0'
    MOV AH, 02H
    INT 21H
    
    ; Check against safety limits
    CMP CL, LIMIT1
    JGE TRIGGER_ALARM
    CMP CL, LIMIT2
    JGE TRIGGER_ALARM
    
    INC CL                              ; Temperature rises...
    
    ; Optional: Add a small delay simulation here if desired
    JMP INC_TEMP

;-------------------------------------------------------------------------
; ALARM STATE
;-------------------------------------------------------------------------
TRIGGER_ALARM:
    LEA DX, MSG_ALARM
    MOV AH, 09H
    INT 21H
    
    LEA DX, MSG_RESTART
    MOV AH, 09H
    INT 21H
    
    MOV AH, 01H                         ; Wait for user interaction
    INT 21H
    
    CMP AL, '1'
    JE START_MONITOR                    ; System reset
    
    ; Program termination
    MOV AH, 4CH
    INT 21H
MAIN ENDP

;-----------------------------------------------------------------------------
; HELPER: READ_BCD_DIGIT
; Reads one char, returns numeric value in AL.
;-----------------------------------------------------------------------------
READ_BCD_DIGIT PROC
    MOV AH, 01H
    INT 21H
    SUB AL, '0'
    RET
READ_BCD_DIGIT ENDP

END MAIN

;=============================================================================
; SIMULATION NOTES:
; - This models a simple "Control Loop" found in embedded systems.
; - It uses BCD (Binary Coded Decimal) logic for easy I/O.
; - The ASCII character 07h is sent to standard output to trigger a 
;   system beep (hardware buzzer simulation).
;=============================================================================