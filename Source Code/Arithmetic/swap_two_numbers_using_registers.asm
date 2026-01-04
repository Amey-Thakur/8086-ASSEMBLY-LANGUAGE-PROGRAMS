; =============================================================================
; TITLE: Register-to-Register Value Swapping Techniques
; DESCRIPTION: This program demonstrates several methods to exchange the 
;              contents of two 8086 registers. It covers the atomic XCHG 
;              instruction and the classic Bitwise XOR algorithm, ensuring 
;              the developer understands the trade-offs between hardware-level 
;              exchange and logical manipulation.
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
    VAL_A DW 10                         
    VAL_B DW 20                         
    
    ; Display Strings
    MSG_BEFORE DB 'State [BEFORE Swap]: $'
    MSG_AFTER1 DB 0DH, 0AH, 'State [AFTER XCHG]: $'
    MSG_AFTER2 DB 0DH, 0AH, 'State [AFTER XOR ]: $'
    MSG_SEP    DB ', $'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
MAIN PROC
    ; --- Step 1: Initialization ---
    MOV AX, @DATA
    MOV DS, AX
    
    ; --- Step 2: Show Initial State ---
    LEA DX, MSG_BEFORE
    MOV AH, 09H
    INT 21H
    
    MOV AX, VAL_A
    CALL PRINT_DECIMAL
    
    LEA DX, MSG_SEP
    MOV AH, 09H
    INT 21H
    
    MOV AX, VAL_B
    CALL PRINT_DECIMAL
    
    ; --- Step 3: Method 1 - The Atomic XCHG Instruction ---
    ; This is the most efficient and readable method in x86.
    MOV AX, VAL_A
    MOV BX, VAL_B
    XCHG AX, BX                         ; Atomic swap of AX and BX
    MOV VAL_A, AX
    MOV VAL_B, BX
    
    ; Display Results
    LEA DX, MSG_AFTER1
    MOV AH, 09H
    INT 21H
    
    MOV AX, VAL_A
    CALL PRINT_DECIMAL
    
    LEA DX, MSG_SEP
    MOV AH, 09H
    INT 21H
    
    MOV AX, VAL_B
    CALL PRINT_DECIMAL
    
    ; --- Step 4: Method 2 - The Bitwise XOR Algorithm ---
    ; Reset values for demonstration
    MOV VAL_A, 10
    MOV VAL_B, 20
    
    MOV AX, VAL_A
    MOV BX, VAL_B
    
    ; Logical Swap: A=A^B, B=A^B, A=A^B
    XOR AX, BX       
    XOR BX, AX       
    XOR AX, BX       
    
    MOV VAL_A, AX
    MOV VAL_B, BX
    
    ; Display Results
    LEA DX, MSG_AFTER2
    MOV AH, 09H
    INT 21H
    
    MOV AX, VAL_A
    CALL PRINT_DECIMAL
    
    LEA DX, MSG_SEP
    MOV AH, 09H
    INT 21H
    
    MOV AX, VAL_B
    CALL PRINT_DECIMAL
    
    ; --- Step 5: Finalize Program ---
    MOV AH, 4CH
    INT 21H
MAIN ENDP

; -----------------------------------------------------------------------------
; PROCEDURE: PRINT_DECIMAL
; DESCRIPTION: Prints a 16-bit unsigned value to the screen in base-10.
; -----------------------------------------------------------------------------
PRINT_DECIMAL PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    
    XOR CX, CX
    MOV BX, 10
    
L_DIV_LOOP:
    XOR DX, DX
    DIV BX
    PUSH DX
    INC CX
    CMP AX, 0
    JNE L_DIV_LOOP
    
L_PRINT_LOOP:
    POP DX
    ADD DL, '0'
    MOV AH, 02H
    INT 21H
    LOOP L_PRINT_LOOP
    
    POP DX
    POP CX
    POP BX
    POP AX
    RET
PRINT_DECIMAL ENDP

END MAIN

; =============================================================================
; TECHNICAL NOTES & ARCHITECTURAL INSIGHTS
; =============================================================================
; 1. XCHG (THE HARDWARE WAY):
;    The XCHG instruction is highly optimized. In multi-processor environments, 
;    XCHG with a memory operand often triggers a "LOCK" signal on the bus, 
;    preventing other processors from accessing that memory during the swap.
;
; 2. XOR SWAP (THE LOGICAL WAY):
;    The XOR method is a clever trick to swap two variables without a third 
;    "Temp" register. It relies on the property that (A XOR B) XOR A = B.
;    - ADVANTAGE: Zero temporary memory/register usage.
;    - DISADVANTAGE: Slower than XCHG and fails if A and B point to the exact 
;      same memory address (aliasing), as A XOR A results in 0.
;
; 3. REGISTER-MEMORY LIMITATION:
;    The 8086 cannot perform XCHG directly between two memory locations. 
;    One value must be loaded into a register first.
;
; 4. ATOMICITY:
;    XCHG is considered an atomic operation at the CPU level.
;
; 5. PERFORMANCE:
;    On an original 8086:
;    - XCHG Reg, Reg: 4 clock cycles.
;    - XOR Reg, Reg (x3): 3 * 3 = 9 clock cycles.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
