; =============================================================================
; TITLE: Every Flag After A Single Addition
; DESCRIPTION: Adds five pairs of words and prints all six status flags after
;              each one, taken from the flags word rather than from a branch.
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
    ; Five additions at the edges of the word, where the interesting flags are.
    PAIRS   DW 0FFFFH, 0001H, 7FFFH, 0001H, 0001H, 0002H, 0007H, 0000H
            DW 8000H, 8000H
    HOWMANY EQU 5

    ; Where each status flag sits in the word PUSHF stores, in the order the
    ; table prints them. Bits 1, 3 and 5 are not implemented and are skipped.
    MASKS   DW 0001H, 0004H, 0010H, 0040H, 0080H, 0800H
    NMASKS  EQU 6

    M_TITLE DB 'Every flag after a single addition', 0DH, 0AH, 0DH, 0AH
            DB 'One ADD sets all six of these, every time, whether or not the '
            DB 'program', 0DH, 0AH
            DB 'goes on to look at any of them. PUSHF is the way to read them '
            DB 'without', 0DH, 0AH
            DB 'branching on one and losing the rest.', 0DH, 0AH, 0DH, 0AH, '$'
    M_HEAD  DB '    A      B    sum  CF  PF  AF  ZF  SF  OF', 0DH, 0AH
            DB '-----  -----  -----  --  --  --  --  --  --', 0DH, 0AH, '$'
    M_GAP   DB '  $'
    M_FGAP  DB '   $'
    M_CLOSE DB 0DH, 0AH
            DB 'Row one wrapped to zero and row five wrapped to zero as well, '
            DB 'yet only', 0DH, 0AH
            DB 'one of them overflowed as a signed sum. Row two did not carry '
            DB 'at all and', 0DH, 0AH
            DB 'still overflowed. No single flag tells the whole story.'
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
    LEA DX, M_HEAD
    CALL PRINT_MESSAGE

    LEA SI, PAIRS
    MOV CX, HOWMANY

EACH_ROW:
    PUSH CX

    MOV AX, [SI]
    CALL PRINT_HEX
    LEA DX, M_GAP
    CALL PRINT_MESSAGE

    MOV AX, [SI+2]
    CALL PRINT_HEX
    LEA DX, M_GAP
    CALL PRINT_MESSAGE

    ; -------------------------------------------------------------------------
    ; PUSHF IS THE ONLY WAY TO KEEP ALL SIX AT ONCE. A CONDITIONAL JUMP READS
    ; ONE FLAG AND THE NEXT INSTRUCTION TO TOUCH THE ARITHMETIC UNIT DESTROYS
    ; THE OTHER FIVE, SO THE WORD IS TAKEN BEFORE ANYTHING ELSE RUNS.
    ; -------------------------------------------------------------------------
    MOV AX, [SI]
    ADD AX, [SI+2]
    PUSHF
    POP BX

    CALL PRINT_HEX
    CALL SHOW_FLAGS
    CALL NEWLINE

    POP CX
    ADD SI, 4                           ; Two words to the next pair
    LOOP EACH_ROW

    LEA DX, M_CLOSE
    CALL PRINT_MESSAGE

    MOV AH, 4CH
    INT 21H

; -----------------------------------------------------------------------------
; SHOW_FLAGS
;
; Prints the six status flags held in the flags word in BX, each as a digit in
; a four column field. Walking a table of masks keeps the six cases identical,
; which a run of separate tests would not.
; -----------------------------------------------------------------------------
SHOW_FLAGS PROC
    PUSH AX
    PUSH CX
    PUSH DX
    PUSH SI

    XOR SI, SI                          ; Offset into the mask table
    MOV CX, NMASKS

SFL_ONE:
    PUSH CX

    LEA DX, M_FGAP
    CALL PRINT_MESSAGE

    MOV AX, MASKS[SI]
    AND AX, BX
    JZ  SFL_CLEAR
    MOV AX, 1                           ; A flag prints as one column, not as a mask
    JMP SFL_EMIT

SFL_CLEAR:
    XOR AX, AX

SFL_EMIT:
    CALL PRINT_DECIMAL

    ADD SI, 2                           ; The masks are words
    POP CX
    LOOP SFL_ONE

    POP SI
    POP DX
    POP CX
    POP AX
    RET
SHOW_FLAGS ENDP

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

END START

; =============================================================================
; TECHNICAL NOTES
; =============================================================================
; 1. THE LAYOUT OF THE WORD:
;    - Carry is bit 0, parity bit 2, auxiliary carry bit 4, zero bit 6,
;    - sign bit 7 and overflow bit 11. The gaps are unimplemented bits,
;    - and the low byte is exactly what LAHF copies into AH.
; 2. PARITY IS THE ODD ONE OUT:
;    - It is computed on the low eight bits of the result even here, where
;    - every addition is sixteen bits wide. That is why row two shows even
;    - parity for 8000H, whose low byte is zero.
; 3. INC AND DEC DO NOT BELONG IN THIS TABLE:
;    - They set every flag shown except the carry, which they deliberately
;    - leave alone so that a loop counter can be advanced in the middle of
;    - a multi word addition.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
