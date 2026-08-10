; =============================================================================
; TITLE: Switching a Bank of Relays
; DESCRIPTION: Turns individual relays on and off without disturbing the
;              others, which is the read, modify, write pattern.
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
    RELAYS  EQU 5
    STATE   DB 0                        ; What the port currently holds

    M_STEP  DB 'relays now: $'
    M_PUMP  DB '   pump on', 0DH, 0AH, '$'
    M_FAN   DB '   fan on', 0DH, 0AH, '$'
    M_NOFAN DB '   fan off', 0DH, 0AH, '$'
    M_ALARM DB '   alarm on', 0DH, 0AH, '$'
    M_ALL   DB '   everything off', 0DH, 0AH, '$'

    PUMP    EQU 00000001B
    FAN     EQU 00000010B
    ALARM   EQU 00000100B

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    ; -------------------------------------------------------------------------
    ; A PORT LATCH CANNOT USUALLY BE READ BACK, SO THE PROGRAM KEEPS ITS OWN
    ; COPY OF WHAT IT LAST WROTE. TURNING ONE RELAY ON MEANS OR-ING ITS BIT
    ; INTO THAT COPY AND SENDING THE WHOLE BYTE, WHICH IS WHY THE COPY HAS TO
    ; BE KEPT: WRITING THE BIT ALONE WOULD SWITCH EVERYTHING ELSE OFF.
    ; -------------------------------------------------------------------------
    MOV AL, PUMP
    CALL TURN_ON
    LEA DX, M_PUMP
    CALL ANNOUNCE

    MOV AL, FAN
    CALL TURN_ON
    LEA DX, M_FAN
    CALL ANNOUNCE

    MOV AL, ALARM
    CALL TURN_ON
    LEA DX, M_ALARM
    CALL ANNOUNCE

    ; Only the fan goes off; the pump and the alarm stay as they are
    MOV AL, FAN
    CALL TURN_OFF
    LEA DX, M_NOFAN
    CALL ANNOUNCE

    ; Everything off, in one write
    MOV BYTE PTR STATE, 0
    MOV AL, 0
    OUT RELAYS, AL
    LEA DX, M_ALL
    CALL ANNOUNCE

    MOV AX, 4C00H
    INT 21H

; -----------------------------------------------------------------------------
; TURN_ON
;
; Sets the bits in AL without disturbing any others.
; -----------------------------------------------------------------------------
TURN_ON PROC
    OR  STATE, AL
    MOV AL, STATE
    OUT RELAYS, AL
    RET
TURN_ON ENDP

; -----------------------------------------------------------------------------
; TURN_OFF
;
; Clears the bits in AL, again leaving the rest alone. The mask has to be
; complemented, because AND keeps what is set rather than clearing it.
; -----------------------------------------------------------------------------
TURN_OFF PROC
    NOT AL
    AND STATE, AL
    MOV AL, STATE
    OUT RELAYS, AL
    RET
TURN_OFF ENDP

; -----------------------------------------------------------------------------
; ANNOUNCE
;
; Shows the port value and the message at DS:DX.
; -----------------------------------------------------------------------------
ANNOUNCE PROC
    PUSH AX
    PUSH DX

    PUSH DX
    LEA DX, M_STEP
    MOV AH, 09H
    INT 21H
    MOV AL, STATE
    CALL SHOW_BITS
    POP DX

    MOV AH, 09H
    INT 21H

    POP DX
    POP AX
    RET
ANNOUNCE ENDP

; -----------------------------------------------------------------------------
; SHOW_BITS
;
; Prints AL as eight ones and zeros, most significant first. A port value is
; a set of independent lines rather than a number, so binary is the form that
; says what it means.
; -----------------------------------------------------------------------------
SHOW_BITS PROC
    PUSH AX
    PUSH CX
    PUSH DX

    MOV CX, 8

SB_LOOP:
    SHL AL, 1
    MOV DL, '0'
    JNC SB_EMIT
    MOV DL, '1'

SB_EMIT:
    PUSH AX
    MOV AH, 02H
    INT 21H
    POP AX
    LOOP SB_LOOP

    POP DX
    POP CX
    POP AX
    RET
SHOW_BITS ENDP

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
; 1. WRITE THE WHOLE BYTE, ALWAYS:
;    - A port takes eight lines at once. Sending only the bit that changed
;    - clears the other seven, which switches off every relay that was on.
; 2. OR TO SET, AND NOT TO CLEAR:
;    - The two operations are not symmetric. Setting is OR with the mask;
;    - clearing is AND with its complement, and forgetting the NOT clears
;    - everything except the bit that was meant to go.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
