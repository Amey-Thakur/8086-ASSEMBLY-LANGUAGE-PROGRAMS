; =============================================================================
; TITLE: Proving a Procedure Preserves Every Register
; DESCRIPTION: Distinct markers are loaded into seven registers and compared
;              against what a procedure left behind, so the promise to preserve
;              them is tested rather than trusted.
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
    NUMBERS DW 1, 2, 3, 4, 5, 6, 7, 8, 9, 10
    NSPAN   EQU $ - NUMBERS             ; Measured, never counted by hand

    ; A marker per register, each one recognisable on sight in hexadecimal.
    MARKS   DW 1111H, 2222H, 3333H, 4444H, 5555H, 6666H, 7777H
    MSPAN   EQU $ - MARKS

    ; Whatever the registers hold the instant the procedure returns.
    SEEN    DW 7 DUP(?)

    N_AX    DB 'AX $'
    N_BX    DB 'BX $'
    N_CX    DB 'CX $'
    N_DX    DB 'DX $'
    N_SI    DB 'SI $'
    N_DI    DB 'DI $'
    N_BP    DB 'BP $'
    NAMES   DW N_AX, N_BX, N_CX, N_DX, N_SI, N_DI, N_BP

    WORKED  DW ?                        ; What the worker actually computed
    COUNTED DW ?

    M_TITLE DB 'Seven markers in, seven markers out', 0DH, 0AH, '$'
    M_ROUND1 DB 0DH, 0AH, 'After SAFE_WORKER, which saves and restores all seven'
             DB 0DH, 0AH, '$'
    M_ROUND2 DB 0DH, 0AH, 'After CARELESS_WORKER, which forgets one of them'
             DB 0DH, 0AH, '$'
    M_HOLDS DB 'holds $'
    M_WANT  DB ', wanted $'
    M_KEPT  DB ', kept', 0DH, 0AH, '$'
    M_LOST  DB ', lost', 0DH, 0AH, '$'
    M_WORK  DB 0DH, 0AH, 'Both workers added $'
    M_TO    DB ' numbers to $'
    M_STOP  DB 0DH, 0AH
            DB 'The careless worker gave the right answer and still broke its '
            DB 'caller, which is why the promise has to be checked and not '
            DB 'inferred from the result.', 0DH, 0AH, '$'

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
    ; ROUND ONE. THE MARKERS GO IN, THE PROCEDURE RUNS, AND THE SNAPSHOT IS
    ; TAKEN BEFORE ANY OUTPUT, SINCE PRINTING ITSELF USES AX AND DX.
    ; -------------------------------------------------------------------------
    LEA DX, M_ROUND1
    CALL PRINT_MESSAGE

    CALL LOAD_MARKERS
    CALL SAFE_WORKER
    CALL SNAPSHOT
    CALL REPORT

    ; -------------------------------------------------------------------------
    ; ROUND TWO. THE SAME ARITHMETIC, AND THE SAME MARKERS, BUT ONE PUSH IS
    ; MISSING FROM THE PROLOGUE OF THE PROCEDURE.
    ; -------------------------------------------------------------------------
    LEA DX, M_ROUND2
    CALL PRINT_MESSAGE

    CALL LOAD_MARKERS
    CALL CARELESS_WORKER
    CALL SNAPSHOT
    CALL REPORT

    LEA DX, M_WORK
    CALL PRINT_MESSAGE
    MOV AX, COUNTED
    CALL PRINT_DECIMAL
    LEA DX, M_TO
    CALL PRINT_MESSAGE
    MOV AX, WORKED
    CALL PRINT_DECIMAL
    CALL NEWLINE

    LEA DX, M_STOP
    CALL PRINT_MESSAGE

    MOV AH, 4CH
    INT 21H

; -----------------------------------------------------------------------------
; LOAD_MARKERS
;
; Puts the seven markers into the seven registers under test. It has to be the
; last thing before the call, because anything else would disturb them.
; -----------------------------------------------------------------------------
LOAD_MARKERS PROC
    MOV AX, 1111H
    MOV BX, 2222H
    MOV CX, 3333H
    MOV DX, 4444H
    MOV SI, 5555H
    MOV DI, 6666H
    MOV BP, 7777H
    RET
LOAD_MARKERS ENDP

; -----------------------------------------------------------------------------
; SNAPSHOT
;
; Copies the seven registers into memory exactly as they stand. CALL and RET
; move only the stack pointer and the instruction pointer, so wrapping this in
; a procedure of its own does not perturb what is being measured.
; -----------------------------------------------------------------------------
SNAPSHOT PROC
    MOV SEEN, AX
    MOV SEEN+2, BX
    MOV SEEN+4, CX
    MOV SEEN+6, DX
    MOV SEEN+8, SI
    MOV SEEN+10, DI
    MOV SEEN+12, BP
    RET
