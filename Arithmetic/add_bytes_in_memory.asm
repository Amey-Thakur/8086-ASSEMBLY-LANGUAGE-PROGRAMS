;=============================================================================
; Program:     Add Series of 10 Bytes from Memory
; Description: Adds 10 bytes stored in consecutive memory locations.
;              Demonstrates direct memory addressing with segment override.
; 
; Author:      Amey Thakur
; Repository:  https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
; License:     MIT License
;=============================================================================

;-----------------------------------------------------------------------------
; CODE SEGMENT
; Adds bytes from memory locations 20000H to 20009H
; Stores result immediately after the series at 2000AH
;-----------------------------------------------------------------------------
CODE SEGMENT
    ASSUME CS:CODE
    
    ; Set up Data Segment to point to 2000:0000
    MOV AX, 2000H
    MOV DS, AX
    
    ;-------------------------------------------------------------------------
    ; Initialize Registers
    ;-------------------------------------------------------------------------
    MOV SI, 0000H                       ; Starting offset address = 0000H
    MOV CX, 000AH                       ; 10 bytes to add (0AH = 10 decimal)
    MOV AX, 0000H                       ; Clear AX for storing sum
    
    ;-------------------------------------------------------------------------
    ; Addition Loop with Carry Handling
    ;-------------------------------------------------------------------------
BACK:   
    ADD AL, [SI]                        ; Add byte at [DS:SI] to AL
    JNC SKIP                            ; Jump if no carry (CF = 0)
    INC AH                              ; If carry, increment high byte
SKIP:   
    INC SI                              ; Point to next byte
    LOOP BACK                           ; Decrement CX, loop if not zero
    
    ;-------------------------------------------------------------------------
    ; Store Result
    ;-------------------------------------------------------------------------
    MOV [SI], AX                        ; Store 16-bit sum at 2000:000AH
    
    ;-------------------------------------------------------------------------
    ; Halt Processor
    ;-------------------------------------------------------------------------
    HLT 

CODE ENDS

;=============================================================================
; NOTES:
; - Physical address = Segment * 16 + Offset
; - 2000:0000 = 20000H physical address
; - JNC (Jump if No Carry) skips the increment when no overflow
; - LOOP decrements CX and jumps if CX != 0
;=============================================================================
