; =============================================================================
; TITLE: Advanced Traffic Control (Bitwise Ops)
; DESCRIPTION: Demonstrates controlling traffic lights using Bitwise Shifting 
;              operators to construct complex port signals dynamically.
; AUTHOR: Amey Thakur (https://github.com/Amey-Thakur)
; REPOSITORY: https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
; LICENSE: MIT License
; =============================================================================

#start=Traffic_Lights.exe#
NAME "traffic_adv"

; -----------------------------------------------------------------------------
; CONSTANTS (Primitive States)
; -----------------------------------------------------------------------------
; Base Pattern (Road 1 Position)
SIG_RED     EQU 001B
SIG_YELLOW  EQU 010B
SIG_GREEN   EQU 100B
SIG_RED_YEL EQU 011B

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
START:
    ; --- DEMONSTRATION 1: Road 1 Cycle ---
    
    ; Red
    MOV AX, SIG_RED
    OUT 4, AX
    
    ; Yellow + Red (Ready)
    MOV AX, SIG_RED_YEL
    OUT 4, AX
    
    ; Green
    MOV AX, SIG_GREEN
    OUT 4, AX
    
    ; --- DEMONSTRATION 2: Road 2 Cycle (Shifted) ---
    ; Road 2 is bits 3-5. We shift primitive states left by 3.
    
    ; Red
    MOV AX, SIG_RED
    SHL AX, 3
    OUT 4, AX
    
    ; Green
    MOV AX, SIG_GREEN
    SHL AX, 3
    OUT 4, AX
    
    ; --- DEMONSTRATION 3: All Roads Red (Composition) ---
    ; R4(Red) | R3(Red) | R2(Red) | R1(Red)
    ; Shift Red into positions 9, 6, 3, 0
    
    MOV AX, 0
    OR  AX, SIG_RED             ; Road 1
    
    MOV BX, SIG_RED
    SHL BX, 3
    OR  AX, BX                  ; Road 2
    
    MOV BX, SIG_RED
    SHL BX, 6
    OR  AX, BX                  ; Road 3
    
    MOV BX, SIG_RED
    SHL BX, 9
    OR  AX, BX                  ; Road 4
    
    OUT 4, AX
    
    JMP START

END

; =============================================================================
; TECHNICAL NOTES & ARCHITECTURAL INSIGHTS
; =============================================================================
; 1. BITWISE COMPOSITION:
;    Hardcoding 16-bit values (e.g., 001001001001b) is error-prone and hard to 
;    read. Using Shifts (SHL) and Logic (OR) allows us to build the signal 
;    semantically: "Road 1 Red AND Road 2 Green".
;
; 2. ASSEMBLY TIME CONSTANTS:
;    We can also do (SIG_RED << 3) in the assembler if supported, but doing it 
;    via instructions (SHL AX, 3) demonstrates the CPU's capability to manipulate 
;    fields dynamically at runtime.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