SNAPSHOT ENDP

; -----------------------------------------------------------------------------
; SAFE_WORKER
;
; Adds up NUMBERS, using every register it can, and gives all seven back. The
; pops mirror the pushes in reverse, which is the whole of the discipline.
; -----------------------------------------------------------------------------
SAFE_WORKER PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    PUSH DI
    PUSH BP

    XOR AX, AX                          ; The running total
    XOR BP, BP                          ; How many have been added
    LEA SI, NUMBERS
    MOV CX, NSPAN
    SHR CX, 1
    JCXZ SW_DONE                        ; LOOP with CX at zero would run forever

SW_NEXT:
    MOV DX, [SI]
    ADD AX, DX
    INC BP
    ADD SI, 2
    LOOP SW_NEXT

SW_DONE:
    MOV BX, AX
    MOV WORKED, BX
    MOV DI, BP
    MOV COUNTED, DI

    POP BP
    POP DI
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
SAFE_WORKER ENDP

; -----------------------------------------------------------------------------
; CARELESS_WORKER
;
; The same procedure with the save and restore of BX removed. Nothing about the
; answer changes, and nothing complains, which is what makes the fault so hard
; to find when it happens for real.
; -----------------------------------------------------------------------------
CARELESS_WORKER PROC
    PUSH AX
    PUSH CX
    PUSH DX
    PUSH SI
    PUSH DI
    PUSH BP

    XOR AX, AX
    XOR BP, BP
    LEA SI, NUMBERS
    MOV CX, NSPAN
    SHR CX, 1
    JCXZ CW_DONE

CW_NEXT:
    MOV DX, [SI]
    ADD AX, DX
    INC BP
    ADD SI, 2
    LOOP CW_NEXT

CW_DONE:
    MOV BX, AX                          ; BX is written and never given back
    MOV WORKED, BX
    MOV DI, BP
    MOV COUNTED, DI

    POP BP
    POP DI
    POP SI
    POP DX
    POP CX
    POP AX
    RET
CARELESS_WORKER ENDP

; -----------------------------------------------------------------------------
; REPORT
;
; Walks the three parallel tables together, one entry per register, and says
; for each whether the marker survived.
; -----------------------------------------------------------------------------
REPORT PROC
    PUSH AX
    PUSH BX
    PUSH SI
    PUSH DI

    XOR DI, DI                          ; Byte position within the tables

RP_NEXT:
    MOV SI, NAMES[DI]                   ; The address of this register's name
    MOV AX, SEEN[DI]
    MOV BX, MARKS[DI]
    CALL CHECK
    ADD DI, 2
    CMP DI, MSPAN
    JB  RP_NEXT

    POP DI
    POP SI
    POP BX
    POP AX
    RET
REPORT ENDP

; -----------------------------------------------------------------------------
; CHECK
;
; Entry: SI = address of a name, AX = what was seen, BX = what was wanted.
;
; The observed value is deliberately kept in AX rather than DX, because DX has
; to carry the address of every message that gets printed.
; -----------------------------------------------------------------------------
CHECK PROC
    PUSH AX
    PUSH BX
    PUSH DX

    MOV DX, SI
    CALL PRINT_MESSAGE                  ; The register's name
    LEA DX, M_HOLDS
    CALL PRINT_MESSAGE
    CALL PRINT_HEX                      ; AX is still what was seen

    LEA DX, M_WANT
    CALL PRINT_MESSAGE
    PUSH AX
    MOV AX, BX
    CALL PRINT_HEX
    POP AX                              ; Back to what was seen, for the verdict

    CMP AX, BX
    JE  CK_KEPT
    LEA DX, M_LOST
    JMP CK_SAY

CK_KEPT:
    LEA DX, M_KEPT

CK_SAY:
    CALL PRINT_MESSAGE

    POP DX
    POP BX
    POP AX
    RET
CHECK ENDP

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
; 1. WHY THE MARKERS ARE WHAT THEY ARE:
;    - Zero is the commonest accidental value, so it proves nothing.
;    - Each marker differs from every other, naming the guilty register.
;    - Printed in hexadecimal they read straight back as they were written.
; 2. WHAT THE SNAPSHOT MUST NOT DO:
;    - It runs before any output, since printing needs AX and DX itself.
;    - It uses only stores to memory, so it disturbs no register at all.
;    - CALL and RET change SP and IP alone, which is why it can be a procedure.
; 3. THE COST OF THE PROMISE:
;    - Seven pushes and seven pops, twenty eight bytes of stack.
;    - A procedure that documents which registers it destroys is cheaper.
;    - Whichever is chosen, the header has to say so plainly.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
