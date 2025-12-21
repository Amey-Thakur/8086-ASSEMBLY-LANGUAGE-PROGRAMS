; =============================================================================
; TITLE: Time Delay Utilities
; DESCRIPTION: A collection of methods to create pauses in program execution 
;              using software loops and BIOS clock ticks.
; AUTHOR: Amey Thakur (https://github.com/Amey-Thakur)
; REPOSITORY: https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
; LICENSE: MIT License
; =============================================================================

.MODEL SMALL
.STACK 100H

; -----------------------------------------------------------------------------
; DATA SEGMENT
; -----------------------------------------------------------------------------
.DATA
    MSG1 DB 'Starting approximately 1-second delay...', 0DH, 0AH, '$'
    MSG2 DB 'Delay complete!', 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
MAIN PROC
    ; Initialize the Data Segment
    MOV AX, @DATA
    MOV DS, AX
    
    ; Output start message
    LEA DX, MSG1
    MOV AH, 09H
    INT 21H
    
    ; --- Method 1: CPU-Based Busy-Wait Loop ---
    ; This method depends on the instruction execution speed of the CPU.
    ; On a real 8086 at 4.77MHz, this is roughly 1 second.
    CALL DELAY_1SEC_LOOP
    
    ; Output completion message
    LEA DX, MSG2
    MOV AH, 09H
    INT 21H
    
    ; Clean termination
    MOV AH, 4CH
    INT 21H
MAIN ENDP

; --- DELAY_1SEC_LOOP PROC ---
; Uses nested loops (CX and DX) to consume CPU cycles.
; Complexity: O(N*M), where N is outer count and M is inner count.
DELAY_1SEC_LOOP PROC
    PUSH CX
    PUSH DX
    
    MOV CX, 0FFFFH       ; Outer loop counter (max 65535)
OUTER_LAYER:
    MOV DX, 00FFH        ; Inner loop counter
INNER_LAYER:
    DEC DX
    JNZ INNER_LAYER      ; Continue inner loop until DX is 0
    LOOP OUTER_LAYER     ; Decrement CX and repeat if CX != 0
    
    POP DX
    POP CX
    RET
DELAY_1SEC_LOOP ENDP

; --- DELAY_BIOS PROC ---
; A more precise delay using the BIOS Real-Time Clock (RTC) ticks.
; BIOS updates the tick count at Port 0040:006C roughly 18.2 times per second.
DELAY_BIOS PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    
    ; INT 1AH, AH=00H: Read System-Timer Time Counter
    ; Returns: CX:DX = tick count (since midnight)
    MOV AH, 00H
    INT 1AH
    
    MOV BX, DX           ; Save the current lower 16-bit tick count
    
    ; Wait for ~18 ticks (roughly 1 second)
    ; Add desired number of ticks to current count
    ADD BX, 18           
    
WAIT_TICK:
    MOV AH, 00H
    INT 1AH              ; Read time again
    CMP DX, BX           ; Compare current DX with target BX
    JB WAIT_TICK         ; Jump back if current tick < target tick
    
    POP DX
    POP CX
    POP BX
    POP AX
    RET
DELAY_BIOS ENDP

END MAIN

; =============================================================================
; TECHNICAL NOTES
; =============================================================================
; 1. CLOCK TICKS:
;    - IBM PC BIOS increments a tick counter (at 0040:006Ch) every 55ms.
;    - Based on PIT frequency (18.2 Hz).
; 2. BUSY-WAITING: 
;    - Method 1 (Nested Loops) is unreliable on modern CPUs/Emulators.
; 3. PRECISION: 
;    - INT 1AH (Method 2) is the standard DOS way for non-critical timing.
;    - Relies on hardware interrupt, not CPU speed.
; 4. OVERFLOW:
;    - Method 2 has a subtle bug if BX overflows 65535 near 16-bit boundary.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
