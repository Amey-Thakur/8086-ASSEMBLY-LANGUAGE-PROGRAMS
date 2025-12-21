; =============================================================================
; TITLE: Unconditional Jump (JMP) and Program Redirection
; DESCRIPTION: This program demonstrates the 8086 'JMP' instruction, which 
;              causes an immediate, unconditional transfer of control to a 
;              target label by directly modifying the Instruction Pointer (IP).
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
    MSG_1         DB 'Step A: Initiating jump sequence...$'
    MSG_SKIP      DB 'Step B: This message is skipped (Dead Code)$'
    MSG_TARGET    DB 0DH, 0AH, 'Step C: Jump success! Reached destination.$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
MAIN PROC
    ; --- Step 1: Initialize Data Segment ---
    MOV AX, @DATA
    MOV DS, AX
    
    ; --- Step 2: Display Initial Message ---
    LEA DX, MSG_1
    MOV AH, 09H
    INT 21H
    
    ; --- Step 3: The Unconditional Jump ---
    ; This instruction forces the CPU to skip the subsequent lines of code.
    JMP L_DESTINATION                   
    
    ; --- Step 4: Dead Code Section ---
    ; This block will never be reached during normal execution flow.
    LEA DX, MSG_SKIP
    MOV AH, 09H
    INT 21H
    
L_DESTINATION:
    ; --- Step 5: Jump Target ---
    LEA DX, MSG_TARGET
    MOV AH, 09H
    INT 21H
    
    ; --- Step 6: Shutdown ---
    MOV AH, 4CH
    INT 21H
MAIN ENDP

END MAIN

; =============================================================================
; TECHNICAL NOTES & ARCHITECTURAL INSIGHTS
; =============================================================================
; 1. JMP INSTRUCTION VARIANTS:
;    - SHORT JMP (2 bytes): EB + 8-bit signed displacement. Range: -128 to +127 
;      bytes. The CPU simply adds the displacement to the IP.
;    - NEAR JMP (3 bytes): E9 + 16-bit signed displacement. Range: Within the 
;      same code segment (+/- 32KB).
;    - FAR JMP (5 bytes): EA + 16-bit offset + 16-bit segment. Allows jumping 
;      to a completely different segment by modifying both CS and IP.
;
; 2. INDIRECT JUMPING:
;    JMP can also target registers or memory locations (e.g., JMP AX or 
;    JMP WORD PTR [BX]). The CPU loads the content of the register/memory 
;    into the IP, allowing for dynamic branching.
;
; 3. PIPELINE DISRUPTION:
;    Modern CPUs use Branch Target Buffers (BTB) to predict JMPs. On the 
;    original 8086, a 'JMP' immediately flushes the prefetch queue because 
;    the "next" instruction is no longer sequentially following the current one.
;
; 4. DEAD CODE ELIMINATION:
;    Compilers identify code following an unconditional JMP (that isn't 
;    labeled as a destination) as "Dead Code" and often remove it during 
;    optimization to save memory space.
;
; 5. THE 'SHORT' ATTRIBUTE:
;    If you know a jump is very close, you can hint the assembler: 'JMP SHORT label'. 
;    This forces a 2-byte instruction instead of a 3-byte NEAR jump.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
