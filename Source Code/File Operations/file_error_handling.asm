; =============================================================================
; TITLE: Decoding File Errors
; DESCRIPTION: Every failing file call is provoked deliberately and its error code turned into an explanation.
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
    REAL_N  DB 'EXISTS.TXT', 0
    FAKE_N  DB 'NOWHERE.TXT', 0
    CONTENT DB 'anything', 0
    SPAN    EQU $ - CONTENT
    BUFFER  DB 20 DUP (0)

    M_TITLE DB 'Every file error, provoked on purpose', 0DH, 0AH, '$'
    M_CASE1 DB 0DH, 0AH, '1. Opening a file that is not there', 0DH, 0AH, '$'
    M_CASE2 DB 0DH, 0AH, '2. Deleting a file that is not there', 0DH, 0AH, '$'
    M_CASE3 DB 0DH, 0AH, '3. Reading from a handle never opened', 0DH, 0AH, '$'
    M_CASE4 DB 0DH, 0AH, '4. Writing to a handle opened read only', 0DH, 0AH, '$'
    M_CASE5 DB 0DH, 0AH, '5. Closing a handle twice', 0DH, 0AH, '$'
    M_OK    DB '   the call succeeded, which was not expected', 0DH, 0AH, '$'
    M_ERR   DB '   failed with code $'
    M_E01   DB ', invalid function', 0DH, 0AH, '$'
    M_E02   DB ', file not found', 0DH, 0AH, '$'
    M_E05   DB ', access denied', 0DH, 0AH, '$'
    M_E06   DB ', invalid handle', 0DH, 0AH, '$'
    M_EOTH  DB ', not one of the codes this program knows', 0DH, 0AH, '$'
    M_ALL   DB 0DH, 0AH, 'Failures provoked: $'
    M_OUTOF DB ' out of 5', 0DH, 0AH, '$'
    M_WHY   DB 0DH, 0AH
            DB 'The carry flag says whether it failed and AX says why. Testing '
            DB 'AX without the carry flag cannot tell a handle from an error.'
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

    XOR BP, BP                          ; Failures seen, as expected

    ; ---- something that does exist, for case four --------------------------
    LEA DX, REAL_N
    MOV CX, 0
    MOV AH, 3CH
    INT 21H
    JC FINISHED
    MOV BX, AX

    LEA DX, CONTENT
    MOV CX, SPAN
    MOV AH, 40H
    INT 21H

    MOV AH, 3EH
    INT 21H

    ; ---- 1. open something absent -------------------------------------------
    LEA DX, M_CASE1
    CALL PRINT_MESSAGE
    MOV AX, 3D00H
    LEA DX, FAKE_N
    INT 21H
    CALL REPORT_OUTCOME

    ; ---- 2. delete something absent -----------------------------------------
    LEA DX, M_CASE2
    CALL PRINT_MESSAGE
    LEA DX, FAKE_N
    MOV AH, 41H
    INT 21H
    CALL REPORT_OUTCOME

    ; ---- 3. read from a handle that was never opened ------------------------
    LEA DX, M_CASE3
    CALL PRINT_MESSAGE
    MOV BX, 99                          ; No such handle
    LEA DX, BUFFER
    MOV CX, 4
    MOV AH, 3FH
    INT 21H
    CALL REPORT_OUTCOME

    ; ---- 4. write to a read only handle -------------------------------------
    LEA DX, M_CASE4
    CALL PRINT_MESSAGE
    MOV AX, 3D00H                       ; Read only
    LEA DX, REAL_N
    INT 21H
    JC FINISHED
    MOV SI, AX                          ; Keep it, to close afterwards
    MOV BX, AX

    LEA DX, CONTENT
    MOV CX, SPAN
    MOV AH, 40H
    INT 21H
    CALL REPORT_OUTCOME

    ; ---- 5. close the same handle twice -------------------------------------
    LEA DX, M_CASE5
    CALL PRINT_MESSAGE
    MOV BX, SI
    MOV AH, 3EH
    INT 21H                             ; The first close, which works

    MOV BX, SI
    MOV AH, 3EH
    INT 21H                             ; The second, which cannot
    CALL REPORT_OUTCOME

    LEA DX, M_ALL
    CALL PRINT_MESSAGE
    MOV AX, BP
    CALL PRINT_DECIMAL
    LEA DX, M_OUTOF
    CALL PRINT_MESSAGE

    LEA DX, M_WHY
    CALL PRINT_MESSAGE

FINISHED:
    MOV AH, 4CH
    INT 21H

; -----------------------------------------------------------------------------
; REPORT_OUTCOME
;
; Reads the carry flag and AX as DOS left them and says what happened. Must be
; called immediately after the service, before anything disturbs either.
;
; PUSHF is taken first so that the printing inside can use the flags freely. The
; carry flag is still readable after it, because neither PUSHF nor PUSH nor MOV
; alters the flags.
; -----------------------------------------------------------------------------
REPORT_OUTCOME PROC
    PUSHF
    PUSH AX
    PUSH DX
    PUSH SI

    MOV SI, AX                          ; The code, before printing changes AX

    ; PUSH and MOV leave the flags alone, so the carry flag DOS set is still
    ; live here and can be tested directly. Popping the saved copy back would
    ; take the word PUSH SI just left on top instead.
    JC IT_FAILED

    LEA DX, M_OK
    CALL PRINT_MESSAGE
    JMP OUTCOME_DONE

IT_FAILED:
    INC BP

    LEA DX, M_ERR
    CALL PRINT_MESSAGE
    MOV AX, SI
    CALL PRINT_DECIMAL

    ; ---- turn the number into words -----------------------------------------
    CMP SI, 1
    JNE TRY_02
    LEA DX, M_E01
    JMP SAY_MEANING
TRY_02:
    CMP SI, 2
    JNE TRY_05
    LEA DX, M_E02
    JMP SAY_MEANING
TRY_05:
    CMP SI, 5
    JNE TRY_06
    LEA DX, M_E05
    JMP SAY_MEANING
TRY_06:
    CMP SI, 6
    JNE USE_OTHER
    LEA DX, M_E06
    JMP SAY_MEANING
USE_OTHER:
    LEA DX, M_EOTH

SAY_MEANING:
    CALL PRINT_MESSAGE

OUTCOME_DONE:
    POP SI
    POP DX
    POP AX
    POPF
    RET
REPORT_OUTCOME ENDP

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
; 1. The flag and the code together:
;    - Carry set means AX is an error code; carry clear means it is a result.
;    - Handle 2 and error 2 are indistinguishable without the flag.
;    - A wrapper that reads both at once, as here, is worth writing in any real program.
; 2. The five codes worth knowing:
;    - One is an invalid function, two a missing file, five access denied, six a bad handle.
;    - Three and four cover paths and too many open files.
;    - Anything else is worth printing rather than swallowing, which is what the last case does.
; 3. Preserving the flags across the report:
;    - The reporting routine prints, and printing changes the flags.
;    - PUSHF at entry and POPF at exit leave the caller exactly as DOS left it.
;    - Without that a JC after the call would test the flags of the last print.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
