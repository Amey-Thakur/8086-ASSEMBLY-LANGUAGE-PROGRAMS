;=============================================================================
; Program:     LED Display Test
; Description: Demonstrate how to access virtual I/O ports in Emu8086.
;              This program sends numeric values to a virtual LED display
;              emulated on port 199.
; 
; Author:      Amey Thakur
; Repository:  https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
; License:     MIT License
;=============================================================================

#start=led_display.exe#
#make_bin#

NAME "led"

;-----------------------------------------------------------------------------
; CODE SEGMENT
;-----------------------------------------------------------------------------
; This program demonstrates the 'OUT' instruction which outputs data to a port.
; Port 199 is used by the Emu8086 virtual LED display device.
;-----------------------------------------------------------------------------

; Send static values to the display
MOV AX, 1234
OUT 199, AX                         ; Display '1234'

MOV AX, -5678
OUT 199, AX                         ; Display '-5678' (signed representation)

;-----------------------------------------------------------------------------
; Counter Loop: Continuously increment and display a value
;-----------------------------------------------------------------------------
MOV AX, 0                           ; Starting value
X1:
    OUT 199, AX                     ; Send value to LED display port
    INC AX                          ; Increment value
    JMP X1                          ; Loop infinitely

HLT                                 ; Halt processor (reachable if loop ends)

;=============================================================================
; LED DISPLAY NOTES:
; - Emu8086 supports virtual hardware components via I/O ports.
; - The LED display responds to 16-bit values sent to port 199.
; - 'OUT port, ax' is the standard instruction for hardware communication.
; - Visual devices are found in the 'Virtual Devices' menu of Emu8086.
;=============================================================================
