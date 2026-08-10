; =============================================================================
; TITLE: Register Addressing Mode
; DESCRIPTION: Both operands live in registers, so the instruction runs without any memory traffic at all.
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
    M_TITLE DB 'Register addressing: both operands are inside the processor', 0DH, 0AH, '$'
    M_SETUP DB 'AX = 1000 and BX = 250', 0DH, 0AH, '$'
    M_COPY  DB 'MOV CX, AX       CX = $'
    M_ADD   DB 'ADD CX, BX       CX = $'
    M_SWAPA DB 'XCHG AX, BX      AX = $'
    M_SWAPB DB ' and BX = $'
    M_HALF  DB 'AH and AL are the two halves of AX.', 0DH, 0AH, '$'
    M_AX    DB 'AX = $'
    M_AH    DB ' so AH = $'
    M_AL    DB ' and AL = $'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA DX, M_TITLE

    CALL PRINT_MESSAGE
    LEA DX, M_SETUP
    CALL PRINT_MESSAGE

    MOV AX, 1000
    MOV BX, 250

    ; -------------------------------------------------------------------------
    ; A REGISTER TO REGISTER MOVE IS TWO BYTES AND ONE CLOCK OF WORK. THERE IS
    ; NO ADDRESS TO FORM, WHICH IS WHY INNER LOOPS KEEP THEIR WORKING VALUES
    ; IN REGISTERS RATHER THAN IN MEMORY.
    ; -------------------------------------------------------------------------
    MOV CX, AX
    LEA DX, M_COPY
    CALL PRINT_MESSAGE
    PUSH AX
    MOV AX, CX
    CALL PRINT_DECIMAL
    POP AX
    CALL NEWLINE

    ADD CX, BX
    LEA DX, M_ADD
    CALL PRINT_MESSAGE
    PUSH AX
    MOV AX, CX
    CALL PRINT_DECIMAL
    POP AX
    CALL NEWLINE

    ; XCHG swaps the two in place. Doing it with MOV would need a third
    ; register to hold one of the values while the other is overwritten.
    XCHG AX, BX
    LEA DX, M_SWAPA
    CALL PRINT_MESSAGE
    CALL PRINT_DECIMAL
    LEA DX, M_SWAPB
    CALL PRINT_MESSAGE
    MOV AX, BX
    CALL PRINT_DECIMAL
    CALL NEWLINE
    CALL NEWLINE

    ; -------------------------------------------------------------------------
    ; THE FOUR GENERAL REGISTERS OVERLAP THEIR OWN HALVES. WRITING AH CHANGES
    ; THE TOP BYTE OF AX AND NOTHING ELSE, WHICH IS BOTH USEFUL AND THE CAUSE
    ; OF A COMMON BUG: SETTING AH FOR A DOS CALL DESTROYS A RESULT HELD IN AX.
    ; -------------------------------------------------------------------------
    LEA DX, M_HALF
    CALL PRINT_MESSAGE

    MOV AX, 258                         ; 0102H
    LEA DX, M_AX
    CALL PRINT_MESSAGE
    MOV AX, 258
    CALL PRINT_DECIMAL

    MOV BX, AX                          ; Keep the pair before AH is disturbed.
    LEA DX, M_AH
    CALL PRINT_MESSAGE
    XOR AX, AX
    MOV AL, BH
    CALL PRINT_DECIMAL

    LEA DX, M_AL

    CALL PRINT_MESSAGE
    XOR AX, AX
    MOV AL, BL
    CALL PRINT_DECIMAL
    CALL NEWLINE

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
; 1. The cheapest mode:
;    - Nothing is fetched from memory, so no effective address is formed.
;    - The register pair is encoded in a single byte after the opcode.
;    - This is why a tight loop keeps its counter and pointer in registers.
; 2. The halves overlap:
;    - AX is AH and AL, BX is BH and BL, and the same for CX and DX.
;    - 258 is 0102H, so AH holds 1 and AL holds 2.
;    - SI, DI, BP and SP have no halves and can only be used sixteen bits at a time.
; 3. The trap this program avoids:
;    - MOV AH, 09H for a DOS call overwrites the top half of any result in AX.
;    - That is why every message here goes through PRINT_MESSAGE, which pushes AX first.
;    - The pair is also copied to BX before AH is read, so 1 and 2 come out intact.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
