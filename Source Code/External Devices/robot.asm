; =============================================================================
; TITLE: Autonomous Robot Controller
; DESCRIPTION: Controls a simulated robot navigating a grid. The robot utilizes 
;              sensors to detect walls and lamps, switching lamps ON/OFF and 
;              navigating random paths.
; AUTHOR: Amey Thakur (https://github.com/Amey-Thakur)
; REPOSITORY: https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
; LICENSE: MIT License
; =============================================================================

#start=robot.exe#
NAME "robot_ai"

#make_bin#
#cs = 500#
#ds = 500#
#ss = 500#
#sp = ffff#
#ip = 0#

; -----------------------------------------------------------------------------
; CONSTANTS (I/O PORTS)
; -----------------------------------------------------------------------------
PORT_CMD    EQU 9                       ; Command Ouput / ID Input
PORT_DATA   EQU 10                      ; Sensor Data Input
PORT_STATUS EQU 11                      ; Busy/Ready Flag Input

CMD_MOVE    EQU 1
CMD_LEFT    EQU 2
CMD_RIGHT   EQU 3
CMD_EXAMINE EQU 4
CMD_LAMP_ON EQU 5
CMD_LAMP_OFF EQU 6

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
START:

AI_LOOP:
    ; --- Step 1: Scan Environment ---
    CALL WAIT_FOR_IDLE
    MOV AL, CMD_EXAMINE
    OUT PORT_CMD, AL
    
    CALL WAIT_FOR_DATA
    IN AL, PORT_DATA                    ; Read Sensor
    
    ; Analyze Sensor Data
    CMP AL, 255                         ; Wall?
    JE L_IS_WALL
    CMP AL, 7                           ; LAMP ON?
    JE L_LAMP_ON
    CMP AL, 0                           ; Empty?
    JE L_MOVE_FWD
    ; Else: Lamp OFF (Values 1-6 are dim lamps)
    JMP L_LAMP_OFF

L_LAMP_ON:
    CALL WAIT_FOR_IDLE
    MOV AL, CMD_LAMP_OFF
    OUT PORT_CMD, AL
    JMP L_MOVE_FWD

L_LAMP_OFF:
    CALL WAIT_FOR_IDLE
    MOV AL, CMD_LAMP_ON
    OUT PORT_CMD, AL
    JMP L_MOVE_FWD

L_IS_WALL:
    ; Hit a wall, forced turn
    CALL RANDOM_TURN
    JMP AI_LOOP

L_MOVE_FWD:
    ; 10% chance to turn even if empty (random walk)
    CALL RANDOM_DECISION 
    JC L_TURN_RANDOM
    
    CALL WAIT_FOR_IDLE
    MOV AL, CMD_MOVE
    OUT PORT_CMD, AL
    JMP AI_LOOP

L_TURN_RANDOM:
    CALL RANDOM_TURN
    JMP AI_LOOP

; -----------------------------------------------------------------------------
; PROCEDURES
; -----------------------------------------------------------------------------

WAIT_FOR_IDLE PROC
L_WAIT1:
    IN AL, PORT_STATUS
    TEST AL, 0000_0010B                 ; Test Busy Bit
    JNZ L_WAIT1                         ; Loop if Busy
    RET
WAIT_FOR_IDLE ENDP

WAIT_FOR_DATA PROC
L_WAIT2:
    IN AL, PORT_STATUS
    TEST AL, 0000_0001B                 ; Test Data Ready Bit
    JZ L_WAIT2                          ; Loop if Empty
    RET
WAIT_FOR_DATA ENDP

RANDOM_TURN PROC
    ; Simple valid turn: Right (simplification)
    CALL WAIT_FOR_IDLE
    MOV AL, CMD_RIGHT
    OUT PORT_CMD, AL
    RET
RANDOM_TURN ENDP

RANDOM_DECISION PROC
    ; Uses System Timer for pseudo-randomness
    MOV AH, 0
    INT 1AH                             ; Read Timer -> DX
    TEST DL, 0000_0100B                 ; Test bit 2 (approx 1/8 chance)
    JZ L_NO_TURN                        ; If 0, carry clear
    STC                                 ; If 1, set carry
    RET
L_NO_TURN:
    CLC
    RET
RANDOM_DECISION ENDP

END

; =============================================================================
; TECHNICAL NOTES & ARCHITECTURAL INSIGHTS
; =============================================================================
; 1. ASYNCHRONOUS I/O:
;    The robot is a mechanical device simulation. It is much slower than the CPU.
;    We MUST use 'Polling' on the Status Register to wait for mechanical completion.
;    (WAIT_FOR_IDLE) prevents sending commands into the void.
;
; 2. SENSOR INTERPRETATION:
;    The robot's "eye" returns:
;    - 0: Empty Space
;    - 255: Solid Obstacle
;    - 1-8: Lamp ID/Brightness
;    This allows creating complex navigation logic (maze solving).
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
