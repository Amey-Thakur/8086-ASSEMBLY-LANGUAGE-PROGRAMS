; =============================================================================
; TITLE: Repetition Done By The Assembler
; DESCRIPTION: A macro that expands its body a fixed number of times, so the repetition costs nothing at run time.
; AUTHOR: Amey Thakur (https://github.com/Amey-Thakur)
; REPOSITORY: https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
; LICENSE: MIT License
; =============================================================================

.MODEL SMALL
.STACK 100H

; -----------------------------------------------------------------------------
; MACRO DEFINITIONS
; -----------------------------------------------------------------------------

; ---- print one character ----------------------------------------------------
PUT_CHAR MACRO WHICH
    PUSH AX
    PUSH DX
    MOV DL, WHICH
    MOV AH, 02H
    INT 21H
    POP DX
    POP AX
ENDM

; ---- the same character several times, unrolled ------------------------------
; The count has to be a constant, because the assembler decides how many copies
; to write before the program ever runs. A run time count needs a real loop.
BAR MACRO WHICH, HOWMANY
    REPT HOWMANY
    PUT_CHAR WHICH
    ENDM
ENDM

; ---- one row of a bar chart -------------------------------------------------
ROW MACRO WHICH, HOWMANY
    BAR WHICH, HOWMANY
    CALL NEWLINE
ENDM

; -----------------------------------------------------------------------------
; DATA SEGMENT
; -----------------------------------------------------------------------------
.DATA
    M_TITLE DB 'REPT unrolls at assembly time, so no counter is needed', 0DH, 0AH, '$'
    M_CHART DB 'A chart drawn entirely by the assembler:', 0DH, 0AH, '$'
    M_LOOP  DB 0DH, 0AH, 'And the same row drawn by a real loop instead:', 0DH, 0AH, '$'
    M_COST  DB 0DH, 0AH
            DB 'The unrolled rows have no counter and no branch. The looped '
            DB 'row is shorter in the file and longer to run.', 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA DX, M_TITLE
    CALL PRINT_MESSAGE
    LEA DX, M_CHART
    CALL PRINT_MESSAGE

    ; -------------------------------------------------------------------------
    ; EACH ROW BELOW IS ONE LINE OF SOURCE AND SEVERAL COPIES OF PUT_CHAR IN
    ; THE ASSEMBLED OUTPUT. NOTHING COUNTS ANYTHING AT RUN TIME.
    ; -------------------------------------------------------------------------
    ROW '#', 3
    ROW '#', 6
    ROW '#', 9
    ROW '#', 12
    ROW '=', 12

    LEA DX, M_LOOP
    CALL PRINT_MESSAGE

    ; -------------------------------------------------------------------------
    ; THE ORDINARY WAY, FOR COMPARISON. THIS ONE COULD TAKE ITS COUNT FROM A
    ; VARIABLE, WHICH THE UNROLLED VERSION CANNOT.
    ; -------------------------------------------------------------------------
    MOV CX, 12
DRAW_ONE:
    PUT_CHAR '#'
    LOOP DRAW_ONE
    CALL NEWLINE

    LEA DX, M_COST
    CALL PRINT_MESSAGE

    MOV AH, 4CH
    INT 21H

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
; 1. REPT is assembly time repetition:
;    - The body is written out the given number of times into the source stream.
;    - The count must be a constant expression the assembler can evaluate.
;    - ENDM closes a REPT block just as it closes a macro.
; 2. Unrolling costs space:
;    - Twelve copies of PUT_CHAR is twelve times the code of one.
;    - In exchange there is no counter to maintain and no branch to predict.
;    - Unrolling a hot inner loop by a small factor is the usual compromise.
; 3. When a real loop is the only option:
;    - A count that is only known at run time cannot be unrolled.
;    - A count large enough to matter for code size should not be unrolled either.
;    - The looped row here does the same work from a register, and is the general case.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
