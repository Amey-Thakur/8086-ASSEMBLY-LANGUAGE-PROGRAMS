;=============================================================================
; Program:     Flags Register Operations
; Description: Demonstrate the 8086 Status Flags (CF, ZF, SF, OF) and 
;              manipulation instructions (CLC, STC, CMC).
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
    MSG_CF DB 'Testing Carry Flag (CF)... Done$'
    MSG_ZF DB 0DH, 0AH, 'Testing Zero Flag (ZF)... Done$'
    MSG_SF DB 0DH, 0AH, 'Testing Sign Flag (SF)... Done$'
    MSG_OF DB 0DH, 0AH, 'Testing Overflow Flag (OF)... Done$'
    NEWLINE DB 0DH, 0AH, '$'

;-----------------------------------------------------------------------------
; CODE SEGMENT
;-----------------------------------------------------------------------------
.CODE
MAIN PROC
    ; Initialize Data Segment
    MOV AX, @DATA
    MOV DS, AX
    
    ;-------------------------------------------------------------------------
    ; 1. CARRY FLAG (CF)
    ; Set on unsigned overflow or explicitly via instructions.
    ;-------------------------------------------------------------------------
    LEA DX, MSG_CF
    MOV AH, 09H
    INT 21H
    
    MOV AL, 0FFH
    ADD AL, 1                           ; AL=0, CF=1 (unsigned overflow)
    
    CLC                                 ; Clear Carry Flag (CF=0)
    STC                                 ; Set Carry Flag (CF=1)
    CMC                                 ; Complement Carry Flag (Toggle)
    
    ;-------------------------------------------------------------------------
    ; 2. ZERO FLAG (ZF)
    ; Set when result of an arithmetic or logic operation is zero.
    ;-------------------------------------------------------------------------
    LEA DX, MSG_ZF
    MOV AH, 09H
    INT 21H
    
    MOV AX, 10
    SUB AX, 10                          ; Result=0, ZF=1
    
    ;-------------------------------------------------------------------------
    ; 3. SIGN FLAG (SF)
    ; Set when the Most Significant Bit (MSB) of the result is 1 (negative).
    ;-------------------------------------------------------------------------
    LEA DX, MSG_SF
    MOV AH, 09H
    INT 21H
    
    MOV AX, 5
    SUB AX, 10                          ; Result=-5, SF=1
    
    ;-------------------------------------------------------------------------
    ; 4. OVERFLOW FLAG (OF)
    ; Set when a signed arithmetic operation result exceeds range.
    ;-------------------------------------------------------------------------
    LEA DX, MSG_OF
    MOV AH, 09H
    INT 21H
    
    ; 8-bit signed range: -128 to +127
    MOV AL, 127                         ; Max positive signed byte
    ADD AL, 1                           ; Result=128 (interpreted as -128), OF=1
    
    ;-------------------------------------------------------------------------
    ; Program Termination
    ;-------------------------------------------------------------------------
    MOV AH, 4CH
    INT 21H
MAIN ENDP
END MAIN

;=============================================================================
; 8086 FLAGS REGISTER (16-BIT) REFERENCE:
; Bit | Name | Description
; ----|------|----------------------------------------------------------------
; CF  | Carry| Set if there is a carry out from MSB (unsigned overflow)
; PF  |Parity| Set if result has even number of 1-bits
; AF  | Aux  | Set if there is a carry from bit 3 to bit 4 (for BCD)
; ZF  | Zero | Set if result is zero
; SF  | Sign | Set if result's MSB is 1 (negative result)
; TF  | Trap | Set to allow single-stepping (debugger)
; IF  | Int  | Set to enable hardware interrupts
; DF  | Dir  | Set to process strings from high to low address
; OF  | Over | Set if signed overflow occurs
;=============================================================================
