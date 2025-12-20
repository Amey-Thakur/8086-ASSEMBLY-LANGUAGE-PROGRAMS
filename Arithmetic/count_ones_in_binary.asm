;=============================================================================
; Program:     Count Number of 1s in Binary Number
; Description: Counts the number of set bits (1s) in an 8-bit number.
;              Demonstrates ROL instruction and bit manipulation.
; 
; Author:      Amey Thakur
; Repository:  https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
; License:     MIT License
;=============================================================================

;-----------------------------------------------------------------------------
; DATA SEGMENT
;-----------------------------------------------------------------------------
DATA SEGMENT
    data1 DB ?                          ; Input number storage
    msg1 DB 10,13,"Enter the number: $"
    msg3 DB 10,13,"Number of 1s are: $"
DATA ENDS   
 
ASSUME CS:CODE, DS:DATA

;-----------------------------------------------------------------------------
; CODE SEGMENT
;-----------------------------------------------------------------------------
CODE SEGMENT
START: 
       ; Initialize Data Segment
       MOV AX, DATA
       MOV DS, AX
       SUB BL, BL                       ; Clear BL (1s counter)
       
       ;---------------------------------------------------------------------
       ; Input Number
       ;---------------------------------------------------------------------
       LEA DX, msg1                     ; Display prompt
       MOV AH, 9H
       INT 21H
       
       MOV AH, 1H                       ; Read single digit
       INT 21H
       SUB AL, 30H                      ; Convert ASCII to number
       
       ;---------------------------------------------------------------------
       ; Bit Counting Loop
       ; ROL rotates left, MSB goes into Carry Flag
       ;---------------------------------------------------------------------
       MOV DL, 8H                       ; 8 bits to check
AGAIN: 
       ROL AL, 1                        ; Rotate left, MSB -> CF
       JNC NEXT                         ; If CF = 0, bit was 0
       INC BL                           ; If CF = 1, increment counter
NEXT:  
       DEC DL                           ; Decrement bit counter
       JNZ AGAIN                        ; Continue if not done
       
       ;---------------------------------------------------------------------
       ; Display Result
       ;---------------------------------------------------------------------
       LEA DX, msg3                     ; Display result message
       MOV AH, 9H
       INT 21H
           
       MOV AH, 2H                       ; Display count
       ADD BL, 30H                      ; Convert to ASCII
       MOV DL, BL                                
       INT 21H
       
       ;---------------------------------------------------------------------
       ; Program Termination
       ;---------------------------------------------------------------------
EXIT:  
       MOV AH, 04CH
       MOV AL, 0
       INT 21H 
       
CODE ENDS
END START

;=============================================================================
; NOTES:
; - ROL (Rotate Left): Shifts bits left, MSB goes to CF and LSB
; - JNC (Jump if No Carry): Skips increment when bit was 0
; - Algorithm: Rotate 8 times, count each 1 that goes into CF
; - Example: 7 (0111 binary) has 3 ones
;=============================================================================
