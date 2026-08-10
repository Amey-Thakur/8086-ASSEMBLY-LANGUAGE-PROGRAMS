; =============================================================================
; TITLE: How An Interrupt Reports Failure
; DESCRIPTION: DOS uses the carry flag and an error code in AX, and the convention is worth learning once rather than per service.
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
    REAL_N  DB 'PRESENT.TXT', 0
    FAKE_N  DB 'MISSING.TXT', 0
    CONTENT DB 'some bytes'
    SPAN    EQU $ - CONTENT

    M_TITLE DB 'The convention every DOS service follows', 0DH, 0AH, '$'
    M_RULE  DB 0DH, 0AH
            DB 'Carry clear: AX holds the result. Carry set: AX holds an error '
            DB 'code. AX alone cannot tell you which.', 0DH, 0AH, '$'
    M_OPEN  DB 0DH, 0AH, 'Opening a file that exists:  $'
    M_MISS  DB 0DH, 0AH, 'Opening one that does not:   $'
    M_CLOSE DB 0DH, 0AH, 'Closing a handle never open: $'
    M_OK    DB 'carry clear, AX = $'
    M_BAD   DB 'carry set,   AX = $'
    M_SAME  DB 0DH, 0AH, 0DH, 0AH, 'Notice that the two AX values above can be '
            DB 'the same number. Only the carry flag separates a handle from an '
            DB 'error.', 0DH, 0AH, '$'
    M_TEST  DB 0DH, 0AH, 'So the test is always JC or JNC immediately after the '
            DB 'interrupt, before anything else disturbs the flags.', 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA DX, M_TITLE
    CALL PRINT_MESSAGE
    LEA DX, M_RULE
    CALL PRINT_MESSAGE

    ; ---- something that exists, so the success path can be shown ------------
    LEA DX, REAL_N
    XOR CX, CX
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

    ; ---- a call that succeeds ----------------------------------------------
    LEA DX, M_OPEN
    CALL PRINT_MESSAGE
    MOV AX, 3D00H
    LEA DX, REAL_N
    INT 21H
    CALL REPORT_FLAG
    MOV BX, AX
    MOV AH, 3EH
    INT 21H

    ; ---- one that fails with a missing file --------------------------------
    LEA DX, M_MISS
    CALL PRINT_MESSAGE
    MOV AX, 3D00H
    LEA DX, FAKE_N
    INT 21H
    CALL REPORT_FLAG

    ; ---- and one that fails with a bad handle ------------------------------
    LEA DX, M_CLOSE
    CALL PRINT_MESSAGE
    MOV BX, 42
    MOV AH, 3EH
    INT 21H
    CALL REPORT_FLAG

    LEA DX, M_SAME
    CALL PRINT_MESSAGE
    LEA DX, M_TEST
    CALL PRINT_MESSAGE

FINISHED:
    MOV AH, 4CH
    INT 21H

; -----------------------------------------------------------------------------
; REPORT_FLAG
;
; Says how the call that just returned ended. It must be called immediately,
; because printing anything at all would set the flags itself.
;
; The carry flag is read first and AX copied out, before either can be lost.
; -----------------------------------------------------------------------------
REPORT_FLAG PROC
    PUSHF
    PUSH AX
    PUSH DX
    PUSH SI

    MOV SI, AX                          ; The result or the code

    ; PUSH and MOV leave the flags alone, so the carry flag DOS set is still the
    ; live one here and can be tested directly.
    JC IT_FAILED

    LEA DX, M_OK
    CALL PRINT_MESSAGE
    JMP SHOW_VALUE

IT_FAILED:
    LEA DX, M_BAD
    CALL PRINT_MESSAGE

SHOW_VALUE:
    MOV AX, SI
    CALL PRINT_DECIMAL

    POP SI
    POP DX
    POP AX
    POPF
    RET
REPORT_FLAG ENDP

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
; 1. The flag and the value together:
;    - Carry clear means AX is the answer; carry set means AX is why there is none.
;    - A handle of 6 and the error code 6 are the same bits in the same register.
;    - So the flag is not an optimisation, it is the only thing that disambiguates.
; 2. Test immediately:
;    - Almost every instruction changes the flags, including anything that prints.
;    - JC or JNC belongs on the line after the interrupt, before anything else.
;    - A reporting routine called in between has to save and restore the flags itself.
; 3. The same convention throughout:
;    - Every file service, and most others, report this way.
;    - The BIOS is less consistent, and several of its services use a status byte instead.
;    - Learning the DOS rule once removes the need to look up each service.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
