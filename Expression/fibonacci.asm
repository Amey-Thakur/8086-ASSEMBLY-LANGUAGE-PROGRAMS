;=============================================================================
; Program:     Fibonacci Series Generator
; Description: Print the Fibonacci series up to N terms.
;              Demonstrates iterative series generation.
; 
; Author:      Amey Thakur
; Repository:  https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
; License:     MIT License
;=============================================================================

.MODEL SMALL
.STACK 64

;-----------------------------------------------------------------------------
; DATA SEGMENT
;-----------------------------------------------------------------------------
.DATA
    VAL1 DB 01H                         ; First Fibonacci number
    VAL2 DB 01H                         ; Second Fibonacci number
    LP DB 00H                           ; Loop counter storage
    V1 DB 00H                           ; Tens digit
    V2 DB 00H                           ; Units digit
    NL DB 0DH, 0AH, '$'                 ; Newline string

;-----------------------------------------------------------------------------
; CODE SEGMENT
; Fibonacci: F(n) = F(n-1) + F(n-2)
; Series: 1, 1, 2, 3, 5, 8, 13, 21, 34, 55, ...
;-----------------------------------------------------------------------------
.CODE
MAIN PROC
    ; Initialize Data Segment
    MOV AX, @DATA
    MOV DS, AX

    ;-------------------------------------------------------------------------
    ; Get number of terms from user
    ;-------------------------------------------------------------------------
    MOV AH, 01H
    INT 21H
    MOV CL, AL
    SUB CL, 30H                         ; Convert ASCII to number
    SUB CL, 2                           ; Already displaying first 2

    ;-------------------------------------------------------------------------
    ; Display first Fibonacci number (1)
    ;-------------------------------------------------------------------------
    MOV AH, 02H
    MOV DL, VAL1
    ADD DL, 30H
    INT 21H

    MOV AH, 09H
    LEA DX, NL
    INT 21H

    ;-------------------------------------------------------------------------
    ; Display second Fibonacci number (1)
    ;-------------------------------------------------------------------------
    MOV AH, 02H
    MOV DL, VAL2
    ADD DL, 30H
    INT 21H

    MOV AH, 09H
    LEA DX, NL
    INT 21H

    ;-------------------------------------------------------------------------
    ; Generate and display remaining terms
    ;-------------------------------------------------------------------------
DISP:
    ; Calculate next: F(n) = F(n-1) + F(n-2)
    MOV BL, VAL1
    ADD BL, VAL2

    ; Split into digits for display
    MOV AH, 00H
    MOV AL, BL
    MOV LP, CL                          ; Save loop counter
    MOV CL, 10
    DIV CL                              ; AL = tens, AH = units
    MOV CL, LP                          ; Restore counter

    MOV V1, AL                          ; Tens digit
    MOV V2, AH                          ; Units digit

    ; Display tens digit
    MOV DL, V1
    ADD DL, 30H
    MOV AH, 02H
    INT 21H

    ; Display units digit
    MOV DL, V2
    ADD DL, 30H
    MOV AH, 02H
    INT 21H

    ; Update values: shift for next iteration
    MOV DL, VAL2
    MOV VAL1, DL
    MOV VAL2, BL

    ; Newline
    MOV AH, 09H
    LEA DX, NL
    INT 21H

    LOOP DISP

    ;-------------------------------------------------------------------------
    ; Program Termination
    ;-------------------------------------------------------------------------
    MOV AH, 4CH
    INT 21H
MAIN ENDP
END MAIN

;=============================================================================
; FIBONACCI SERIES NOTES:
; - Each number is sum of two preceding numbers
; - F(1)=1, F(2)=1, F(n)=F(n-1)+F(n-2)
; - Appears in nature: sunflower seeds, pine cones, shell spirals
; - Ratio approaches Golden Ratio (φ ≈ 1.618)
;=============================================================================
