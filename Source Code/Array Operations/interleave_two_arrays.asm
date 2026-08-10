; =============================================================================
; TITLE: Interleaving Two Arrays
; DESCRIPTION: Builds one array by taking alternately from two others, and then
;              separates them again.
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
    ODDS    DW 1, 3, 5, 7
    EVENS   DW 2, 4, 6, 8
    EACH    EQU 4

    MERGED  DW EACH * 2 DUP(0)
    BACK_A  DW EACH DUP(0)
    BACK_B  DW EACH DUP(0)

    M_ODDS  DB 'Odds:       $'
    M_EVENS DB 'Evens:      $'
    M_MIX   DB 'Interleaved: $'
    M_A     DB 'Separated A: $'
    M_B     DB 'Separated B: $'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA DX, M_ODDS
    MOV AH, 09H
    INT 21H
    LEA SI, ODDS
    MOV CX, EACH
    CALL SHOW_RUN

    LEA DX, M_EVENS
    MOV AH, 09H
    INT 21H
    LEA SI, EVENS
    MOV CX, EACH
    CALL SHOW_RUN

    ; -------------------------------------------------------------------------
    ; THREE POINTERS AGAIN, BUT THE DESTINATION ADVANCES TWICE AS FAST AS
    ; EITHER SOURCE. THAT IS THE WHOLE OF INTERLEAVING, AND IT IS HOW STEREO
    ; AUDIO SAMPLES ARE STORED.
    ; -------------------------------------------------------------------------
    LEA SI, ODDS
    LEA DI, EVENS
    LEA BX, MERGED
    MOV CX, EACH

WEAVE:
    MOV AX, [SI]
    MOV [BX], AX
    ADD BX, 2

    MOV AX, [DI]
    MOV [BX], AX
    ADD BX, 2

    ADD SI, 2
    ADD DI, 2
    LOOP WEAVE

    LEA DX, M_MIX
    MOV AH, 09H
    INT 21H
    LEA SI, MERGED
    MOV CX, EACH * 2
    CALL SHOW_RUN

    ; -------------------------------------------------------------------------
    ; SEPARATING IS THE SAME LOOP READ THE OTHER WAY: THE SOURCE ADVANCES
    ; TWICE PER PASS AND EACH DESTINATION ONCE.
    ; -------------------------------------------------------------------------
    LEA SI, MERGED
    LEA DI, BACK_A
    LEA BX, BACK_B
    MOV CX, EACH

UNWEAVE:
    MOV AX, [SI]
    MOV [DI], AX
    ADD SI, 2
    ADD DI, 2

    MOV AX, [SI]
    MOV [BX], AX
    ADD SI, 2
    ADD BX, 2

    LOOP UNWEAVE

    LEA DX, M_A
    MOV AH, 09H
    INT 21H
    LEA SI, BACK_A
    MOV CX, EACH
    CALL SHOW_RUN

    LEA DX, M_B
    MOV AH, 09H
    INT 21H
    LEA SI, BACK_B
    MOV CX, EACH
    CALL SHOW_RUN

    MOV AX, 4C00H
    INT 21H

; -----------------------------------------------------------------------------
; SHOW_RUN
;
; Prints CX words starting at DS:SI, then a newline.
; -----------------------------------------------------------------------------
SHOW_RUN PROC
    PUSH AX
    PUSH CX
    PUSH DX
    PUSH SI

    JCXZ SR_DONE

SR_LOOP:
    MOV AX, [SI]
    PUSH CX
    PUSH SI
    CALL PRINT_SIGNED
    MOV DL, ' '
    MOV AH, 02H
    INT 21H
    POP SI
    POP CX

    ADD SI, 2
    LOOP SR_LOOP

SR_DONE:
    CALL NEWLINE

    POP SI
    POP DX
    POP CX
    POP AX
    RET
SHOW_RUN ENDP

; -----------------------------------------------------------------------------
; PRINT_SIGNED
;
; Prints AX as a signed value, with a minus sign when it is negative.
; -----------------------------------------------------------------------------
PRINT_SIGNED PROC
    PUSH AX
    PUSH DX

    OR  AX, AX
    JNS PS_POSITIVE                     ; Sign flag clear means not negative

    PUSH AX
    MOV DL, '-'
    MOV AH, 02H
    INT 21H
    POP AX
    NEG AX                              ; Print the magnitude

PS_POSITIVE:
    CALL PRINT_DECIMAL

    POP DX
    POP AX
    RET
PRINT_SIGNED ENDP

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
; 1. THE DESTINATION MOVES TWICE AS FAST:
;    - Which is the only thing that distinguishes interleaving from
;    - copying. Both sources are read once per pass and the output is
;    - written twice.
; 2. WHY IT MATTERS:
;    - Interleaved data is one contiguous read rather than two, which on
;    - any machine with a cache or a disk is considerably faster. It is
;    - why audio, video and vertex data are all stored this way.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
