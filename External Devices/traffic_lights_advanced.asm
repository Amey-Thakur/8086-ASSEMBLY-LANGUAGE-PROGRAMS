;=============================================================================
; Program:     Advanced Traffic Lights Control
; Description: Demonstrate complex bit-shifting techniques to control
;              multiple traffic lights on port 4.
; 
; Author:      Amey Thakur
; Repository:  https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
; License:     MIT License
;=============================================================================

#start=Traffic_Lights.exe#
NAME "traffic2"

;-----------------------------------------------------------------------------
; CONSTANTS: Light States (base 3 bits)
;-----------------------------------------------------------------------------
RED              EQU 0000_0001B      ; Red bit set
YELLOW_AND_RED   EQU 0000_0011B      ; Prepare to go
GREEN            EQU 0000_0100B      ; Green bit set
YELLOW_AND_GREEN EQU 0000_0110B      ; Prepare to stop

ALL_RED_BASE     EQU 0010_0100_1001B ; Red on all 4 directions

;-----------------------------------------------------------------------------
; CODE SEGMENT
;-----------------------------------------------------------------------------
START:
    NOP

    ;-------------------------------------------------------------------------
    ; Road Group 1 (Bits 0,1,2)
    ;-------------------------------------------------------------------------
    MOV AX, GREEN
    OUT 4, AX

    MOV AX, YELLOW_AND_GREEN 
    OUT 4, AX

    MOV AX, RED
    OUT 4, AX

    MOV AX, YELLOW_AND_RED
    OUT 4, AX

    ;-------------------------------------------------------------------------
    ; Road Group 2 (Bits 3,4,5) - Shifted by 3
    ;-------------------------------------------------------------------------
    MOV AX, GREEN << 3
    OUT 4, AX

    MOV AX, YELLOW_AND_GREEN << 3
    OUT 4, AX

    MOV AX, RED << 3
    OUT 4, AX

    MOV AX, YELLOW_AND_RED << 3
    OUT 4, AX

    ;-------------------------------------------------------------------------
    ; Road Group 3 (Bits 6,7,8) - Shifted by 6
    ;-------------------------------------------------------------------------
    MOV AX, GREEN << 6
    OUT 4, AX

    MOV AX, YELLOW_AND_GREEN << 6
    OUT 4, AX

    MOV AX, RED << 6
    OUT 4, AX

    MOV AX, YELLOW_AND_RED << 6
    OUT 4, AX

    ;-------------------------------------------------------------------------
    ; Road Group 4 (Bits 9,A,B) - Shifted by 9
    ;-------------------------------------------------------------------------
    MOV AX, GREEN << 9
    OUT 4, AX

    MOV AX, YELLOW_AND_GREEN << 9
    OUT 4, AX

    MOV AX, RED << 9
    OUT 4, AX

    MOV AX, YELLOW_AND_RED << 9
    OUT 4, AX

    ;-------------------------------------------------------------------------
    ; Global States
    ;-------------------------------------------------------------------------
    
    ; All Red
    MOV AX, ALL_RED_BASE
    OUT 4, AX

    ; All Yellow (By shifting Red bits once left)
    MOV AX, ALL_RED_BASE << 1
    OUT 4, AX

    ; All Green (By shifting Red bits twice left)
    MOV AX, ALL_RED_BASE << 2
    OUT 4, AX

    ; Loop back or Step through: 
    ; Better to use Step-by-Step mode in emulator for this program.
    JMP START

END

;=============================================================================
; BIT-SHIFTING CONTROL NOTES:
; - Instead of defining 16-bit patterns, we define 3-bit primitives.
; - Use assembly-time shifts (<<) to align primitives with junction bits.
; - Junction 1: Index 0 | Junction 2: Index 3 | Junction 3: Index 6 | Junction 4: Index 9
; - This makes the code modular and easier to understand than raw constants.
;=============================================================================
