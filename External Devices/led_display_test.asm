; =============================================================================
; TITLE: Virtual LED Display Control
; DESCRIPTION: Demonstrates I/O Port communication using the Emu8086 Virtual 
;              LED Display. It formats values for Port 199 to visualize numeric 
;              output.
; AUTHOR: Amey Thakur (https://github.com/Amey-Thakur)
; REPOSITORY: https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
; LICENSE: MIT License
; =============================================================================

; Emu8086 specific directives
#start=led_display.exe#

NAME "led_test"
#make_bin#

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
START:
    ; --- Step 1: Static Tests ---
    ; The LED display reads 16-bit signed integers from Port 199
    
    ; Test Positive
    MOV AX, 1234
    OUT 199, AX                         ; Display: "1234"
    
    ; Test Negative
    MOV AX, -5678
    OUT 199, AX                         ; Display: "-5678"
    
    ; --- Step 2: Dynamic Counter ---
    ; Rapidly incrementing counter to show update speed
    MOV AX, 0
    
PERPETUAL_LOOP:
    OUT 199, AX
    INC AX
    JMP PERPETUAL_LOOP                  ; Infinite Loop
    
    HLT                                 ; Never reached

END START

; =============================================================================
; TECHNICAL NOTES & ARCHITECTURAL INSIGHTS
; =============================================================================
; 1. I/O PORT ADDRESSING:
;    The 8086 has a separate 64KB I/O address space, distinct from Memory.
;    - IN AL, Port  / OUT Port, AL (8-bit)
;    - IN AX, Port  / OUT Port, AX (16-bit)
;    
; 2. EMU8086 VIRTUAL DEVICES:
;    Port 199 is hardcoded in the emulator to map to the LED Display tool.
;    Real hardware would use specific chipset addresses (e.g., 80h for POST).
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
