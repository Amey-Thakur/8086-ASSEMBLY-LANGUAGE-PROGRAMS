;=============================================================================
; Program:     Addition of Two 8-bit Numbers (with User Input)
; Description: Reads two single-digit numbers from keyboard, adds them,
;              and displays the result. Demonstrates basic I/O and arithmetic.
; 
; Author:      Amey Thakur
; Repository:  https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
; License:     MIT License
;=============================================================================

;-----------------------------------------------------------------------------
; DATA SEGMENT
; Contains variables for storing numbers and display messages
;-----------------------------------------------------------------------------
DATA SEGMENT
    num1 DB ?                           ; First number (8-bit)
    num2 DB ?                           ; Second number (8-bit)
    res DB ?                            ; Result of addition
    msg1 DB 10,13,"Enter the first number: $"
    msg2 DB 10,13,"Enter the second number: $"
    msg3 DB 10,13,"Result of addition is: $"
DATA ENDS   

ASSUME CS:CODE, DS:DATA

;-----------------------------------------------------------------------------
; CODE SEGMENT
; Main program logic for 8-bit addition with user input
;-----------------------------------------------------------------------------
CODE SEGMENT
    START: 
           ; Initialize Data Segment
           MOV AX, DATA
           MOV DS, AX                   ; Set up data segment register
           
           ;-----------------------------------------------------------------
           ; Input First Number
           ;-----------------------------------------------------------------
           LEA DX, msg1                 ; Load address of prompt message
           MOV AH, 9H                   ; DOS: Display string function
           INT 21H                      ; Display "Enter the first number:"
           
           MOV AH, 1H                   ; DOS: Read character with echo
           INT 21H                      ; Wait for keypress, char in AL
           SUB AL, 30H                  ; Convert ASCII to numeric (0-9)
           MOV num1, AL                 ; Store first number
           
           ;-----------------------------------------------------------------
           ; Input Second Number
           ;-----------------------------------------------------------------
           LEA DX, msg2                 ; Load address of second prompt
           MOV AH, 9H                   ; DOS: Display string function
           INT 21H                      ; Display "Enter the second number:"
           
           MOV AH, 1H                   ; DOS: Read character with echo
           INT 21H                      ; Wait for keypress, char in AL
           SUB AL, 30H                  ; Convert ASCII to numeric (0-9)
           MOV num2, AL                 ; Store second number
           
           ;-----------------------------------------------------------------
           ; Perform Addition
           ;-----------------------------------------------------------------
           ADD AL, num1                 ; AL = num1 + num2
           MOV res, AL                  ; Store sum in result variable
           MOV AH, 0                    ; Clear AH (for AAA instruction)
           AAA                          ; ASCII Adjust for Addition
                                        ; Converts binary to unpacked BCD
           ADD AH, 30H                  ; Convert tens digit to ASCII
           ADD AL, 30H                  ; Convert ones digit to ASCII
           
           ;-----------------------------------------------------------------
           ; Display Result
           ;-----------------------------------------------------------------
           MOV BX, AX                   ; Save result in BX for display
           LEA DX, msg3                 ; Load result message address
           MOV AH, 9H                   ; DOS: Display string function
           INT 21H                      ; Display "Result of addition is:"
           
           ; Display tens digit (if any)
           MOV AH, 2H                   ; DOS: Display character function
           MOV DL, BH                   ; Tens digit from BH
           INT 21H                      ; Print tens digit
           
           ; Display ones digit
           MOV AH, 2H                   ; DOS: Display character function
           MOV DL, BL                   ; Ones digit from BL
           INT 21H                      ; Print ones digit
    
           ;-----------------------------------------------------------------
           ; Program Termination
           ;-----------------------------------------------------------------
           MOV AH, 4CH                  ; DOS: Terminate program function
           INT 21H                      ; Return to DOS
     
CODE ENDS
END START
