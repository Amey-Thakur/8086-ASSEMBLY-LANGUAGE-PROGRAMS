;=============================================================================
; Program:     Unconditional Jump (JMP)
; Description: Demonstrate the unconditional jump instruction.
;              JMP transfers control without any condition check.
; 
; Author:      Amey Thakur
; Repository:  https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
; License:     MIT License
;=============================================================================

.MODEL SMALL
.STACK 100H

;-----------------------------------------------------------------------------
; DATA SEGMENT
;-----------------------------------------------------------------------------
.DATA
    MSG1 DB 'Step 1: Before jump$'
    MSG2 DB 0DH, 0AH, 'Step 2: Skipped by jump$'
    MSG3 DB 0DH, 0AH, 'Step 3: After jump target$'

;-----------------------------------------------------------------------------
; CODE SEGMENT
;-----------------------------------------------------------------------------
.CODE
MAIN PROC
    ; Initialize Data Segment
    MOV AX, @DATA
    MOV DS, AX
    
    ;-------------------------------------------------------------------------
    ; Display Step 1
    ;-------------------------------------------------------------------------
    LEA DX, MSG1
    MOV AH, 09H
    INT 21H
    
    ;-------------------------------------------------------------------------
    ; Unconditional Jump - Always jumps to target
    ; This skips Step 2 entirely
    ;-------------------------------------------------------------------------
    JMP SKIP_STEP2                      ; Jump unconditionally
    
    ;-------------------------------------------------------------------------
    ; This code is NEVER executed (dead code)
    ;-------------------------------------------------------------------------
    LEA DX, MSG2
    MOV AH, 09H
    INT 21H
    
SKIP_STEP2:
    ;-------------------------------------------------------------------------
    ; Display Step 3 (jump target)
    ;-------------------------------------------------------------------------
    LEA DX, MSG3
    MOV AH, 09H
    INT 21H
    
    ;-------------------------------------------------------------------------
    ; Program Termination
    ;-------------------------------------------------------------------------
    MOV AH, 4CH                         ; DOS: Terminate program
    INT 21H
MAIN ENDP
END MAIN

;=============================================================================
; JMP INSTRUCTION TYPES:
; 
; 1. Short Jump (JMP SHORT label)
;    - Range: -128 to +127 bytes from current IP
;    - 2 bytes: EB + 8-bit displacement
; 
; 2. Near Jump (JMP label)
;    - Range: Within same segment (±32KB)
;    - 3 bytes: E9 + 16-bit displacement
; 
; 3. Far Jump (JMP FAR PTR label)
;    - Range: Any segment
;    - 5 bytes: EA + offset + segment
; 
; 4. Indirect Jump (JMP [BX] or JMP WORD PTR [address])
;    - Target address stored in memory or register
;=============================================================================
