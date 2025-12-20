;=============================================================================
; Program:     Stepper Motor Control
; Description: Demonstrate controlling a virtual stepper motor on port 7.
;              Cycles through half-step and full-step rotations in both
;              clockwise and counter-clockwise directions.
; 
; Author:      Amey Thakur
; Repository:  https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
; License:     MIT License
;=============================================================================

#start=stepper_motor.exe#
NAME "stepper"
#make_bin#

; Configuration
STEPS_BEFORE_DIRECTION_CHANGE EQU 20H ; 32 (decimal) steps per sequence

;-----------------------------------------------------------------------------
; CODE SEGMENT
;-----------------------------------------------------------------------------
JMP START

;-----------------------------------------------------------------------------
; STEPPING SEQUENCE DATA (4-phase motor)
; Each byte represents the state of the 4 coils/magnets
;-----------------------------------------------------------------------------

; Half-Step Clockwise (Smoother, higher torque)
DATCW    DB 0000_0110B
         DB 0000_0100B    
         DB 0000_0011B
         DB 0000_0010B

; Half-Step Counter-Clockwise
DATCCW   DB 0000_0011B
         DB 0000_0001B    
         DB 0000_0110B
         DB 0000_0010B

; Full-Step Clockwise (Higher speed)
DATCW_FS DB 0000_0001B
         DB 0000_0011B    
         DB 0000_0110B
         DB 0000_0000B

; Full-Step Counter-Clockwise
DATCCW_FS DB 0000_0100B
          DB 0000_0110B    
          DB 0000_0011B
          DB 0000_0000B

START:
    MOV BX, OFFSET DATCW            ; Start with Clockwise Half-Step
    MOV SI, 0                       ; Table index (0-3)
    MOV CX, 0                       ; Global step counter

NEXT_STEP:
    ; Handshake: Motor sets top bit (bit 7) when ready for next command
WAIT_READY:   
    IN AL, 7                        ; Read motor status from port 7
    TEST AL, 10000000B              ; Check busy bit
    JZ WAIT_READY                   ; Loop until ready

    ; Send current phase sequence from data table to port 7
    MOV AL, [BX][SI]
    OUT 7, AL

    ; Cycle through 4-step sequence
    INC SI
    CMP SI, 4
    JB CONTINUE_LOOP
    MOV SI, 0                       ; Reset to start of 4-step sequence

CONTINUE_LOOP:
    INC CX                          ; Total steps in current direction
    CMP CX, STEPS_BEFORE_DIRECTION_CHANGE
    JB  NEXT_STEP                   ; Continue current sequence

    ; Change to next sequence after enough steps
    MOV CX, 0
    ADD BX, 4                       ; Increment data pointer to next table

    ; If we've finished all 4 tables, return to the first one
    CMP BX, OFFSET DATCCW_FS
    JBE NEXT_STEP

    MOV BX, OFFSET DATCW            ; Return to beginning (Half-CW)
    JMP NEXT_STEP

END

;=============================================================================
; STEPPER MOTOR NOTES:
; - Stepper motors move in precise angular increments (steps).
; - Requires a sequence of electrical pulses to internal coils.
; - Half-stepping interleaves states for finer resolution.
; - Full-stepping energizes coils in simpler pairs for higher power/speed.
; - Emu8086 uses port 7 for its virtual stepper motor device.
;=============================================================================
