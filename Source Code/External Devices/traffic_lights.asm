; =============================================================================
; TITLE: 4-Way Traffic Light Controller
; DESCRIPTION: Controls a 4-way intersection traffic light system using Port 4.
;              Sequences through standard Red-Green transitions with delays.
; AUTHOR: Amey Thakur (https://github.com/Amey-Thakur)
; REPOSITORY: https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
; LICENSE: MIT License
; =============================================================================

#start=Traffic_Lights.exe#
NAME "traffic"

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
START:
    ; --- Step 1: Initialize (All Red) ---
    MOV AX, STATE_ALL_RED
    OUT 4, AX
    
    ; Pointer to Sequence Table
    LEA SI, SEQUENCE_TABLE
    
L_SEQUENCE:
    ; --- Step 2: Output State ---
    MOV AX, [SI]
    CMP AX, 0FFFFH                  ; Check for Terminator
    JE L_RESET
    
    OUT 4, AX
    
    ; --- Step 3: Wait (Simulated) ---
    ; 2,000,000 microseconds = 2 seconds
    MOV CX, 001EH                   ; High Word
    MOV DX, 8480H                   ; Low Word
    MOV AH, 86H
    INT 15H
    
    ADD SI, 2                       ; Next Word
    JMP L_SEQUENCE
    
L_RESET:
    LEA SI, SEQUENCE_TABLE
    JMP L_SEQUENCE

; -----------------------------------------------------------------------------
; DATA TABLE (16-bit Port Patterns)
; -----------------------------------------------------------------------------
; Bit Mapping: [Road4: Y R G] [Road3: Y R G] [Road2: Y R G] [Road1: Y R G]
; Note: The specific mapping depends on the Emulator's hardware wiring.
; Typical: ... R G Y ...
STATE_ALL_RED EQU 0010_0100_1001B   ; Example Safety

SEQUENCE_TABLE DW 0010_0100_1001B   ; State 1
               DW 0011_0100_1001B   ; State 2
               DW 1000_0100_1001B   ; State 3
               DW 0010_0100_1100B   ; State 4
               DW 0FFFFH            ; End Marker

END

; =============================================================================
; TECHNICAL NOTES & ARCHITECTURAL INSIGHTS
; =============================================================================
; 1. PORT 4 CONTROL:
;    The Traffic Light device listens on Port 4. Sending a 16-bit word controls
;    12 lamps (4 roads * 3 lights).
;    
; 2. TABLE-DRIVEN DESIGN:
;    Instead of hardcoding MOV/OUT instructions for every state, we define 
;    a table of states. This allows easy modification of the timing sequence 
;    without rewriting code logic.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =