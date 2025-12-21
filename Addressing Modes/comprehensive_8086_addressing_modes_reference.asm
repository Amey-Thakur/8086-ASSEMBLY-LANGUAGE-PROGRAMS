; =============================================================================
; TITLE: 8086 Addressing Modes - Complete Reference
; DESCRIPTION: A comprehensive demonstration of all 7 addressing modes of the 
;              Intel 8086 microprocessor. This program serves as a practical 
;              guide for understanding how the CPU accesses operands from 
;              registers and memory.
; AUTHOR: Amey Thakur (https://github.com/Amey-Thakur)
; REPOSITORY: https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
; LICENSE: MIT License
; =============================================================================

.MODEL SMALL
.STACK 100H

; =============================================================================
; DATA SEGMENT
; =============================================================================
.DATA
    ; Byte and Word variables for Direct and Indirect addressing
    VAR1 DB 10H                      ; Simple 8-bit variable
    VAR2 DW 1234H                    ; Simple 16-bit variable
    
    ; Array for demonstrating Indexed and Based addressing
    ARRAY DB 10H, 20H, 30H, 40H, 50H ; 5-byte data array
    
    ; Success message for visual confirmation
    MSG DB 'Addressing Modes Demo Completed Successfully!$', 0DH, 0AH, '$'

; =============================================================================
; CODE SEGMENT
; =============================================================================
.CODE
MAIN PROC
    ; --- Initialize Data Segment (Segment Addressing) ---
    ; In real mode, we must manually load the data segment address into DS.
    MOV AX, @DATA                    
    MOV DS, AX                       
    
    ; 1. IMMEDIATE ADDRESSING MODE
    ; -------------------------------------------------------------------------
    ; The operand is a constant value part of the instruction machine code.
    ; Pros: Fast execution, no memory bus cycles required.
    MOV AX, 1234H                    ; 16-bit constant to AX
    MOV BL, 56H                      ; 8-bit constant to BL
    MOV CX, 100                      ; Decimal constant (automatically converted)
    
    ; 2. REGISTER ADDRESSING MODE
    ; -------------------------------------------------------------------------
    ; Both source and destination operands are CPU registers.
    ; Pros: Fastest possible data transfer (internal to CPU).
    MOV AX, BX                       ; Copy 16-bit value from BX to AX
    MOV CL, DL                       ; Copy 8-bit value from DL to CL
    MOV SI, DI                       ; Transfer between index registers
    
    ; 3. DIRECT ADDRESSING MODE
    ; -------------------------------------------------------------------------
    ; The memory offset is specified directly in the instruction.
    ; The effectively address (EA) is provided by the displacement.
    MOV AL, VAR1                     ; Load byte from memory label VAR1
    MOV AX, VAR2                     ; Load word from memory label VAR2
    MOV VAR1, 20H                    ; Store immediate value directly into memory
    
    ; 4. REGISTER INDIRECT ADDRESSING MODE
    ; -------------------------------------------------------------------------
    ; The memory address is held in a pointer register (BX, SI, DI, or BP).
    ; Extremely useful for dynamic memory access and buffer handling.
    LEA BX, VAR1                     ; LEA: Load Effective Address of VAR1 into BX
    MOV AL, [BX]                     ; Access data at the address held in BX
    
    LEA SI, ARRAY                    ; SI points to start of ARRAY
    MOV AL, [SI]                     ; Access ARRAY[0]
    INC SI                           ; Increment pointer
    MOV AL, [SI]                     ; Access ARRAY[1]
    
    ; 5. INDEXED ADDRESSING MODE
    ; -------------------------------------------------------------------------
    ; Uses an index register (SI or DI) with an optional displacement.
    ; Ideal for array traversal.
    LEA DI, ARRAY                    ; DI = Base of array
    MOV SI, 2                        ; SI = Offset relative to base
    MOV AL, [DI+SI]                  ; Access ARRAY[2] (10H + 2 bytes = 30H)
    
    ; 6. BASED ADDRESSING MODE
    ; -------------------------------------------------------------------------
    ; Uses a base register (BX or BP) with a constant displacement.
    ; Commonly used for accessing structure fields or stack-based parameters.
    LEA BX, ARRAY                    ; BX points to array base
    MOV AL, [BX+0]                   ; Access byte at (BX + 0)
    MOV AL, [BX+1]                   ; Access byte at (BX + 1)
    MOV AL, [BX+2]                   ; Access byte at (BX + 2)
    MOV AL, [BX+4]                   ; Access byte at (BX + 4)
    
    ; 7. BASED-INDEXED ADDRESSING MODE
    ; -------------------------------------------------------------------------
    ; Combines a base register, an index register, and an optional displacement.
    ; Essential for accessing 2D arrays or complex record structures.
    LEA BX, ARRAY                    ; BX = Base address
    MOV SI, 1                        ; SI = Index offset
    MOV AL, [BX+SI]                  ; Accesses index 1 (20H)
    MOV AL, [BX+SI+1]                ; Accesses (Base + Index + 1) = index 2 (30H)
    MOV AL, [BX+SI+2]                ; Accesses (Base + Index + 2) = index 3 (40H)
    
    ; --- Display Status ---
    LEA DX, MSG                      
    MOV AH, 09H                      ; DOS function: Print String
    INT 21H                          
    
    ; --- Finalize Program ---
    MOV AH, 4CH                      ; DOS function: Terminate Process
    INT 21H                          
MAIN ENDP

; =============================================================================
; TECHNICAL NOTES & ARCHITECTURE DETAILS
; =============================================================================
; 1. PHYSICAL ADDRESS CALCULATION:
;    The 8086 generates a 20-bit physical address using a 16-bit segment and 
;    a 16-bit offset:
;    Physical Address = (Segment Register << 4) + Effective Address (Offset)
;    Example: If DS=1000H and BX=0020H, Physical Address = 10000H + 0020H = 10020H.
;
; 2. EFFECTIVE ADDRESS (EA) COMPONENTS:
;    EA = Base + Index + Displacement
;    - Base Register: BX or BP
;    - Index Register: SI or DI
;    - Displacement: 8-bit or 16-bit constant value
;
; 3. SEGMENT DEFAULTS:
;    - BX, SI, DI: Default to Data Segment (DS).
;    - BP, SP: Default to Stack Segment (SS).
;    - A segment override (e.g., MOV AL, ES:[BX]) can bypass these defaults.
;
; 4. LEA vs MOV:
;    - LEA (Load Effective Address): Calculates and loads the address itself.
;    - MOV: Loads the data stored at that address.
;
; 5. PERFORMANCE TRADE-OFFS:
;    - Register/Immediate: 0-2 clock cycles (no memory access).
;    - Memory Addressing: 5-12+ clock cycles (requires bus cycles to fetch data).
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

END MAIN
