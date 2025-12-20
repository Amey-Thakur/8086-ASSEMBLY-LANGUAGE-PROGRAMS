;=============================================================================
; Program:     Reverse a Number
; Description: Reverse the digits of a decimal number.
;              Example: 12345 -> 54321
; 
; Author:      Amey Thakur
; Repository:  https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
; License:     MIT License
;=============================================================================

;-----------------------------------------------------------------------------
; MACRO: Display String
;-----------------------------------------------------------------------------
DISPLAY MACRO MSG
    MOV AH, 9
    LEA DX, MSG
    INT 21H
ENDM

;-----------------------------------------------------------------------------
; DATA SEGMENT
;-----------------------------------------------------------------------------
DATA SEGMENT
    NUM1 DW 12345                        ; Original number
    NUM2 DW ?                            ; Reversed number
    ARRY DB 10 DUP (0)                   ; Digit array
    TEMP DW ?                            ; Temporary storage
    MSG1 DB 10, 13, 'Stored number in memory is : $'
    MSG2 DB 10, 13, 'Reverse number is : $'
    RES DB 10 DUP ('$')                  ; Result string
DATA ENDS

;-----------------------------------------------------------------------------
; CODE SEGMENT
;-----------------------------------------------------------------------------
CODE SEGMENT
    ASSUME CS:CODE, DS:DATA
    
START:
    ; Initialize Data Segment
    MOV AX, DATA
    MOV DS, AX
    
    ;-------------------------------------------------------------------------
    ; Display Original Number
    ;-------------------------------------------------------------------------
    DISPLAY MSG1
    MOV AX, NUM1                         ; Load original number
    LEA SI, RES
    CALL HEX2DEC                         ; Convert to string
    LEA DX, RES
    MOV AH, 9
    INT 21H
    
    ;-------------------------------------------------------------------------
    ; Extract Digits (reverse order into array)
    ;-------------------------------------------------------------------------
    LEA SI, ARRY
    MOV AX, NUM1
    
REVE:
    MOV DX, 0
    MOV BX, 10
    DIV BX                               ; AX = quotient, DX = remainder
    MOV ARRY[SI], DL                     ; Store digit
    MOV TEMP, AX
    MOV AX, DX
    INC SI
    MOV AX, TEMP
    CMP TEMP, 0
    JG REVE
    
    ;-------------------------------------------------------------------------
    ; Find Last Non-Zero Digit
    ;-------------------------------------------------------------------------
    LEA DI, ARRY
    
LAST:
    INC DI
    CMP ARRY[DI], 0
    JG LAST
    DEC DI
    
    ;-------------------------------------------------------------------------
    ; Build Reversed Number
    ;-------------------------------------------------------------------------
    MOV AL, ARRY[DI]
    MOV AH, 0
    MOV NUM2, AX
    MOV CX, 10
    
CONV:
    DEC DI
    MOV AL, ARRY[DI]
    MOV AH, 0
    MUL CX                               ; Multiply by place value
    ADD NUM2, AX
    MOV AX, CX
    MOV BX, 10
    MUL BX                               ; Next place value
    MOV CX, AX
    CMP ARRY[DI], 0
    JG CONV
    
    ;-------------------------------------------------------------------------
    ; Display Reversed Number
    ;-------------------------------------------------------------------------
    DISPLAY MSG2
    MOV AX, NUM2
    LEA SI, RES
    CALL HEX2DEC
    LEA DX, RES
    MOV AH, 9
    INT 21H
    
    ;-------------------------------------------------------------------------
    ; Program Termination
    ;-------------------------------------------------------------------------
    MOV AH, 4CH
    INT 21H
CODE ENDS

;-----------------------------------------------------------------------------
; HEX2DEC: Convert AX to decimal string at [SI]
;-----------------------------------------------------------------------------
HEX2DEC PROC NEAR
    MOV CX, 0
    MOV BX, 10
    
LOOP1: 
    MOV DX, 0
    DIV BX
    ADD DL, 30H
    PUSH DX
    INC CX
    CMP AX, 9
    JG LOOP1
    ADD AL, 30H
    MOV [SI], AL
    
LOOP2: 
    POP AX
    INC SI
    MOV [SI], AL
    LOOP LOOP2
    RET
HEX2DEC ENDP

END START

;=============================================================================
; REVERSE NUMBER ALGORITHM:
; 1. Extract digits using repeated division by 10
; 2. Store digits in array (already in reverse order)
; 3. Reconstruct number by multiplying each digit by place value
; Example: 12345 -> digits [5,4,3,2,1] -> 54321
;=============================================================================