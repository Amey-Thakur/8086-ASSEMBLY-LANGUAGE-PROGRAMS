; =============================================================================
; TITLE: Register Indirect Addressing Mode
; DESCRIPTION: A register holds the address instead of the value, which is what makes walking an array possible.
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
    DATA_W  DW 11, 22, 33, 44
    HOWMANY EQU 4

    M_TITLE DB 'Register indirect: the register holds the address', 0DH, 0AH, '$'
    M_BX    DB 'Through BX: $'
    M_SI    DB 'Through SI: $'
    M_DI    DB 'Through DI: $'
    M_WALK  DB 'Walking the array with SI: $'
    M_BP    DB 'Through BP, which reads the stack: $'
    M_ONLY  DB 'Only BX, BP, SI and DI may hold an address. AX, CX and DX '
            DB 'cannot.', 0DH, 0AH, '$'
    M_SPACE DB ' $'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA DX, M_TITLE

    CALL PRINT_MESSAGE

    ; -------------------------------------------------------------------------
    ; LEA LOADS THE ADDRESS OF A NAME. THE BRACKETS THEN MEAN "THE WORD THAT
    ; ADDRESS POINTS AT", SO ALL THREE OF THESE READ THE SAME FIRST ELEMENT.
    ; -------------------------------------------------------------------------
    LEA BX, DATA_W
    MOV AX, [BX]
    LEA DX, M_BX
    CALL PRINT_MESSAGE
    CALL PRINT_DECIMAL
    CALL NEWLINE

    LEA SI, DATA_W
    MOV AX, [SI]
    LEA DX, M_SI
    CALL PRINT_MESSAGE
    CALL PRINT_DECIMAL
    CALL NEWLINE

    LEA DI, DATA_W
    MOV AX, [DI]
    LEA DX, M_DI
    CALL PRINT_MESSAGE
    CALL PRINT_DECIMAL
    CALL NEWLINE

    ; -------------------------------------------------------------------------
    ; ADVANCING THE REGISTER BY THE SIZE OF ONE ELEMENT VISITS THE NEXT ONE.
    ; TWO BYTES FOR A WORD, ONE FOR A BYTE. THIS IS THE WHOLE MECHANISM BEHIND
    ; EVERY ARRAY LOOP ON THIS PROCESSOR.
    ; -------------------------------------------------------------------------
    LEA DX, M_WALK
    CALL PRINT_MESSAGE

    LEA SI, DATA_W
    MOV CX, HOWMANY
NEXT_ELEMENT:
    MOV AX, [SI]
    CALL PRINT_DECIMAL
    LEA DX, M_SPACE
    CALL PRINT_MESSAGE
    ADD SI, 2
    LOOP NEXT_ELEMENT
    CALL NEWLINE

    ; -------------------------------------------------------------------------
    ; BP IS THE ODD ONE OUT. IT DEFAULTS TO THE STACK SEGMENT RATHER THAN THE
    ; DATA SEGMENT, WHICH IS EXACTLY WHAT A PROCEDURE WANTS WHEN IT REACHES
    ; FOR AN ARGUMENT ITS CALLER PUSHED.
    ; -------------------------------------------------------------------------
    MOV AX, 777
    PUSH AX
    MOV BP, SP
    MOV AX, [BP]                        ; Reads SS:[BP], the word just pushed.
    LEA DX, M_BP
    CALL PRINT_MESSAGE
    CALL PRINT_DECIMAL
    CALL NEWLINE
    POP AX
    CALL NEWLINE

    LEA DX, M_ONLY

    CALL PRINT_MESSAGE

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
; 1. The four legal registers:
;    - BX and BP are base registers; SI and DI are index registers.
;    - No other register may appear inside brackets on an 8086.
;    - MOV AX, [CX] is rejected, which surprises anyone arriving from a later processor.
; 2. Segment defaults differ:
;    - [BX], [SI] and [DI] read the data segment.
;    - [BP] reads the stack segment, because BP exists to address stack frames.
;    - DS:[BP] overrides that when a program really means the data segment.
; 3. Advance by element size:
;    - ADD SI, 2 steps to the next word; INC SI would land mid element.
;    - A byte array steps with INC SI instead.
;    - Getting the stride wrong reads halves of two neighbouring values.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
