; TITLE: 8086 Addressing Modes - Complete Reference
; DESCRIPTION: Demonstrates all 7 addressing modes of the Intel 8086 microprocessor with practical examples.
; AUTHOR: Amey Thakur (https://github.com/Amey-Thakur)
; REPOSITORY: https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
; LICENSE: MIT License

.MODEL SMALL
.STACK 100H

;-----------------------------------------------------------------------------
; DATA SEGMENT
; Define variables and arrays for demonstrating different addressing modes
;-----------------------------------------------------------------------------
.DATA
    VAR1 DB 10H                      ; Byte variable (1 byte)
    VAR2 DW 1234H                    ; Word variable (2 bytes)
    ARRAY DB 10H, 20H, 30H, 40H, 50H ; Array of 5 bytes
    MSG DB 'Addressing Modes Demo Completed Successfully!$', 0DH, 0AH, '$'

;-----------------------------------------------------------------------------
; CODE SEGMENT
; Main program demonstrating all 8086 addressing modes
;-----------------------------------------------------------------------------
.CODE
MAIN PROC
    ; Initialize Data Segment
    MOV AX, @DATA                    ; Load data segment address
    MOV DS, AX                       ; Set DS register
    
    ;=========================================================================
    ; 1. IMMEDIATE ADDRESSING MODE
    ; The operand is a constant value embedded in the instruction itself.
    ; Fastest mode as no memory access is needed.
    ; Syntax: MOV destination, immediate_value
    ;=========================================================================
    MOV AX, 1234H                    ; Load 16-bit immediate value into AX
    MOV BL, 56H                      ; Load 8-bit immediate value into BL
    MOV CX, 100                      ; Decimal immediate value
    
    ;=========================================================================
    ; 2. REGISTER ADDRESSING MODE
    ; Both operands are CPU registers. Data transfer between registers.
    ; Very fast as no memory access is required.
    ; Syntax: MOV register1, register2
    ;=========================================================================
    MOV AX, BX                       ; Copy BX to AX (16-bit)
    MOV CL, DL                       ; Copy DL to CL (8-bit)
    MOV SI, DI                       ; Copy DI to SI (index registers)
    
    ;=========================================================================
    ; 3. DIRECT ADDRESSING MODE
    ; The operand's memory address is specified directly in the instruction.
    ; Address is the offset within the data segment.
    ; Syntax: MOV register, [address] or MOV register, variable_name
    ;=========================================================================
    MOV AL, VAR1                     ; Load byte from memory location VAR1
    MOV AX, VAR2                     ; Load word from memory location VAR2
    MOV VAR1, 20H                    ; Store immediate to memory directly
    
    ;=========================================================================
    ; 4. REGISTER INDIRECT ADDRESSING MODE
    ; The memory address is contained in a register (BX, SI, DI, or BP).
    ; The register acts as a pointer to the memory location.
    ; Syntax: MOV register, [pointer_register]
    ;=========================================================================
    LEA BX, VAR1                     ; Load Effective Address of VAR1 into BX
    MOV AL, [BX]                     ; Access memory via BX (indirect)
    
    LEA SI, ARRAY                    ; Point SI to ARRAY start
    MOV AL, [SI]                     ; Get first element (10H)
    INC SI                           ; Move to next element
    MOV AL, [SI]                     ; Get second element (20H)
    
    ;=========================================================================
    ; 5. INDEXED ADDRESSING MODE
    ; Uses index registers (SI or DI) with a displacement/base.
    ; Useful for array traversal with calculated offsets.
    ; Syntax: MOV register, [base + index]
    ;=========================================================================
    LEA DI, ARRAY                    ; Load base address of ARRAY
    MOV SI, 2                        ; Set index to 2
    MOV AL, [DI+SI]                  ; Access ARRAY[2] = 30H
    
    ;=========================================================================
    ; 6. BASED ADDRESSING MODE
    ; Uses base register (BX or BP) with a displacement (constant offset).
    ; Commonly used for accessing structure members or stack frames.
    ; Syntax: MOV register, [base_register + displacement]
    ;=========================================================================
    LEA BX, ARRAY                    ; BX points to ARRAY base
    MOV AL, [BX+0]                   ; ARRAY[0] = 10H
    MOV AL, [BX+1]                   ; ARRAY[1] = 20H
    MOV AL, [BX+2]                   ; ARRAY[2] = 30H
    MOV AL, [BX+4]                   ; ARRAY[4] = 50H
    
    ;=========================================================================
    ; 7. BASED-INDEXED ADDRESSING MODE
    ; Combines base register, index register, and displacement.
    ; Most flexible mode for complex data structure access.
    ; Syntax: MOV register, [base + index + displacement]
    ;=========================================================================
    LEA BX, ARRAY                    ; Base address
    MOV SI, 1                        ; Index offset
    MOV AL, [BX+SI]                  ; ARRAY[1] = 20H
    MOV AL, [BX+SI+1]                ; ARRAY[1+1] = ARRAY[2] = 30H
    MOV AL, [BX+SI+2]                ; ARRAY[1+2] = ARRAY[3] = 40H
    
    ;-------------------------------------------------------------------------
    ; Display completion message
    ;-------------------------------------------------------------------------
    LEA DX, MSG                      ; Load message address
    MOV AH, 09H                      ; DOS: Display string function
    INT 21H                          ; Call DOS interrupt
    
    ;-------------------------------------------------------------------------
    ; Program termination
    ;-------------------------------------------------------------------------
    MOV AH, 4CH                      ; DOS: Terminate program function
    INT 21H                          ; Return to DOS
MAIN ENDP

;=============================================================================
; ADDRESSING MODES QUICK REFERENCE
;=============================================================================
; Mode              | Syntax Example           | Description
;-------------------|--------------------------|------------------------------
; 1. Immediate      | MOV AX, 1234H            | Operand is constant value
; 2. Register       | MOV AX, BX               | Operand is register
; 3. Direct         | MOV AX, VAR              | Direct memory offset
; 4. Indirect       | MOV AX, [BX]             | Address in BX, SI, or DI
; 5. Indexed        | MOV AX, [SI+4]           | Index + displacement
; 6. Based          | MOV AX, [BX+4]           | Base + displacement
; 7. Based-Indexed  | MOV AX, [BX+SI+4]        | Base + index + displacement
;=============================================================================

; =============================================================================
; NOTES:
; 1. PHYSICAL ADDRESS CALCULATION: 8086 uses a 20-bit address.
;    Physical Address = (Segment Register * 10H) + Effective Address (Offset)
; 2. DEFAULT SEGMENTS:
;    - BX, SI, DI usually refer to the Data Segment (DS).
;    - BP (Base Pointer) usually refers to the Stack Segment (SS).
; 3. EFFECTIVE ADDRESS (EA): The final offset calculated by the CPU using the 
;    above components (Base + Index + Displacement).
; 4. PERFORMANCE: Register and Immediate modes are the fastest as they do not 
;    require external memory bus cycles.
; =============================================================================

END MAIN
