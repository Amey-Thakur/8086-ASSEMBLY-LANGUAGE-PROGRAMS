;=============================================================================
; Program:     Digital Thermostat Control
; Description: Simulate a temperature control system using a heater and
;              a virtual thermometer. Maintains temperature between 60'C and 80'C.
; 
; Author:      Amey Thakur
; Repository:  https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
; License:     MIT License
;=============================================================================

#start=thermometer.exe#
#make_bin#
NAME "thermo"

;-----------------------------------------------------------------------------
; CODE SEGMENT
;-----------------------------------------------------------------------------
; Logic: Hysteresis-based temperature control.
; - If Temp < 60'C: Turn Heater ON
; - If Temp > 80'C: Turn Heater OFF
; - Ports: 125 (Input from Thermometer), 127 (Output to Heater)
;-----------------------------------------------------------------------------

; Initialize segments
MOV AX, CS
MOV DS, AX

START:
    ; Read current temperature from port 125
    IN AL, 125

    ; Check lower threshold (60'C)
    CMP AL, 60
    JL  LOW_TEMP                    ; If under 60, heat up

    ; Check upper threshold (80'C)
    CMP AL, 80
    JG   HIGH_TEMP                  ; If over 80, cool down

    ; If between 60 and 80, maintain current heater state
    JMP OK

LOW_TEMP:
    ; Temperature is too low (< 60)
    MOV AL, 1
    OUT 127, AL                     ; Turn heater "ON" by sending 1 to port 127
    JMP OK

HIGH_TEMP:
    ; Temperature is too high (> 80)
    MOV AL, 0
    OUT 127, AL                     ; Turn heater "OFF" by sending 0 to port 127

OK:
    JMP START                       ; Endless control loop

END

;=============================================================================
; THERMOSTAT LOGIC NOTES:
; - Goal: Maintain temperature in safety range (60-80).
; - Port 125: Returns current temp as a byte.
; - Port 127: Heater control (1=on, 0=off).
; - Air temp is assumed < 60 so default state cools down without heater.
; - Hysteresis prevents rapid oscillation (jitter) at a single degree threshold.
;=============================================================================
