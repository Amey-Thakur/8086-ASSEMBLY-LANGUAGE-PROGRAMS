; =============================================================================
; TITLE: String Addressing Mode
; DESCRIPTION: The string instructions take no operands at all: the source and destination registers are implied and stepped for you.
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
    SOURCE  DB 'ADDRESSING'
    SPAN  EQU $ - SOURCE
    TARGET  DB SPAN DUP ('?')
    REVERSE DB SPAN DUP ('?')

    M_TITLE DB 'String addressing: DS:SI to ES:DI, with no operands', 0DH, 0AH, '$'
    M_FROM  DB 'Source:   $'
    M_TO    DB 'Copied:   $'
    M_BACK  DB 'Backwards: $'
    M_LODS  DB 'LODSB then STOSB does the same work one byte at a time.', 0DH, 0AH, '$'
    M_FLAG  DB 'CLD counts up, STD counts down. Leave the flag clear.', 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX
    MOV ES, AX                          ; The destination segment for STOS

    LEA DX, M_TITLE

    CALL PRINT_MESSAGE

    LEA DX, M_FROM

    CALL PRINT_MESSAGE
    LEA SI, SOURCE
    MOV CX, SPAN
    CALL PRINT_TEXT
    CALL NEWLINE

    ; -------------------------------------------------------------------------
    ; REP MOVSB IS THE WHOLE COPY. SI, DI AND CX ARE NOT NAMED BY THE
    ; INSTRUCTION BUT ARE ALL USED AND ALL UPDATED, WHICH IS WHY THEY MUST BE
    ; SET UP FIRST AND WHY THE DIRECTION FLAG MATTERS.
    ; -------------------------------------------------------------------------
    CLD                                 ; Count upwards
    LEA SI, SOURCE
    LEA DI, TARGET
    MOV CX, SPAN
    REP MOVSB

    LEA DX, M_TO

    CALL PRINT_MESSAGE
    LEA SI, TARGET
    MOV CX, SPAN
    CALL PRINT_TEXT
    CALL NEWLINE

    ; -------------------------------------------------------------------------
    ; LODSB AND STOSB SPLIT THE MOVE IN TWO, WHICH LETS SOMETHING HAPPEN IN
    ; BETWEEN. HERE THE DESTINATION WALKS BACKWARDS WHILE THE SOURCE WALKS
    ; FORWARDS, SO THE COPY COMES OUT REVERSED.
    ; -------------------------------------------------------------------------
    LEA SI, SOURCE
    LEA DI, REVERSE
    ADD DI, SPAN
    DEC DI                              ; Aim at the last byte of the target
    MOV CX, SPAN

REVERSE_ONE:
    CLD
    LODSB                               ; AL = DS:[SI], then SI = SI + 1
    STD
    STOSB                               ; ES:[DI] = AL, then DI = DI - 1
    LOOP REVERSE_ONE
    CLD                                 ; Always leave the flag clear

    LEA DX, M_BACK

    CALL PRINT_MESSAGE
    LEA SI, REVERSE
    MOV CX, SPAN
    CALL PRINT_TEXT
    CALL NEWLINE
    CALL NEWLINE

    LEA DX, M_LODS

    CALL PRINT_MESSAGE
    LEA DX, M_FLAG
    CALL PRINT_MESSAGE

    MOV AH, 4CH
    INT 21H

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
; 1. Implied operands:
;    - MOVSB reads DS:[SI], writes ES:[DI], and steps both.
;    - LODSB loads into AL and STOSB stores from AL, each stepping its own register.
;    - SCASB compares AL against ES:[DI], which is why a search uses the destination register.
; 2. The direction flag decides the step:
;    - CLD clears it and both registers count up; STD sets it and they count down.
;    - The flag is global, so a procedure that sets it must clear it again.
;    - DOS and the BIOS assume it is clear on entry.
; 3. ES must be set:
;    - The destination always goes through ES, with no way to override it on a string move.
;    - A program that forgets MOV ES, AX writes into whatever segment the loader left there.
;    - Both registers point at the same segment here, which is the common case in a small model.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
