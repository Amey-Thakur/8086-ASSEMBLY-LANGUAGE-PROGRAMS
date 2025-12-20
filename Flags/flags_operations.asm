; Program: Flags Register Operations
; Description: Demonstrate CPU flags and their usage
; Author: Amey Thakur

.MODEL SMALL
.STACK 100H

.DATA
    MSG_CF DB 'Testing Carry Flag (CF)$'
    MSG_ZF DB 0DH, 0AH, 'Testing Zero Flag (ZF)$'
    MSG_SF DB 0DH, 0AH, 'Testing Sign Flag (SF)$'
    MSG_OF DB 0DH, 0AH, 'Testing Overflow Flag (OF)$'
    NEWLINE DB 0DH, 0AH, '$'

.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX
    
    ; === CARRY FLAG (CF) ===
    LEA DX, MSG_CF
    MOV AH, 09H
    INT 21H
    
    ; Set CF by adding with carry
    MOV AL, 0FFH
    ADD AL, 1        ; CF = 1 (overflow in unsigned)
    
    ; Clear CF
    CLC              ; Clear Carry Flag
    
    ; Set CF
    STC              ; Set Carry Flag
    
    ; Complement CF
    CMC              ; Complement Carry Flag
    
    ; === ZERO FLAG (ZF) ===
    LEA DX, MSG_ZF
    MOV AH, 09H
    INT 21H
    
    ; Set ZF
    MOV AX, 10
    SUB AX, 10       ; Result is 0, ZF = 1
    
    ; === SIGN FLAG (SF) ===
    LEA DX, MSG_SF
    MOV AH, 09H
    INT 21H
    
    ; Set SF (negative result)
    MOV AX, 5
    SUB AX, 10       ; Result is -5, SF = 1
    
    ; === OVERFLOW FLAG (OF) ===
    LEA DX, MSG_OF
    MOV AH, 09H
    INT 21H
    
    ; Set OF (signed overflow)
    MOV AL, 127      ; Max positive 8-bit signed
    ADD AL, 1        ; OF = 1 (overflow to -128)
    
    MOV AH, 4CH
    INT 21H
MAIN ENDP
END MAIN

; FLAGS REFERENCE:
; CF - Carry Flag: Set on unsigned overflow
; ZF - Zero Flag: Set when result is zero
; SF - Sign Flag: Set when result is negative (MSB = 1)
; OF - Overflow Flag: Set on signed overflow
; PF - Parity Flag: Set when number of 1-bits is even
; AF - Auxiliary Flag: BCD carry from bit 3 to 4
; DF - Direction Flag: String operation direction
; IF - Interrupt Flag: Enable/disable interrupts
; TF - Trap Flag: Single-step debugging
