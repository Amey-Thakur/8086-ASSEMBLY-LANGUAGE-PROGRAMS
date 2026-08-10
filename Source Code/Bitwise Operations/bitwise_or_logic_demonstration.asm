; =============================================================================
; TITLE: Bitwise Logical OR Operation (Union & Flag Setting)
; DESCRIPTION: This program demonstrates the 8086 'OR' instruction, which 
;              performs a bitwise logical union between two 8-bit operands. 
;              It illustrates how OR can be used to set specific bits within 
;              a register while keeping other bits unchanged.
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
    ; Operands for bitwise union
    VAL_1    DB 0FH                     ; 0000 1111 (Lower nibble)
    VAL_2    DB 0F0H                    ; 1111 0000 (Upper nibble)
    
    ; Variable to capture the combined result
    UNION_RES DB ?                         

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------

    ; Labels for the report at the end of the program.
    RPT_HEAD DB 0DH, 0AH, 'Results:', 0DH, 0AH, '$'
    RPT_NL   DB 0DH, 0AH, '$'
    RPT_N_VAL_1 DB '  VAL_1 = ', '$'
    RPT_N_VAL_2 DB '  VAL_2 = ', '$'
    RPT_N_UNION_RES DB '  UNION_RES = ', '$'
.CODE
MAIN PROC
    ; --- Step 1: Initialize Data Segment ---
    MOV AX, @DATA
    MOV DS, AX
    
    ; --- Step 2: Load First Operand ---
    MOV AL, VAL_1                       ; AL = 0000 1111
    
    ; --- Step 3: Execute Bitwise OR ---
    ; Truth Table for OR:
    ; A=0, B=0 -> 0 | A=1, B=0 -> 1
    ; A=0, B=1 -> 1 | A=1, B=1 -> 1
    
    OR AL, VAL_2                        ; AL = (0000 1111) OR (1111 0000)
    
    ; Calculation Logic:
    ;   0000 1111
    ; | 1111 0000
    ; -----------
    ;   1111 1111 -> FFH (255)
    
    ; --- Step 4: Persist Result ---
    MOV UNION_RES, AL                     
    
    ; --- Step 5: Shutdown ---
    
    ; -------------------------------------------------------------------------
    ; WHAT THIS PROGRAM COMPUTED
    ;
    ; The work above leaves its answers in the variables below. Printing them
    ; is what makes the program demonstrate itself rather than needing a
    ; debugger to be believed.
    ; -------------------------------------------------------------------------
    LEA DX, RPT_HEAD
    CALL RPT_SAY

    LEA DX, RPT_N_VAL_1
    CALL RPT_SAY
    XOR AX, AX
    MOV AL, VAL_1
    CALL RPT_DECIMAL
    LEA DX, RPT_NL
    CALL RPT_SAY

    LEA DX, RPT_N_VAL_2
    CALL RPT_SAY
    XOR AX, AX
    MOV AL, VAL_2
    CALL RPT_DECIMAL
    LEA DX, RPT_NL
    CALL RPT_SAY

    LEA DX, RPT_N_UNION_RES
    CALL RPT_SAY
    XOR AX, AX
    MOV AL, UNION_RES
    CALL RPT_DECIMAL
    LEA DX, RPT_NL
    CALL RPT_SAY

    MOV AH, 4CH                         
    INT 21H
MAIN ENDP

; -----------------------------------------------------------------------------
; RPT_DECIMAL
;
; Prints the unsigned value in AX as decimal. Named apart from any helper the
; program already had, so adding this report cannot clash with it.
;
; The digits come out of the division lowest first, which is the wrong order to
; print them in, so they are pushed and then popped back off.
; -----------------------------------------------------------------------------
RPT_DECIMAL PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX

    XOR CX, CX
    MOV BX, 10

RPT_SPLIT:
    XOR DX, DX
    DIV BX
    PUSH DX
    INC CX
    CMP AX, 0
    JNE RPT_SPLIT

RPT_EMIT:
    POP DX
    ADD DL, '0'
    MOV AH, 02H
    INT 21H
    LOOP RPT_EMIT

    POP DX
    POP CX
    POP BX
    POP AX
    RET
RPT_DECIMAL ENDP

; -----------------------------------------------------------------------------
; RPT_SAY
;
; Prints the dollar terminated string at DS:DX without disturbing AX, which
; matters because the caller usually has the value it is about to print there.
; -----------------------------------------------------------------------------
RPT_SAY PROC
    PUSH AX
    MOV AH, 09H
    INT 21H
    POP AX
    RET
RPT_SAY ENDP


END MAIN

; =============================================================================
; TECHNICAL NOTES & ARCHITECTURAL INSIGHTS
; =============================================================================
; 1. SETTING BITS (SUPERPOSITION):
;    The OR instruction is the primary tool for "setting" bits to 1. By ORing 
;    a register with a bitmask, any bit corresponding to a '1' in the mask 
;    will be forced to '1' in the result, regardless of its previous state.
;
; 2. REGISTER-PERSISTENCE:
;    Wait, bits that are '0' in the mask leave the corresponding register bits 
;    unchanged. This property is vital for combining different independent 
;    status flags into a single control register.
;
; 3. FLAG REGISTER IMPACT (8086):
;    Executing an OR operation affects the status register:
;    - Carry Flag (CF) & Overflow Flag (OF): Always cleared to 0.
;    - Zero Flag (ZF): Set if the result is 0 (unlikely if setting bits).
;    - Sign Flag (SF): Set if the highest bit (Bit 7) is 1.
;    - Parity Flag (PF): Set for an even number of '1' bits in the result.
;
; 4. CASE TRANSITIONS (ASCII):
;    For ASCII characters, ORing a character with 20H (0010 0000) will 
;    guarantee it is lowercase, as Bit 5 distinguishes upper and lower case 
;    in the ASCII table.
;
; 5. HARDWARE EXECUTION:
;    OR is implemented using a set of parallel OR gates. It is an extremely 
;    efficient instruction, providing the maximum throughput possible on the 
;    8086's ALU.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
