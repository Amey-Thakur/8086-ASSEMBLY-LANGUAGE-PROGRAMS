; =============================================================================
; TITLE: Driving A Bank Of Relays
; DESCRIPTION: Eight relays on one port, switched individually without disturbing the other seven.
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
    RELAY_PORT EQU 7

    ; The program keeps its own copy of what it last wrote, because an output
    ; port cannot be read back on most hardware and reading it here would be a
    ; habit that does not transfer.
    SHADOW_B DB 0

    ; A short sequence of commands: which relay, and what to do with it.
    ; 0 close, 1 open, 2 toggle.
    WHICH   DB 0, 3, 5, 3, 7, 0, 5, 7
    ACTION  DB 0, 0, 0, 1, 0, 2, 2, 1
    HOWMANY EQU 8

    M_TITLE DB 'Eight relays on one port, switched one at a time', 0DH, 0AH, '$'
    M_HEAD  DB 0DH, 0AH, 'relay  action   port value  relays closed', 0DH, 0AH, '$'
    M_CLOSE DB 'close    $'
    M_OPEN  DB 'open     $'
    M_TOG   DB 'toggle   $'
    M_GAP   DB '   $'
    M_GAP2  DB '        $'
    M_ON    DB '1$'
    M_OFF   DB '.$'
    M_FINAL DB 0DH, 0AH, 'Relays left closed: $'
    M_WHY   DB 0DH, 0AH
            DB 'Every change is a read of the shadow, one logical operation, and '
            DB 'one write. Writing the bit alone would open the other seven.'
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
    LEA DX, M_HEAD
    CALL PRINT_MESSAGE

    XOR SI, SI
    MOV CX, HOWMANY

EACH_COMMAND:
    PUSH CX

    ; ---- which relay --------------------------------------------------------
    MOV BL, WHICH[SI]
    XOR BH, BH
    MOV AX, BX
    CALL PRINT_DECIMAL
    LEA DX, M_GAP
    CALL PRINT_MESSAGE

    ; ---- build the mask for that one bit ------------------------------------
    MOV CL, BL
    MOV AL, 1
    SHL AL, CL
    MOV BH, AL                          ; The mask

    ; ---- and apply the action ----------------------------------------------
    MOV BL, ACTION[SI]

    CMP BL, 0
    JNE TRY_OPEN
    LEA DX, M_CLOSE
    CALL PRINT_MESSAGE
    MOV AL, SHADOW_B
    OR AL, BH                           ; Closing is an OR
    JMP APPLY

TRY_OPEN:
    CMP BL, 1
    JNE DO_TOGGLE
    LEA DX, M_OPEN
    CALL PRINT_MESSAGE
    MOV AL, BH
    NOT AL
    AND AL, SHADOW_B                    ; Opening is an AND with the complement
    JMP APPLY

DO_TOGGLE:
    LEA DX, M_TOG
    CALL PRINT_MESSAGE
    MOV AL, SHADOW_B
    XOR AL, BH                          ; Toggling is an XOR

APPLY:
    MOV SHADOW_B, AL
    OUT RELAY_PORT, AL

    XOR AH, AH
    CALL PRINT_DECIMAL
    LEA DX, M_GAP2
    CALL PRINT_MESSAGE

    CALL SHOW_RELAYS
    CALL NEWLINE

    INC SI
    POP CX
    LOOP EACH_COMMAND

    LEA DX, M_FINAL
    CALL PRINT_MESSAGE
    MOV AL, SHADOW_B
    XOR AH, AH
    CALL COUNT_BITS
    CALL PRINT_DECIMAL

    LEA DX, M_WHY
    CALL PRINT_MESSAGE

    MOV AH, 4CH
    INT 21H

; -----------------------------------------------------------------------------
; SHOW_RELAYS
;
; Prints the eight relays, lowest numbered first, as a one or a dot.
; -----------------------------------------------------------------------------
SHOW_RELAYS PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX

    MOV BL, SHADOW_B
    MOV CX, 8

EACH_RELAY:
    TEST BL, 1
    JZ RELAY_OPEN

    LEA DX, M_ON
    CALL PRINT_MESSAGE
    JMP RELAY_NEXT

RELAY_OPEN:
    LEA DX, M_OFF
    CALL PRINT_MESSAGE

RELAY_NEXT:
    SHR BL, 1
    LOOP EACH_RELAY

    POP DX
    POP CX
    POP BX
    POP AX
    RET
SHOW_RELAYS ENDP

; -----------------------------------------------------------------------------
; COUNT_BITS
;
; How many bits are set in AX, by clearing the lowest each time.
; -----------------------------------------------------------------------------
COUNT_BITS PROC
    PUSH BX
    PUSH CX

    XOR CX, CX

BITS_AGAIN:
    CMP AX, 0
    JE BITS_DONE
    MOV BX, AX
    DEC BX
    AND AX, BX
    INC CX
    JMP BITS_AGAIN

BITS_DONE:
    MOV AX, CX

    POP CX
    POP BX
    RET
COUNT_BITS ENDP

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
; 1. Keep a shadow of the port:
;    - Most output ports cannot be read back, so the program must remember what it wrote.
;    - Every change reads the shadow, alters one bit, and writes the whole byte.
;    - Writing only the wanted bit would drive the other seven to zero.
; 2. Three operations, three instructions:
;    - Closing a relay is OR with the mask, opening is AND with its complement.
;    - Toggling is XOR, which needs no knowledge of the current state at all.
;    - The mask itself is one shifted left by the relay number.
; 3. Relays are not lamps:
;    - A relay takes milliseconds to move, so a fast toggle may never actually switch.
;    - Real drivers therefore rate limit changes and often refuse to reverse instantly.
;    - The logic here is right; the timing would need adding for real hardware.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
