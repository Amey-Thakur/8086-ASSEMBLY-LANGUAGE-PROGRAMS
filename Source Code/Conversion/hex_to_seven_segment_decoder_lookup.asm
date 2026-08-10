; =============================================================================
; TITLE: Seven Segment Display Decoder
; DESCRIPTION: Convert a hexadecimal digit (0-F) to its seven segment display
;              pattern using a lookup table.
; AUTHOR: Amey Thakur (https://github.com/Amey-Thakur)
; REPOSITORY: https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
; LICENSE: MIT License
; =============================================================================

;-----------------------------------------------------------------------------
; DATA SEGMENT
; Seven segment pattern: bits represent segments a-g
;   --a--
;  |     |
;  f     b
;  |     |
;   --g--
;  |     |
;  e     c
;  |     |
;   --d--
;-----------------------------------------------------------------------------
DATA SEGMENT

    ; Labels for the register report at the end of the program.
    RPT_HEAD DB 0DH, 0AH, 'Registers when the program finished:', 0DH, 0AH, '$'
    RPT_N_AX DB '  AX = ', '$'
    RPT_N_BX DB '   BX = ', '$'
    RPT_N_CX DB '   CX = ', '$'
    RPT_N_DX DB '   DX = ', '$'
    RPT_NL   DB 0DH, 0AH, '$'
    ;-------------------------------------------------------------------------
    ; Lookup Table: Patterns for digits 0-F
    ; Bit order: 0gfedcba (1 = segment ON)
    ;-------------------------------------------------------------------------
    SEGMENT_TABLE DB 3FH                 ; 0: abcdef  = 00111111
                  DB 06H                 ; 1: bc      = 00000110
                  DB 5BH                 ; 2: abdeg   = 01011011
                  DB 4FH                 ; 3: abcdg   = 01001111
                  DB 66H                 ; 4: bcfg    = 01100110
                  DB 6DH                 ; 5: acdfg   = 01101101
                  DB 7DH                 ; 6: acdefg  = 01111101
                  DB 07H                 ; 7: abc     = 00000111
                  DB 7FH                 ; 8: abcdefg = 01111111
                  DB 6FH                 ; 9: abcdfg  = 01101111
                  DB 77H                 ; A: abcefg  = 01110111
                  DB 7CH                 ; B: cdefg   = 01111100
                  DB 39H                 ; C: adef    = 00111001
                  DB 5EH                 ; D: bcdeg   = 01011110
                  DB 79H                 ; E: adefg   = 01111001
                  DB 71H                 ; F: aefg    = 01110001
    
    INPUT_DIGIT DB 05H                   ; Input: digit 5
    OUTPUT_PATTERN DB ?                  ; Output: 7-seg pattern
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
    ; Convert Digit to 7-Segment Pattern
    ;-------------------------------------------------------------------------
    MOV AL, INPUT_DIGIT                  ; Get input digit (0-F)
    LEA SI, SEGMENT_TABLE                ; Point to lookup table
    XOR AH, AH                           ; Clear high byte
    ADD SI, AX                           ; Add offset (digit value)
    MOV AL, [SI]                         ; Get pattern from table
    MOV OUTPUT_PATTERN, AL               ; Store result
    
    ; For digit 5: OUTPUT_PATTERN = 6DH (01101101)
    ; Segments lit: a, c, d, f, g
    
    ;-------------------------------------------------------------------------
    ; Program Termination
    ;-------------------------------------------------------------------------
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
; SEVEN SEGMENT DISPLAY NOTES:
; - Each bit in the pattern controls one segment (a-g)
; - Common patterns form 0-9 and A-F hexadecimal digits
; - Lookup table provides O(1) conversion
; - Used in calculators, digital clocks, meters
;=============================================================================