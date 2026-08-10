; =============================================================================
; TITLE: Set, Clear and Toggle a Chosen Bit
; DESCRIPTION: Builds a mask for a bit named at run time and shows the three
;              operations that act on that bit alone, together with the test
;              that reads it without disturbing anything.
; AUTHOR: Amey Thakur (https://github.com/Amey-Thakur)
; REPOSITORY: https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
; LICENSE: MIT License
; =============================================================================

.MODEL SMALL
.STACK 100H

; -----------------------------------------------------------------------------
; DATA SEGMENT
; -----------------------------------------------------------------------------
.DATA
    CONTROL DW 1234H                    ; The word every operation is applied to

    BITLIST DB 0, 2, 6, 15              ; Bit numbers to demonstrate
    HOWMANY EQU $ - BITLIST             ; Measured, never counted by hand

    M_TITLE DB 'Every operation below is applied to $'
    M_AFTER DB ', which is itself never altered', 0DH, 0AH, '$'
    M_BIT   DB 'Bit $'
    M_MASK  DB '   mask $'
    M_IS_ON DB '   state set$'
    M_IS_NO DB '   state clear$'
    M_SET   DB '   set $'
    M_CLR   DB '   cleared $'
    M_TOG   DB '   toggled $'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    ; Context setup
    MOV AX, @DATA
    MOV DS, AX

    LEA DX, M_TITLE
    CALL PRINT_MESSAGE
    MOV AX, CONTROL
    CALL PRINT_HEX
    LEA DX, M_AFTER
    CALL PRINT_MESSAGE

    XOR SI, SI
    MOV CX, HOWMANY

EACH_BIT:
    LEA DX, M_BIT
    CALL PRINT_MESSAGE
    MOV AL, BITLIST[SI]
    XOR AH, AH                          ; The list is bytes, the printer wants a word
    CALL PRINT_DECIMAL

    ; -------------------------------------------------------------------------
    ; THE MASK
    ;
    ; A shift of more than one place has to take its count from CL, and CL is
    ; the low half of the loop counter, so the counter is stacked around it.
    ; -------------------------------------------------------------------------
    PUSH CX
    MOV CL, BITLIST[SI]
    MOV BX, 1
    SHL BX, CL                          ; One bit, standing where it was asked for
    POP CX

    LEA DX, M_MASK
    CALL PRINT_MESSAGE
    MOV AX, BX
    CALL PRINT_HEX

    ; -------------------------------------------------------------------------
    ; READING THE BIT
    ;
    ; TEST is an AND that throws its result away and keeps only the flags, so
    ; the word is read without being altered.
    ; -------------------------------------------------------------------------
    MOV AX, CONTROL
    TEST AX, BX
    JZ  BIT_IS_CLEAR
    LEA DX, M_IS_ON
    JMP SAY_STATE

BIT_IS_CLEAR:
    LEA DX, M_IS_NO

SAY_STATE:
    CALL PRINT_MESSAGE

    ; Setting: OR turns the chosen bit on and cannot turn any other one off
    LEA DX, M_SET
    CALL PRINT_MESSAGE
    MOV AX, CONTROL
    OR  AX, BX
    CALL PRINT_HEX

    ; Clearing: the complement of the mask is ones everywhere else, so AND
    ; keeps every other bit and drops only this one
    LEA DX, M_CLR
    CALL PRINT_MESSAGE
    MOV AX, BX
    NOT AX
    AND AX, CONTROL
    CALL PRINT_HEX

    ; Toggling: XOR flips the chosen bit whichever way it was, with no test
    LEA DX, M_TOG
    CALL PRINT_MESSAGE
    MOV AX, CONTROL
    XOR AX, BX
    CALL PRINT_HEX
    CALL NEWLINE

    INC SI
    LOOP EACH_BIT

    ; End process
    MOV AH, 4CH
    INT 21H

; -----------------------------------------------------------------------------
; PRINT_DECIMAL
;
; Prints the unsigned value in AX as decimal, with no leading zeros.
; Every register it touches is restored, so a caller can rely on it.
; -----------------------------------------------------------------------------
PRINT_DECIMAL PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX

    XOR CX, CX                          ; How many digits have been stacked
    MOV BX, 10

PD_DIVIDE:
    XOR DX, DX                          ; DX:AX is the dividend, so clear DX
    DIV BX                              ; AX = quotient, DX = this digit
    PUSH DX                             ; Digits arrive lowest first
    INC CX
    OR  AX, AX
    JNZ PD_DIVIDE                       ; Keep going until the quotient is zero

PD_EMIT:
    POP DX                              ; Unstacking reverses them into order
    ADD DL, '0'
    MOV AH, 02H
    INT 21H
    LOOP PD_EMIT

    POP DX
    POP CX
    POP BX
    POP AX
    RET
PRINT_DECIMAL ENDP

; -----------------------------------------------------------------------------
; PRINT_HEX
;
; Prints the value in AX as four hexadecimal digits followed by H.
; -----------------------------------------------------------------------------
PRINT_HEX PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX

    MOV BX, AX                          ; Keep the value; AX is needed for DOS
    MOV CX, 4                           ; Four nibbles, most significant first

PH_NEXT:
    ROL BX, 4                           ; Bring the next nibble to the bottom
    MOV DL, BL
    AND DL, 0FH

    ADD DL, '0'                         ; 0 to 9 sit just after '0'
    CMP DL, '9'
    JBE PH_EMIT
    ADD DL, 7                           ; A to F sit seven further on

PH_EMIT:
    MOV AH, 02H
    INT 21H
    LOOP PH_NEXT

    MOV DL, 'H'
    MOV AH, 02H
    INT 21H

    POP DX
    POP CX
    POP BX
    POP AX
    RET
PRINT_HEX ENDP

; -----------------------------------------------------------------------------
; NEWLINE
;
; Moves to the start of the next line. DOS needs both characters: the return
; moves the cursor to column zero and the feed moves it down a line.
; -----------------------------------------------------------------------------
NEWLINE PROC
    PUSH AX
    PUSH DX

    MOV DL, 0DH
    MOV AH, 02H
    INT 21H
    MOV DL, 0AH
    MOV AH, 02H
    INT 21H

    POP DX
    POP AX
    RET
NEWLINE ENDP

; -----------------------------------------------------------------------------
; PRINT_MESSAGE
;
; Prints the dollar terminated string at DS:DX, leaving AX exactly as it was.
;
; Service 09H needs the service number in AH, and AH is the top half of AX. A
; caller that has just computed a result into AX and then sets AH for itself
; destroys that result: 500 becomes 09F4H, which prints as 2548. Doing the call
; in here, around a push and a pop, removes the trap for good.
; -----------------------------------------------------------------------------
PRINT_MESSAGE PROC
    PUSH AX

    MOV AH, 09H
    INT 21H

    POP AX
    RET
PRINT_MESSAGE ENDP

END START

; =============================================================================
; TECHNICAL NOTES
; =============================================================================
; 1. WHY EACH OPERATION USES THE OPERATOR IT DOES:
;    - OR with a mask can only add bits, so setting is safe beside other flags.
;    - AND with the complement can only remove bits, so clearing is equally safe.
;    - XOR flips exactly the masked bits, which is a toggle without a branch.
; 2. WHY TEST AND NOT AND:
;    - AND would leave the masked result in the destination and lose the word.
;    - TEST performs the same AND, sets the same flags and writes nothing back.
;    - The zero flag then answers the question directly, with no copy to keep.
; 3. WHERE THE SHIFT COUNT HAS TO LIVE:
;    - The 8086 takes a variable shift count only from CL, so a bit number read
;    - from memory has to pass through it.
;    - CL is the low half of CX, so a loop counted by CX must stack it first.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
