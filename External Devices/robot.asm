;=============================================================================
; Program:     Robot Control Simulation
; Description: Demonstrate controlling a virtual robot in Emu8086.
;              The robot explores its environment, detects obstacles/lamps,
;              and toggles lights randomly.
; 
; Author:      Amey Thakur
; Repository:  https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
; License:     MIT License
;=============================================================================

#start=robot.exe#
NAME "robot"

; Memory layout configuration for simulation
#make_bin#
#cs = 500#
#ds = 500#
#ss = 500#                          ; Stack segment
#sp = ffff#                         ; Stack pointer at bottom
#ip = 0#                            ; Instruction pointer

;-----------------------------------------------------------------------------
; ROBOT I/O PORTS
; - Port 9: Command Register (Output) / Status (Input)
; - Port 10: Data Register (Input of sensor readings)
; - Port 11: Status Register (Flag check)
;-----------------------------------------------------------------------------
R_PORT EQU 9

;-----------------------------------------------------------------------------
; MAIN LOOP: EXPLORATION
;-----------------------------------------------------------------------------
ETERNAL_LOOP:
    CALL WAIT_ROBOT                  ; Ensure robot is ready for next command

    ; Examine the area in front of the robot
    MOV AL, 4                        ; Command 4: Examine
    OUT R_PORT, AL

    CALL WAIT_EXAM                   ; Wait for sensor data to become valid

    ; Get sensor result from Data Register
    IN AL, R_PORT + 1

    ; Sensor feedback codes:
    ; 0   - Nothing found
    ; 255 - Wall/Obstacle
    ; 7   - Lighted lamp
    ; 0..6 - Dark lamps (various shades)

    CMP AL, 0
    JE CONT                          ; Nothing found, move forward
    CMP AL, 255  
    JE CONT                          ; Wall found, try to turn in 'CONT'

    CMP AL, 7                        ; Is it a switched-on lamp?
    JNE LAMP_OFF                     ; No, skip to switching on
    
    ; If lamp is on, switch it off
    CALL SWITCH_OFF_LAMP 
    JMP  CONT

LAMP_OFF: 
    ; If it reaches here, it must be a switched-off lamp
    CALL SWITCH_ON_LAMP

CONT:
    ; Randomly decide to turn or move
    CALL RANDOM_TURN
    CALL WAIT_ROBOT

    ; Move step forward
    MOV AL, 1                        ; Command 1: Step forward
    OUT R_PORT, AL
    CALL WAIT_ROBOT

    ; Move step forward again for smoother motion
    MOV AL, 1
    OUT R_PORT, AL

    JMP ETERNAL_LOOP                 ; Infinite exploration loop

;-----------------------------------------------------------------------------
; PROCEDURES
;-----------------------------------------------------------------------------

; BLOCKING WAIT: Robot Ready
WAIT_ROBOT PROC
    BUSY: 
        IN AL, R_PORT + 2            ; Read Status Register
        TEST AL, 00000010B           ; Check bit 1 (Busy Flag)
        JNZ BUSY                     ; Wait while busy
    RET    
WAIT_ROBOT ENDP

; BLOCKING WAIT: Examination Data Valid
WAIT_EXAM PROC
    BUSY2: 
        IN AL, R_PORT + 2            ; Read Status Register
        TEST AL, 00000001B           ; Check bit 0 (Data Ready Flag)
        JZ BUSY2                     ; Wait if no data yet
    RET    
WAIT_EXAM ENDP

; Toggle Lamp Off (Command 6)
SWITCH_OFF_LAMP PROC
    MOV AL, 6
    OUT R_PORT, AL
    RET
SWITCH_OFF_LAMP ENDP

; Toggle Lamp On (Command 5)
SWITCH_ON_LAMP PROC
    MOV AL, 5
    OUT R_PORT, AL
    RET
SWITCH_ON_LAMP ENDP

; Generate random turns using system timer ticks
RANDOM_TURN PROC
    ; Get current clock ticks in CX:DX
    MOV AH, 0
    INT 1AH                          ; BIOS Time services

    ; Scramble ticks to generate pseudo-random bits
    XOR DH, DL
    XOR CH, CL
    XOR CH, DH

    TEST CH, 2                       ; Use bit 1 to decide weight of turning
    JZ NO_TURN

    TEST CH, 1                       ; Use bit 0 to decide Left or Right
    JNZ TURN_RIGHT

    ; Turn Left (Command 2)
    MOV AL, 2
    OUT R_PORT, AL
    RET  

TURN_RIGHT:
    ; Turn Right (Command 3)
    MOV AL, 3
    OUT R_PORT, AL

NO_TURN:
    RET
RANDOM_TURN ENDP

END

;=============================================================================
; ROBOT SIMULATION NOTES:
; - Virtual robot uses multiple ports starting from base port 9.
; - Robot takes physical time to move; software MUST poll status registers.
; - Command mapping:
;   1: Step forward
;   2: Turn left
;   3: Turn right
;   4: Examine front
;   5: Switch lamp ON
;   6: Switch lamp OFF
;=============================================================================
