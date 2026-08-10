; =============================================================================
; TITLE: BCD to Hexadecimal Conversion
; DESCRIPTION: Convert a 16-bit BCD (Binary Coded Decimal) number to its
;              equivalent hexadecimal value.
; AUTHOR: Amey Thakur (https://github.com/Amey-Thakur)
; REPOSITORY: https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
; LICENSE: MIT License
; =============================================================================

;-----------------------------------------------------------------------------
; DATA SEGMENT
; BCD digits stored in array: 65535 = {6, 5, 5, 3, 5}
;-----------------------------------------------------------------------------
DATA SEGMENT

    ; Labels for the register report at the end of the program.
    RPT_HEAD DB 0DH, 0AH, 'Registers when the program finished:', 0DH, 0AH, '$'
    RPT_N_AX DB '  AX = ', '$'
    RPT_N_BX DB '   BX = ', '$'
    RPT_N_CX DB '   CX = ', '$'
    RPT_N_DX DB '   DX = ', '$'
    RPT_NL   DB 0DH, 0AH, '$'
    BCD DB 06H, 05H, 05H, 03H, 05H     ; BCD digits (65535)
    HEX DW ?                            ; Hexadecimal result
DATA ENDS

ASSUME CS:CODE, DS:DATA

;-----------------------------------------------------------------------------
; CODE SEGMENT
; Algorithm: Multiply each digit by its place value and accumulate
; 65535 = 6*10000 + 5*1000 + 5*100 + 3*10 + 5*1
;-----------------------------------------------------------------------------
CODE SEGMENT
START: 
       ; Initialize Data Segment
       MOV AX, DATA
       MOV DS, AX
       
       ;---------------------------------------------------------------------
       ; Initialize Registers
       ;---------------------------------------------------------------------
       MOV CL, 05H                      ; 5 BCD digits to process
       MOV BP, 000AH                    ; Divisor for place value (10)
       MOV AX, 2710H                    ; Initial place value (10000)
       PUSH AX                          ; Save place value
       MOV DI, 0000H                    ; Accumulator for result
       MOV SI, OFFSET BCD               ; Point to BCD array
       
       ;---------------------------------------------------------------------
       ; Conversion Loop
       ; Multiply each BCD digit by place value and add to result
       ;---------------------------------------------------------------------
X:     
       MOV BL, [SI]                     ; Get BCD digit
       MUL BX                           ; AX = digit * place value
       ADD DI, AX                       ; Add to result
       POP AX                           ; Restore place value
       DIV BP                           ; AX = place value / 10
       PUSH AX                          ; Save new place value
       INC SI                           ; Next BCD digit
       LOOP X                           ; Repeat for all digits
       
       ;---------------------------------------------------------------------
       ; Store Result
       ; 65535 decimal = FFFFH
       ;---------------------------------------------------------------------
       MOV HEX, DI                      ; Store hex result
       
       ;---------------------------------------------------------------------
       ; Program Termination
       ;---------------------------------------------------------------------
; -------------------------------------------------------------------------
    ; WHAT THIS PROGRAM COMPUTED
    ;
    ; The work above leaves its answer in the registers. Printing them is what
    ; makes the program demonstrate itself rather than needing a debugger to be
    ; believed.
    ; -------------------------------------------------------------------------
    CALL RPT_REGISTERS

           MOV AH, 4CH
       INT 21H
CODE ENDS

; -----------------------------------------------------------------------------
; RPT_DECIMAL
;
; Prints the unsigned value in AX as decimal. Named apart from anything the
; program already had, so this report cannot clash with it.
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
; Prints the dollar terminated string at DS:DX, leaving AX alone.
; -----------------------------------------------------------------------------
RPT_SAY PROC
    PUSH AX
    MOV AH, 09H
    INT 21H
    POP AX
    RET
RPT_SAY ENDP

; -----------------------------------------------------------------------------
; RPT_REGISTERS
;
; Prints the four general registers as they were on entry.
;
; They are pushed first and read back off, because printing needs AX for the
; value and DX for the message: reading them any later would report the state of
; the printer rather than the state of the program.
; -----------------------------------------------------------------------------
RPT_REGISTERS PROC
    PUSH DX
    PUSH CX
    PUSH BX
    PUSH AX

    PUSH BP
    MOV BP, SP

    LEA DX, RPT_HEAD
    CALL RPT_SAY

    LEA DX, RPT_N_AX
    CALL RPT_SAY
    MOV AX, [BP+2]
    CALL RPT_DECIMAL

    LEA DX, RPT_N_BX
    CALL RPT_SAY
    MOV AX, [BP+4]
    CALL RPT_DECIMAL

    LEA DX, RPT_N_CX
    CALL RPT_SAY
    MOV AX, [BP+6]
    CALL RPT_DECIMAL

    LEA DX, RPT_N_DX
    CALL RPT_SAY
    MOV AX, [BP+8]
    CALL RPT_DECIMAL

    LEA DX, RPT_NL
    CALL RPT_SAY

    POP BP

    POP AX
    POP BX
    POP CX
    POP DX
    RET
RPT_REGISTERS ENDP

END START

;=============================================================================
; BCD TO HEX CONVERSION NOTES:
; - BCD stores each decimal digit in a separate nibble or byte
; - Conversion: Sum of (digit * 10^position)
; - Example: 65535 (BCD) = 6*10000 + 5*1000 + 5*100 + 3*10 + 5 = FFFFH
;=============================================================================
