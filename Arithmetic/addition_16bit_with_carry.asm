;=============================================================================
; Program:     16-bit Addition with Carry Detection
; Description: Adds two 16-bit numbers and detects if carry occurs.
;              Demonstrates JNC (Jump if No Carry) instruction.
; 
; Author:      Amey Thakur
; Repository:  https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
; License:     MIT License
;=============================================================================

;-----------------------------------------------------------------------------
; DATA SEGMENT
;-----------------------------------------------------------------------------
DATA SEGMENT
    var1 DW 1234H                       ; First operand (4660 decimal)
    var2 DW 5140H                       ; Second operand (20800 decimal)
    result DW ?                         ; Sum result
    carry DB 00H                        ; Carry flag indicator
DATA ENDS

;-----------------------------------------------------------------------------
; CODE SEGMENT
;-----------------------------------------------------------------------------
CODE SEGMENT
    ASSUME CS:CODE, DS:DATA
    
    ; Initialize Data Segment
    MOV AX, DATA
    MOV DS, AX
   
START: 
       ;---------------------------------------------------------------------
       ; Perform 16-bit Addition
       ;---------------------------------------------------------------------
       MOV AX, var1                     ; Load first operand
       ADD AX, var2                     ; AX = var1 + var2
                                        ; 1234H + 5140H = 6374H (no carry)
       
       ;---------------------------------------------------------------------
       ; Check for Carry (Overflow beyond 16 bits)
       ;---------------------------------------------------------------------
       JNC SKIP                         ; Jump if No Carry (CF = 0)
       MOV carry, 01H                   ; If carry occurred, set flag

SKIP:  
       MOV result, AX                   ; Store the sum

       ;---------------------------------------------------------------------
       ; Program Termination (using INT 03H for debug breakpoint)
       ;---------------------------------------------------------------------
       INT 03H                          ; Breakpoint for debugger

END START
CODE ENDS
END

;=============================================================================
; NOTES:
; - JNC: Jump if No Carry (CF = 0)
; - JC:  Jump if Carry (CF = 1)
; - Carry occurs when sum exceeds FFFFH (65535) for 16-bit numbers
; - Example: FFFFH + 0001H = 0000H with CF = 1
;=============================================================================
