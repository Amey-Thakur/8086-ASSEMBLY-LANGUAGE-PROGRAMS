;=============================================================================
; Program:     Seven Segment Display Decoder
; Description: Convert a hexadecimal digit (0-F) to its seven segment
;              display pattern using a lookup table.
; 
; Author:      Amey Thakur
; Repository:  https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
; License:     MIT License
;=============================================================================

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
    MOV AH, 4CH
    INT 21H
CODE ENDS
END START

;=============================================================================
; SEVEN SEGMENT DISPLAY NOTES:
; - Each bit in the pattern controls one segment (a-g)
; - Common patterns form 0-9 and A-F hexadecimal digits
; - Lookup table provides O(1) conversion
; - Used in calculators, digital clocks, meters
;=============================================================================