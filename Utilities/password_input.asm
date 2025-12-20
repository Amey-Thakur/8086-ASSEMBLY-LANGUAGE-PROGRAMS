; Program: Password Input (Hidden)
; Description: Read password with asterisk masking
; Author: Amey Thakur
; Keywords: 8086 password, hidden input, masked input

.MODEL SMALL
.STACK 100H

.DATA
    PROMPT DB 'Enter password: $'
    CORRECT_PASS DB 'secret', 0
    PASS_LEN EQU 6
    INPUT_PASS DB 20 DUP(0)
    MSG_CORRECT DB 0DH, 0AH, 'Access Granted!$'
    MSG_WRONG DB 0DH, 0AH, 'Access Denied!$'

.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX
    
    ; Display prompt
    LEA DX, PROMPT
    MOV AH, 09H
    INT 21H
    
    ; Read password with hidden input
    LEA DI, INPUT_PASS
    XOR CX, CX       ; Character counter
    
READ_LOOP:
    ; Read character without echo
    MOV AH, 07H      ; DOS: Read without echo
    INT 21H
    
    CMP AL, 0DH      ; Enter pressed?
    JE CHECK_PASS
    
    CMP AL, 08H      ; Backspace?
    JE BACKSPACE
    
    ; Store character
    MOV [DI], AL
    INC DI
    INC CX
    
    ; Display asterisk
    MOV DL, '*'
    MOV AH, 02H
    INT 21H
    
    CMP CX, 19       ; Max length
    JL READ_LOOP
    JMP CHECK_PASS
    
BACKSPACE:
    CMP CX, 0
    JE READ_LOOP
    DEC DI
    DEC CX
    ; Erase asterisk
    MOV DL, 08H
    MOV AH, 02H
    INT 21H
    MOV DL, ' '
    INT 21H
    MOV DL, 08H
    INT 21H
    JMP READ_LOOP
    
CHECK_PASS:
    MOV BYTE PTR [DI], 0  ; Null terminate
    
    ; Compare passwords
    LEA SI, CORRECT_PASS
    LEA DI, INPUT_PASS
    
CMP_LOOP:
    MOV AL, [SI]
    MOV BL, [DI]
    CMP AL, BL
    JNE WRONG
    CMP AL, 0
    JE CORRECT
    INC SI
    INC DI
    JMP CMP_LOOP
    
CORRECT:
    LEA DX, MSG_CORRECT
    JMP DISPLAY
    
WRONG:
    LEA DX, MSG_WRONG
    
DISPLAY:
    MOV AH, 09H
    INT 21H
    
    MOV AH, 4CH
    INT 21H
MAIN ENDP
END MAIN
