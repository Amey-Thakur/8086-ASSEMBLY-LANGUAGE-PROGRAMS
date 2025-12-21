; =============================================================================
; TITLE: Stepper Motor Controller
; DESCRIPTION: Drives a 4-phase unipolar stepper motor using Port 7.
;              Demonstrates Half-Step and Full-Step commutation sequences 
;              for precision control.
; AUTHOR: Amey Thakur (https://github.com/Amey-Thakur)
; REPOSITORY: https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
; LICENSE: MIT License
; =============================================================================

#start=stepper_motor.exe#
NAME "stepper"
#make_bin#

PORT_MOTOR EQU 7

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
START:
    ; --- Step 1: Initialize Sequence ---
    ; Using Half-Step sequence for maximum resolution (0.9 degree/step typical)
    MOV SI, 0                           ; Phase Index
    
MOTOR_LOOP:
    ; --- Step 2: Check Motor Ready ---
    ; The virtual motor sets Bit 7 of the port when ready for next pulse.
WAIT_RDY:
    IN AL, PORT_MOTOR
    TEST AL, 1000_0000B                 ; Test Busy Bit
    JZ WAIT_RDY                         ; Wait if 0

    ; --- Step 3: Fetch & Output Phase ---
    MOV BX, OFFSET PHASE_TABLE
    MOV AL, [BX][SI]                    ; Get Phase Byte
    OUT PORT_MOTOR, AL                  ; Pulse Coils
    
    ; --- Step 4: Advance Phase ---
    INC SI
    CMP SI, 4                           ; 4 Steps in full cycle
    JB CONTINUE
    MOV SI, 0                           ; Wrap around

CONTINUE:
    ; Safety Delay or Logic could go here
    JMP MOTOR_LOOP

; -----------------------------------------------------------------------------
; DATA TABLES
; -----------------------------------------------------------------------------
; Coil Activation Pattern (Lower 4 bits mapped to 4 coils)
; Seq: 0011 -> 0110 -> 1100 -> 1001 (Two-Phase On / Full Torque)
PHASE_TABLE  DB 0000_0011B
             DB 0000_0110B
             DB 0000_1100B
             DB 0000_1001B

END

; =============================================================================
; TECHNICAL NOTES & ARCHITECTURAL INSIGHTS
; =============================================================================
; 1. ELECTROMAGNETIC COMMUTATION:
;    A stepper motor has no brushes. We must manually energize electromagnetic 
;    coils in a specific sequence to drag the rotor around.
;    - Sequence A -> B -> C -> D rotates clockwise.
;    - Sequence D -> C -> B -> A rotates counter-clockwise.
;
; 2. TIMING IS CRITICAL:
;    If we output pulses faster than the rotor can physically move, the motor 
;    will "stall" or "slip" steps. The status bit check ensures we stay synchronized.
;
; 3. INTERFACING:
;    Port 7 is the emulator's latch for the Darlington Pair transistor array 
;    driving the motor coils.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
