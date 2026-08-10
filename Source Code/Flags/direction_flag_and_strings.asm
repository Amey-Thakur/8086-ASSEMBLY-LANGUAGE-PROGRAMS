; =============================================================================
; TITLE: The Direction Flag
; DESCRIPTION: One flag decides whether the string instructions count up or down, and leaving it set is a classic way to break DOS.
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
    SOURCE  DB 'ABCDEFGH'
    SPAN    EQU $ - SOURCE
    FORWARD DB SPAN DUP ('?')
    BACKWRD DB SPAN DUP ('?')

    M_TITLE DB 'CLD counts up, STD counts down', 0DH, 0AH, '$'
    M_SRC   DB 0DH, 0AH, 'source:            $'
    M_FWD   DB 0DH, 0AH, 'copied with CLD:   $'
    M_BWD   DB 0DH, 0AH, 'copied with STD:   $'
    M_SI    DB 0DH, 0AH, 0DH, 0AH, 'After the forward copy SI advanced to $'
    M_SI2   DB 0DH, 0AH, 'After the backward copy SI retreated to $'
    M_WHY   DB 0DH, 0AH, 0DH, 0AH
            DB 'The flag is global and survives a call. DOS and the BIOS assume '
            DB 'it is clear, so a routine that sets it must clear it again.'
            DB 0DH, 0AH, '$'
    M_LAST  DB 'That is why every string routine here ends with CLD, whether or '
            DB 'not it used STD.', 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX
    MOV ES, AX

    LEA DX, M_TITLE
    CALL PRINT_MESSAGE

    LEA DX, M_SRC
    CALL PRINT_MESSAGE
    LEA SI, SOURCE
    MOV CX, SPAN
    CALL PRINT_TEXT

    ; -------------------------------------------------------------------------
    ; FORWARD. BOTH POINTERS START AT THE FIRST BYTE AND COUNT UP, WHICH IS WHAT
    ; CLD SELECTS AND WHAT EVERY ORDINARY COPY WANTS.
    ; -------------------------------------------------------------------------
    CLD
    LEA SI, SOURCE
    LEA DI, FORWARD
    MOV CX, SPAN
    REP MOVSB
    MOV BP, SI                          ; Where SI ended up

    LEA DX, M_FWD
    CALL PRINT_MESSAGE
    LEA SI, FORWARD
    MOV CX, SPAN
    CALL PRINT_TEXT

    ; -------------------------------------------------------------------------
    ; BACKWARD. BOTH POINTERS START AT THE LAST BYTE AND COUNT DOWN, SO THE COPY
    ; COMES OUT IN THE SAME ORDER, NOT REVERSED. STD REVERSES THE DIRECTION OF
    ; TRAVEL, NOT THE RESULT.
    ; -------------------------------------------------------------------------
    STD
    LEA SI, SOURCE
    ADD SI, SPAN - 1
    LEA DI, BACKWRD
    ADD DI, SPAN - 1
    MOV CX, SPAN
    REP MOVSB
    MOV DI, SI                          ; Where SI ended up this time
    CLD                                 ; Always leave it clear

    LEA DX, M_BWD
    CALL PRINT_MESSAGE
    LEA SI, BACKWRD
    MOV CX, SPAN
    CALL PRINT_TEXT

    LEA DX, M_SI
    CALL PRINT_MESSAGE
    MOV AX, BP
    CALL PRINT_DECIMAL

    LEA DX, M_SI2
    CALL PRINT_MESSAGE
    MOV AX, DI
    CALL PRINT_DECIMAL

    LEA DX, M_WHY
    CALL PRINT_MESSAGE
    LEA DX, M_LAST
    CALL PRINT_MESSAGE

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
; PRINT_TEXT
;
; Prints CX characters starting at DS:SI. Both are left as they were found.
; -----------------------------------------------------------------------------
PRINT_TEXT PROC
    PUSH AX
    PUSH CX
    PUSH DX
    PUSH SI

    JCXZ PT_DONE                        ; Nothing to print

PT_LOOP:
    MOV DL, [SI]
    MOV AH, 02H
    INT 21H
    INC SI
    LOOP PT_LOOP

PT_DONE:
    POP SI
    POP DX
    POP CX
    POP AX
    RET
PRINT_TEXT ENDP

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
; 1. Direction of travel, not of the result:
;    - Both copies produce the same string, because both pointers move the same way.
;    - A backward copy is what avoids corruption when two blocks overlap.
;    - Reversing a string needs the two pointers moving in opposite directions instead.
; 2. The flag is global:
;    - Nothing resets it at a procedure boundary, so it survives a call and a return.
;    - DOS and the BIOS both assume it is clear when they are entered.
;    - A routine that sets it and returns has left a trap for everything after it.
; 3. Where the pointer ends up:
;    - After a forward copy SI is one past the last byte read.
;    - After a backward one it is one before the first, which can wrap below zero.
;    - Either way it is left ready for the next element, which is what makes REP work.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
