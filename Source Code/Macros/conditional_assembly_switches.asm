; =============================================================================
; TITLE: Conditional Assembly From A Switch
; DESCRIPTION: One source file that assembles to different programs depending on a constant set at the top.
; AUTHOR: Amey Thakur (https://github.com/Amey-Thakur)
; REPOSITORY: https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
; LICENSE: MIT License
; =============================================================================

.MODEL SMALL
.STACK 100H

; -----------------------------------------------------------------------------
; BUILD SWITCHES
;
; These are read by the assembler, not by the processor. Changing one and
; reassembling produces a genuinely different program: the excluded code is not
; skipped at run time, it is never emitted at all.
; -----------------------------------------------------------------------------
VERBOSE   EQU 1                         ; 1 includes the commentary
CHECKING  EQU 1                         ; 1 includes the range check
UNITS     EQU 2                         ; 1 metric, 2 imperial

; -----------------------------------------------------------------------------
; MACRO DEFINITIONS
; -----------------------------------------------------------------------------

; A trace line that costs nothing at all when VERBOSE is zero.
TRACE MACRO WHICH
    IF VERBOSE
    LEA DX, WHICH
    CALL PRINT_MESSAGE
    ENDIF
ENDM

; -----------------------------------------------------------------------------
; DATA SEGMENT
; -----------------------------------------------------------------------------
.DATA
    INPUT_W DW 40

    M_TITLE DB 'One file, several programs, decided at assembly time', 0DH, 0AH, '$'
    M_TRACE DB '  [trace] about to convert', 0DH, 0AH, '$'
    M_CHECK DB '  [trace] range checked and accepted', 0DH, 0AH, '$'
    M_METRE DB 'Metric build:   40 units becomes $'
    M_IMPER DB 'Imperial build: 40 units becomes $'
    M_TOOBIG DB 'The input is out of range.', 0DH, 0AH, '$'
    M_WHICH DB 0DH, 0AH, 'VERBOSE is 1, CHECKING is 1, UNITS is 2.', 0DH, 0AH, '$'
    M_GONE  DB 'The metric branch is not in this program at all.', 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA DX, M_TITLE
    CALL PRINT_MESSAGE

    TRACE M_TRACE

    ; -------------------------------------------------------------------------
    ; THE RANGE CHECK IS OPTIONAL. A DEBUG BUILD KEEPS IT AND A RELEASE BUILD
    ; LEAVES IT OUT, WHICH IS THE OLDEST USE OF CONDITIONAL ASSEMBLY THERE IS.
    ; -------------------------------------------------------------------------
    MOV AX, INPUT_W

    IF CHECKING
    CMP AX, 1000
    JBE IN_RANGE
    LEA DX, M_TOOBIG
    CALL PRINT_MESSAGE
    JMP FINISHED
IN_RANGE:
    TRACE M_CHECK
    ENDIF

    ; -------------------------------------------------------------------------
    ; TWO MUTUALLY EXCLUSIVE CONVERSIONS. ONLY ONE REACHES THE OUTPUT FILE, SO
    ; THERE IS NO RUN TIME TEST AND NO DEAD CODE.
    ; -------------------------------------------------------------------------
    IF UNITS EQ 1
    LEA DX, M_METRE
    CALL PRINT_MESSAGE
    MOV BX, 100                         ; Metric: multiply by a hundred
    MUL BX
    ELSE
    LEA DX, M_IMPER
    CALL PRINT_MESSAGE
    MOV BX, 12                          ; Imperial: multiply by twelve
    MUL BX
    ENDIF

    CALL PRINT_DECIMAL
    CALL NEWLINE

    LEA DX, M_WHICH
    CALL PRINT_MESSAGE
    LEA DX, M_GONE
    CALL PRINT_MESSAGE

FINISHED:
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
; 1. Not the same as an IF at run time:
;    - A conditional jump tests a value while the program runs and both paths exist.
;    - IF and ENDIF decide what exists, and the rejected path is never assembled.
;    - The excluded code cannot be reached even by a jump, because it is not there.
; 2. The usual switches:
;    - A verbosity or trace flag, so instrumentation costs nothing when off.
;    - A checking flag, kept in a debug build and dropped in a release one.
;    - A variant selector, as UNITS is here, for one source and several products.
; 3. The forms available:
;    - IF tests an expression, IFE tests it for zero, and IFDEF tests whether a name exists.
;    - ELSE and ENDIF close the block, and they nest.
;    - EQ, NE, LT and GT compare inside the condition, as UNITS EQ 1 does here.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
