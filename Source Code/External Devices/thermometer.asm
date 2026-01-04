; =============================================================================
; TITLE: Digital Thermostat Controller
; DESCRIPTION: Simulates a hysteresis-based temperature control system. 
;              Monitors a virtual thermometer and toggles a heater component 
;              to maintain temperature between 60"C and 80"C.
; AUTHOR: Amey Thakur (https://github.com/Amey-Thakur)
; REPOSITORY: https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
; LICENSE: MIT License
; =============================================================================

#start=thermometer.exe#
NAME "thermo"
#make_bin#

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
START:
    ; --- Step 1: Main Control Loop ---
    ; READ Temperature (Input Port 125)
    IN AL, 125
    
    ; --- Step 2: Hysteresis Logic ---
    ; Low Threshold: 60 degrees
    CMP AL, 60
    JL L_HEAT_ON
    
    ; High Threshold: 80 degrees
    CMP AL, 80
    JG L_HEAT_OFF
    
    ; Else: Maintain State
    JMP START

L_HEAT_ON:
    ; Turn Heater ON (Output Port 127 = 1)
    MOV AL, 1
    OUT 127, AL
    JMP START

L_HEAT_OFF:
    ; Turn Heater OFF (Output Port 127 = 0)
    MOV AL, 0
    OUT 127, AL
    JMP START

END

; =============================================================================
; TECHNICAL NOTES & ARCHITECTURAL INSIGHTS
; =============================================================================
; 1. HYSTERESIS CONTROL:
;    Simple On/Off control at a single point causes rapid switching (chatter) 
;    if the temperature fluctuates near the setpoint.
;    Hysteresis adds a "deadband" (60-80 range) where the heater state 
;    remains unchanged, ensuring system stability.
;
; 2. VIRTUAL HARDWARE:
;    - Port 125: Thermometer Data (0-255 degrees)
;    - Port 127: Heater Relay Control (1=On, 0=Off)
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
