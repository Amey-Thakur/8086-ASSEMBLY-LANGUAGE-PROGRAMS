; =============================================================================
; TITLE: Saving Every Register Across A Call
; DESCRIPTION: A procedure that promises to change nothing, and the proof that it kept the promise.
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
    M_TITLE DB 'A procedure that leaves every register as it found it', 0DH, 0AH, '$'
    M_BEFOR DB 'before:  AX=$'
    M_AFTER DB 'after:   AX=$'
    M_BX    DB ' BX=$'
    M_CX    DB ' CX=$'
    M_SI    DB ' SI=$'
    M_DI    DB ' DI=$'
    M_BP    DB ' BP=$'
    M_INSID DB 'The procedure filled all six with 9999 while it ran.', 0DH, 0AH
            DB 'DX is not one of the six. It carries the message pointer for '
            DB 'every print here, so it can never hold a test value.', 0DH, 0AH, '$'
    M_MATCH DB 'Every register matches: the save was complete.', 0DH, 0AH, '$'
    M_DIFF  DB 'Something differs: the save was not complete.', 0DH, 0AH, '$'
    KEEP_W  DW 6 DUP (0)                ; The recorded copy, for the comparison
    SHOW_W  DW 6 DUP (0)                ; A scratch copy, so printing is safe

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
    ; SIX DISTINCT VALUES SO THAT ANY REGISTER RESTORED INTO THE WRONG PLACE
    ; SHOWS UP. A COMMON BUG IS POPPING IN THE SAME ORDER AS THE PUSHES, WHICH
    ; SWAPS THEM ROUND AND WOULD BE INVISIBLE IF THEY ALL HELD THE SAME THING.
    ; -------------------------------------------------------------------------
    MOV AX, 1
    MOV BX, 2
    MOV CX, 3
    MOV SI, 5
    MOV DI, 6
    MOV BP, 7

    CALL SNAPSHOT                       ; Record what they hold now
    LEA DX, M_BEFOR
    CALL PRINT_MESSAGE
    CALL SHOW_ALL

    CALL WELL_BEHAVED

    LEA DX, M_AFTER
    CALL PRINT_MESSAGE
    CALL SHOW_ALL
    CALL NEWLINE

    LEA DX, M_INSID
    CALL PRINT_MESSAGE

    ; -------------------------------------------------------------------------
    ; THE CHECK COMPARES THE LIVE REGISTERS AGAINST THE RECORDED COPIES RATHER
    ; THAN TRUSTING THE PRINTED OUTPUT TO BE READ CAREFULLY.
    ; -------------------------------------------------------------------------
    CMP AX, KEEP_W
    JNE MISMATCH
    CMP BX, KEEP_W+2
    JNE MISMATCH
    CMP CX, KEEP_W+4
    JNE MISMATCH
    CMP SI, KEEP_W+6
    JNE MISMATCH
    CMP DI, KEEP_W+8
    JNE MISMATCH
    CMP BP, KEEP_W+10
    JNE MISMATCH

    LEA DX, M_MATCH
    CALL PRINT_MESSAGE
    JMP FINISHED

MISMATCH:
    LEA DX, M_DIFF
    CALL PRINT_MESSAGE

FINISHED:
    MOV AH, 4CH
    INT 21H

; -----------------------------------------------------------------------------
; WELL_BEHAVED
;
; Overwrites six registers and then puts them all back. The pops are in the
; exact reverse of the pushes, which is what a stack demands.
; -----------------------------------------------------------------------------
WELL_BEHAVED PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH SI
    PUSH DI
    PUSH BP

    MOV AX, 9999
    MOV BX, 9999
    MOV CX, 9999
    MOV SI, 9999
    MOV DI, 9999
    MOV BP, 9999

    POP BP
    POP DI
    POP SI
    POP CX
    POP BX
    POP AX
    RET
WELL_BEHAVED ENDP

; -----------------------------------------------------------------------------
; SNAPSHOT
;
; Copies the six registers into KEEP_W so they can be compared later.
; -----------------------------------------------------------------------------
SNAPSHOT PROC
    MOV KEEP_W, AX
    MOV KEEP_W+2, BX
    MOV KEEP_W+4, CX
    MOV KEEP_W+6, SI
    MOV KEEP_W+8, DI
    MOV KEEP_W+10, BP
    RET
SNAPSHOT ENDP

; -----------------------------------------------------------------------------
; SHOW_ALL
;
; Prints all six registers on one line and restores everything it used.
; -----------------------------------------------------------------------------
SHOW_ALL PROC
    ; Every value is copied out before anything is printed. Printing needs DX
    ; for the message and AX for the number, so reading a register after the
    ; first line would report the printer rather than the caller.
    MOV SHOW_W, AX
    MOV SHOW_W+2, BX
    MOV SHOW_W+4, CX
    MOV SHOW_W+6, SI
    MOV SHOW_W+8, DI
    MOV SHOW_W+10, BP

    PUSH AX
    PUSH DX

    MOV AX, SHOW_W
    CALL PRINT_DECIMAL

    LEA DX, M_BX
    CALL PRINT_MESSAGE
    MOV AX, SHOW_W+2
    CALL PRINT_DECIMAL

    LEA DX, M_CX
    CALL PRINT_MESSAGE
    MOV AX, SHOW_W+4
    CALL PRINT_DECIMAL

    LEA DX, M_SI
    CALL PRINT_MESSAGE
    MOV AX, SHOW_W+6
    CALL PRINT_DECIMAL

    LEA DX, M_DI
    CALL PRINT_MESSAGE
    MOV AX, SHOW_W+8
    CALL PRINT_DECIMAL

    LEA DX, M_BP
    CALL PRINT_MESSAGE
    MOV AX, SHOW_W+10
    CALL PRINT_DECIMAL
    CALL NEWLINE

    POP DX
    POP AX
    RET
SHOW_ALL ENDP

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
; 1. Pops mirror pushes:
;    - The last register pushed is the first that must be popped.
;    - Popping in the pushing order silently swaps values between registers.
;    - Six different starting values make such a mistake visible immediately.
; 2. Why DX is not tested:
;    - Every message is printed by putting its address in DX and calling DOS.
;    - A register doing that cannot also carry a value under test.
;    - BP stands in for it, and is just as easy for a careless procedure to lose.
; 3. PUSHA does not exist here:
;    - PUSHA and POPA arrive with the 80186, not the 8086.
;    - An 8086 procedure has to name every register it saves.
;    - That is why the helpers in this repository push only what they actually use.
; 4. Checked, not eyeballed:
;    - The program compares the live registers against a recorded copy.
;    - A printed line that looks right can still be wrong in a digit.
;    - Letting the program do the comparison is the whole idea behind a self checking test.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
