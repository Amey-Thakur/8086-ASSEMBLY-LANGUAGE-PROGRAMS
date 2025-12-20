;=============================================================================
; Program:     Traffic Junction Controller
; Description: Simulate a 4-way traffic light controller using port 4.
;              Sequences through various traffic situations with delays.
; 
; Author:      Amey Thakur
; Repository:  https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
; License:     MIT License
;=============================================================================

#start=Traffic_Lights.exe#
NAME "traffic"

;-----------------------------------------------------------------------------
; MAIN CODE SECTION
;-----------------------------------------------------------------------------

; Start with all lights red for safety
MOV AX, ALL_RED                                 
OUT 4, AX

LEA SI, SITUATION                   ; Point to sequence of light patterns

NEXT: 
    ; Output current situation to traffic light hardware (Port 4)
    MOV AX, [SI]
    OUT 4, AX
      
    ;-------------------------------------------------------------------------
    ; WAIT DELAY: 5 Seconds
    ; Using INT 15h / AH=86h
    ; 5,000,000 microseconds = 004C 4B40H
    ;-------------------------------------------------------------------------
    MOV CX, 004CH                   ; High word
    MOV DX, 4B40H                   ; Low word
    MOV AH, 86H                     ; BIOS: Wait
    INT 15H

    ; Move to next situation in table
    ADD SI, 2
    CMP SI, SIT_END                 ; End of table reached?
    JB NEXT                         ; If not, continue

    ; Loop back to first situation
    LEA SI, SITUATION
    JMP NEXT

;-----------------------------------------------------------------------------
; LIGHT PATTERN DATA (mapped to Port 4 bits)
; Pattern layout (16-bit): FEDC_BA98_7654_3210
; Each 3 bits controls 1 lamp (Green, Yellow, Red)
;-----------------------------------------------------------------------------

; Light Situations
SITUATION DW 0000_0011_0000_1100B
S1        DW 0000_0110_1001_1010B
S2        DW 0000_1000_0110_0001B
S3        DW 0000_1000_0110_0001B
S4        DW 0000_0100_1101_0011B 
SIT_END   = $

; Pre-defined constants
ALL_RED EQU 0000_0010_0100_1001B

END

;=============================================================================
; TRAFFIC LIGHT CONTROLLER NOTES:
; - Virtual hardware uses port 4 to control lamp states.
; - Bits mapped as: [..Yellow Red Green] for each road.
; - Road 1: Bits 0-2 | Road 2: Bits 3-5 | Road 3: Bits 6-8 | Road 4: Bits 9-11
; - Delay is crucial to allow traffic to clear intersections.
;=============================================================================