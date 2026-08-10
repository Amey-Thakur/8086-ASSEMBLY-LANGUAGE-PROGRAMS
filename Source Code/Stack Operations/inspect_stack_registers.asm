; =============================================================================
; TITLE: Inspecting SS, SP And BP
; DESCRIPTION: Prints the three registers that describe the stack and shows the linear address they combine into.
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
    M_TITLE DB 'The three registers that describe the stack', 0DH, 0AH, '$'
    M_SS    DB 'SS, the stack segment:      $'
    M_SP    DB 'SP, the top of the stack:   $'
    M_BP    DB 'BP, the current frame:      $'
    M_LIN   DB 'SS:SP as a linear address:  $'
    M_HOW   DB 'A linear address is the segment shifted left four, plus the '
            DB 'offset.', 0DH, 0AH, '$'
    M_AFTER DB 0DH, 0AH, 'After three pushes SP has dropped by six:', 0DH, 0AH, '$'
    M_NOW   DB 'SP is now:                  $'
    M_SAME  DB 'SS is unchanged:            $'
    M_SEG   DB 'A push moves the offset only. The segment never moves.', 0DH, 0AH, '$'

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
    ; ALL THREE ARE READ INTO SAFE REGISTERS FIRST. PRINTING PUSHES, SO ANY
    ; READING OF SP AFTER THE FIRST CALL WOULD REPORT THE PRINTER RATHER THAN
    ; THE PROGRAM.
    ; -------------------------------------------------------------------------
    MOV BX, SP
    MOV CX, BP
    MOV DI, SS

    LEA DX, M_SS
    CALL PRINT_MESSAGE
    MOV AX, DI
    CALL PRINT_HEX
    CALL NEWLINE

    LEA DX, M_SP
    CALL PRINT_MESSAGE
    MOV AX, BX
    CALL PRINT_HEX
    CALL NEWLINE

    LEA DX, M_BP
    CALL PRINT_MESSAGE
    MOV AX, CX
    CALL PRINT_HEX
    CALL NEWLINE

    ; -------------------------------------------------------------------------
    ; THE LINEAR ADDRESS IS TWENTY BITS, WHICH DOES NOT FIT IN ONE REGISTER.
    ; ONLY THE LOW SIXTEEN ARE SHOWN HERE, WHICH IS ENOUGH TO SEE THE OFFSET
    ; BEING ADDED TO THE SHIFTED SEGMENT.
    ; -------------------------------------------------------------------------
    MOV AX, DI
    MOV CL, 4
    SHL AX, CL                          ; Segment times sixteen
    ADD AX, BX                          ; Plus the offset
    LEA DX, M_LIN
    CALL PRINT_MESSAGE
    CALL PRINT_HEX
    CALL NEWLINE

    LEA DX, M_HOW
    CALL PRINT_MESSAGE

    LEA DX, M_AFTER
    CALL PRINT_MESSAGE

    MOV AX, 1
    PUSH AX
    PUSH AX
    PUSH AX
    MOV BX, SP
    MOV DI, SS

    LEA DX, M_NOW
    CALL PRINT_MESSAGE
    MOV AX, BX
    CALL PRINT_HEX
    CALL NEWLINE

    LEA DX, M_SAME
    CALL PRINT_MESSAGE
    MOV AX, DI
    CALL PRINT_HEX
    CALL NEWLINE

    POP AX
    POP AX
    POP AX

    LEA DX, M_SEG
    CALL PRINT_MESSAGE

    MOV AH, 4CH
    INT 21H

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
; 1. Three registers, three jobs:
;    - SS says which 64K segment the stack lives in.
;    - SP says where the top of it currently is, and moves on every push and pop.
;    - BP marks a fixed point inside a frame and moves only when a procedure sets it.
; 2. The segmented address:
;    - The physical address is the segment shifted left four bits plus the offset.
;    - That gives twenty bits, which is the full megabyte an 8086 can reach.
;    - Only the low sixteen bits are printed here, because AX is all there is to print with.
; 3. MOV SS needs care on real hardware:
;    - Loading SS and SP separately leaves a window where the pair is inconsistent.
;    - An interrupt in that window would push onto a half changed stack.
;    - The 8086 suppresses interrupts after a MOV to SS for exactly one instruction.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
