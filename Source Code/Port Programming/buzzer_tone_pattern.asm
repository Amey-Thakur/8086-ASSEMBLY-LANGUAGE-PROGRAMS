; =============================================================================
; TITLE: Sounding a Buzzer in Patterns
; DESCRIPTION: Drives a buzzer line on and off to produce distinguishable
;              alarm patterns rather than one continuous noise.
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
    BUZZER  EQU 97                      ; The speaker control port

    ; Each pattern is a run of on and off periods, ending with a zero length.
    ; Keeping them as data means a new alarm is a new table rather than new
    ; code, which is what an installer can be given.
    SHORT_  DB 2, 2, 2, 2, 2, 2, 0
    LONG_   DB 8, 4, 8, 4, 0
    URGENT  DB 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0

    M_SHORT DB 'Three short: $'
    M_LONG  DB 0DH, 0AH, 'Two long:    $'
    M_URG   DB 0DH, 0AH, 'Urgent:      $'
    CRLF    DB 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA DX, M_SHORT
    MOV AH, 09H
    INT 21H
    LEA SI, SHORT_
    CALL SOUND_PATTERN

    LEA DX, M_LONG
    MOV AH, 09H
    INT 21H
    LEA SI, LONG_
    CALL SOUND_PATTERN

    LEA DX, M_URG
    MOV AH, 09H
    INT 21H
    LEA SI, URGENT
    CALL SOUND_PATTERN

    LEA DX, CRLF
    MOV AH, 09H
    INT 21H

    ; Silence
    MOV AL, 0
    OUT BUZZER, AL

    MOV AX, 4C00H
    INT 21H

; -----------------------------------------------------------------------------
; SOUND_PATTERN
;
; Walks the table at DS:SI, alternating the buzzer on and off for the number
; of periods each entry gives, and draws what it is doing.
; -----------------------------------------------------------------------------
SOUND_PATTERN PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI

    MOV BL, 1                           ; The first period is a sound

SP_ENTRY:
    MOV CL, [SI]
    OR  CL, CL
    JZ  SP_DONE                          ; A zero length ends the pattern

    XOR CH, CH

    ; -------------------------------------------------------------------------
    ; THE BUZZER LINE IS SET FOR THE WHOLE OF A SOUNDING PERIOD AND CLEARED
    ; FOR THE WHOLE OF A SILENT ONE. ONE WRITE PER PERIOD IS ENOUGH; WRITING
    ; INSIDE THE LOOP WOULD BE THE SAME VALUE OVER AND OVER.
    ; -------------------------------------------------------------------------
    MOV AL, BL
    OUT BUZZER, AL

SP_PERIOD:
    MOV DL, '.'
    OR  BL, BL
    JZ  SP_EMIT
    MOV DL, '#'

SP_EMIT:
    PUSH CX
    MOV AH, 02H
    INT 21H
    POP CX
    LOOP SP_PERIOD

    XOR BL, 1                           ; Alternate sound and silence
    INC SI
    JMP SP_ENTRY

SP_DONE:
    MOV AL, 0
    OUT BUZZER, AL

    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
SOUND_PATTERN ENDP

END START

; =============================================================================
; TECHNICAL NOTES
; =============================================================================
; 1. ALTERNATING WITH ONE XOR:
;    - XOR BL, 1 flips between sounding and silent, so the table holds
;    - only the lengths and never has to say which is which.
; 2. A ZERO LENGTH ENDS IT:
;    - Which means no separate count has to be stored or kept in step
;    - with the table. It is the same convention as a string terminator.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
