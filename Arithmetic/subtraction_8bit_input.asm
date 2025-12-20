;=============================================================================
; Program:     Subtraction of Two 8-bit Numbers (with User Input)
; Description: Reads two single-digit numbers from keyboard, subtracts them,
;              and displays the result. Demonstrates SUB instruction.
; 
; Author:      Amey Thakur
; Repository:  https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
; License:     MIT License
;=============================================================================

;-----------------------------------------------------------------------------
; DATA SEGMENT
;-----------------------------------------------------------------------------
DATA SEGMENT
    num1 DB ?                           ; Minuend (number to subtract from)
    num2 DB ?                           ; Subtrahend (number to subtract)
    res DB ?                            ; Difference result
    msg1 DB 10,13,"Enter the first number: $"
    msg2 DB 10,13,"Enter the second number: $"
    msg3 DB 10,13,"Result of subtraction is: $"
DATA ENDS   

ASSUME CS:CODE, DS:DATA

;-----------------------------------------------------------------------------
; CODE SEGMENT
;-----------------------------------------------------------------------------
CODE SEGMENT
    START: 
           ; Initialize Data Segment
           MOV AX, DATA
           MOV DS, AX                   ; Set up data segment register
           
           ;-----------------------------------------------------------------
           ; Input First Number (Minuend)
           ;-----------------------------------------------------------------
           LEA DX, msg1                 ; Load prompt address
           MOV AH, 9H                   ; DOS: Display string
           INT 21H          
           
           MOV AH, 1H                   ; DOS: Read character
           INT 21H
           SUB AL, 30H                  ; ASCII to numeric conversion
           MOV num1, AL                 ; Store minuend
           
           ;-----------------------------------------------------------------
           ; Input Second Number (Subtrahend)
           ;-----------------------------------------------------------------
           LEA DX, msg2                 ; Load second prompt
           MOV AH, 9H                   ; DOS: Display string
           INT 21H          
           
           MOV AH, 1H                   ; DOS: Read character
           INT 21H
           SUB AL, 30H                  ; ASCII to numeric conversion
           MOV num2, AL                 ; Store subtrahend
           
           ;-----------------------------------------------------------------
           ; Perform Subtraction: num1 - num2
           ;-----------------------------------------------------------------
           MOV AL, num1                 ; Load minuend
           SUB AL, num2                 ; AL = num1 - num2
           MOV res, AL                  ; Store difference
           MOV AH, 0                    ; Clear AH for AAS
           AAS                          ; ASCII Adjust for Subtraction
           ADD AH, 30H                  ; Convert tens to ASCII
           ADD AL, 30H                  ; Convert ones to ASCII
           
           ;-----------------------------------------------------------------
           ; Display Result
           ;-----------------------------------------------------------------
           MOV BX, AX                   ; Save for display
           LEA DX, msg3                 ; Load result message
           MOV AH, 9H
           INT 21H
           
           MOV AH, 2H                   ; Display tens digit
           MOV DL, BH                                
           INT 21H
           
           MOV AH, 2H                   ; Display ones digit
           MOV DL, BL
           INT 21H
     
           ;-----------------------------------------------------------------
           ; Program Termination
           ;-----------------------------------------------------------------
           MOV AH, 4CH
           INT 21H
     
CODE ENDS
END START
