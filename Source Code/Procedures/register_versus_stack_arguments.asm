; =============================================================================
; TITLE: Arguments in Registers Against Arguments on the Stack
; DESCRIPTION: One calculation is reached by two calling conventions, and the
;              stack each of them costs is measured rather than asserted.
; AUTHOR: Amey Thakur (https://github.com/Amey-Thakur)
; REPOSITORY: https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
; LICENSE: MIT License
; =============================================================================

.MODEL SMALL
.STACK 200H

; -----------------------------------------------------------------------------
; DATA SEGMENT
; -----------------------------------------------------------------------------
.DATA
    TRIPLES DW 7, 6, 5
            DW 12, 12, 100
            DW 250, 200, 1000
    SPAN    EQU $ - TRIPLES             ; Measured, never counted by hand

    VAL_A   DW ?                        ; The three arguments of the moment,
    VAL_B   DW ?                        ; held in memory because DX is reserved
    VAL_C   DW ?                        ; for message addresses throughout

    MARK_SP DW ?                        ; SP before the call is set up at all
    SEEN_SP DW ?                        ; SP as the called procedure found it

    M_TITLE DB 'One calculation, two calling conventions', 0DH, 0AH
            DB 'Each procedure works out A times B plus C', 0DH, 0AH, '$'
    M_A     DB 0DH, 0AH, 'A = $'
    M_B     DB '   B = $'
    M_C     DB '   C = $'
    M_REG   DB '   in registers: $'
    M_STK   DB '   on the stack: $'
    M_COST  DB '   costing $'
    M_BYTES DB ' bytes of stack', 0DH, 0AH, '$'
    M_CLOSE DB 0DH, 0AH
            DB 'Two bytes against eight for the same answer. Registers are the '
            DB 'cheaper carrier, but there are only a handful of them, so a '
            DB 'procedure of many arguments has to fall back on the stack.'
            DB 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA DX, M_TITLE
    CALL PRINT_MESSAGE

    XOR SI, SI                          ; Byte position within TRIPLES

; -----------------------------------------------------------------------------
; TAKE THE THREE ARGUMENTS OF THIS TRIPLE INTO MEMORY FIRST. READING THEM ONE
; AT A TIME ADVANCES SI TO THE NEXT TRIPLE WITHOUT ANY INDEX ARITHMETIC, AND
; PARKING THEM IN MEMORY KEEPS THEM SAFE WHILE THE REGISTERS ARE USED FOR
; PRINTING.
; -----------------------------------------------------------------------------
NEXT_CASE:
    MOV AX, TRIPLES[SI]
    MOV VAL_A, AX
    ADD SI, 2
    MOV AX, TRIPLES[SI]
    MOV VAL_B, AX
    ADD SI, 2
    MOV AX, TRIPLES[SI]
    MOV VAL_C, AX
    ADD SI, 2

    LEA DX, M_A
    CALL PRINT_MESSAGE
    MOV AX, VAL_A
    CALL PRINT_DECIMAL
    LEA DX, M_B
    CALL PRINT_MESSAGE
    MOV AX, VAL_B
    CALL PRINT_DECIMAL
    LEA DX, M_C
    CALL PRINT_MESSAGE
    MOV AX, VAL_C
    CALL PRINT_DECIMAL
    CALL NEWLINE

    ; -------------------------------------------------------------------------
    ; THE REGISTER CONVENTION. NOTHING IS PUSHED, SO THE ONLY THING THE CALL
    ; PUTS ON THE STACK IS THE RETURN ADDRESS.
    ; -------------------------------------------------------------------------
    MOV MARK_SP, SP
    MOV AX, VAL_A
    MOV BX, VAL_B
    MOV CX, VAL_C
    CALL SCALE_IN_REGISTERS

    LEA DX, M_REG
    CALL PRINT_MESSAGE
    CALL PRINT_DECIMAL
    CALL SHOW_COST

    ; -------------------------------------------------------------------------
    ; THE STACK CONVENTION. THE ARGUMENTS GO ON LAST TO FIRST, WHICH LEAVES THE
    ; FIRST OF THEM NEAREST THE FRAME POINTER AND SO AT THE SMALLEST OFFSET.
    ; -------------------------------------------------------------------------
    MOV MARK_SP, SP
    MOV AX, VAL_C
    PUSH AX
    MOV AX, VAL_B
    PUSH AX
    MOV AX, VAL_A
    PUSH AX
    CALL SCALE_ON_STACK                 ; Its RET 6 takes the arguments away

    LEA DX, M_STK
    CALL PRINT_MESSAGE
    CALL PRINT_DECIMAL
    CALL SHOW_COST

    CMP SI, SPAN
    JB  NEXT_CASE                       ; Unsigned, SI is a byte position

    LEA DX, M_CLOSE
    CALL PRINT_MESSAGE

    MOV AH, 4CH
    INT 21H

; -----------------------------------------------------------------------------
; SCALE_IN_REGISTERS
;
; Entry: AX = A, BX = B, CX = C. Exit: AX = A * B + C.
;
; The measurement is the first instruction, because anything this procedure
; pushed for itself would otherwise be charged to the calling convention rather
; than to the body of the work.
; -----------------------------------------------------------------------------
SCALE_IN_REGISTERS PROC
    MOV SEEN_SP, SP

    PUSH DX                             ; MUL writes the high half into DX

    MUL BX                              ; DX:AX = A * B, and the data keeps DX zero
    ADD AX, CX

    POP DX
    RET
SCALE_IN_REGISTERS ENDP

; -----------------------------------------------------------------------------
; SCALE_ON_STACK
;
; Entry: A, B and C pushed by the caller in that reverse order. Exit: AX holds
; A * B + C, and the three arguments have been discarded by the RET itself.
;
; Once BP is set the frame is fixed, so further pushes inside the procedure do
; not disturb the offsets at which the arguments are read.
; -----------------------------------------------------------------------------
SCALE_ON_STACK PROC
    MOV SEEN_SP, SP

    PUSH BP
    MOV BP, SP                          ; [BP+2] return address, [BP+4] first argument
    PUSH BX
    PUSH DX

    MOV AX, [BP+4]                      ; A
    MOV BX, [BP+6]                      ; B
    MUL BX
    ADD AX, [BP+8]                      ; C

    POP DX
    POP BX
    POP BP
    RET 6
SCALE_ON_STACK ENDP

; -----------------------------------------------------------------------------
; SHOW_COST
;
; Prints how many bytes of stack the call just made consumed, taken as the
; distance between SP before the arguments were prepared and SP as the
; procedure found it.
; -----------------------------------------------------------------------------
SHOW_COST PROC
    PUSH AX
    PUSH DX

    LEA DX, M_COST
    CALL PRINT_MESSAGE
    MOV AX, MARK_SP
    SUB AX, SEEN_SP                     ; The stack grows downwards, so this way round
    CALL PRINT_DECIMAL
    LEA DX, M_BYTES
    CALL PRINT_MESSAGE

    POP DX
    POP AX
    RET
SHOW_COST ENDP

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
; 1. WHY REGISTERS COME FIRST:
;    - A register argument is already where the arithmetic needs it.
;    - No memory is written, so the call costs only its return address.
;    - The limit is arithmetic: eight registers, several of them spoken for.
; 2. WHAT THE STACK BUYS:
;    - Any number of arguments, and each of them at a fixed offset from BP.
;    - Recursion becomes possible, since every call gets a fresh frame.
;    - The price is two memory writes per argument and the frame setup.
; 3. WHO CLEARS THE ARGUMENTS AWAY:
;    - RET 6 makes the procedure do it, which suits a fixed argument list.
;    - ADD SP, 6 after the call makes the caller do it instead.
;    - Only the caller knows how many it pushed when the count can vary.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
