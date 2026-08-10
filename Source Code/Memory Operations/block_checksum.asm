; =============================================================================
; TITLE: Checksum Over A Memory Block
; DESCRIPTION: Adds a block of bytes into a sixteen bit total, derives the one
;              byte checksum that drives the low half of that total to zero,
;              and shows the check failing after a single byte is disturbed.
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
    PAYLOAD DB 12H, 34H, 56H, 78H, 9AH, 0BCH, 0DEH, 0F0H
    CHECK_B DB 0                         ; The checksum rides at the end of the frame
    FRAME_W EQU $ - PAYLOAD              ; Payload and checksum together
    HOWMANY EQU FRAME_W - 1              ; The payload on its own

    M_TOTAL DB 'Payload total, all sixteen bits:   $'
    M_LOW   DB 'Low byte of that total:            $'
    M_CHECK DB 'Checksum byte written:             $'
    M_OPEN  DB ' which is $'
    M_FRAME DB 'Frame total with the checksum:     $'
    M_NOW   DB 'Low byte of the frame total:       $'
    M_BENT  DB 'One payload byte altered, low byte: $'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    ; -------------------------------------------------------------------------
    ; THE RUNNING TOTAL IS KEPT SIXTEEN BITS WIDE EVEN THOUGH THE CHECKSUM IS
    ; ONLY EIGHT, BECAUSE THE WIDER TOTAL SHOWS HOW MUCH WAS DISCARDED. EIGHT
    ; BYTES CANNOT CARRY IT PAST 2040, SO NOTHING WRAPS.
    ; -------------------------------------------------------------------------
    LEA SI, PAYLOAD
    MOV CX, HOWMANY
    CALL SUM_BYTES
    MOV BP, AX                          ; Out of AX before any message goes out

    LEA DX, M_TOTAL
    CALL PRINT_MESSAGE
    MOV AX, BP
    CALL PRINT_DECIMAL
    CALL NEWLINE

    ; A checksum is only as wide as the field that carries it, so everything
    ; above the bottom eight bits is thrown away here on purpose.
    MOV AX, BP
    AND AX, 00FFH
    MOV DI, AX

    LEA DX, M_LOW
    CALL PRINT_MESSAGE
    MOV AX, DI
    CALL PRINT_DECIMAL
    CALL NEWLINE

    ; -------------------------------------------------------------------------
    ; THE CHECKSUM IS WHATEVER HAS TO BE ADDED TO MAKE THE LOW BYTE COME OUT AT
    ; ZERO, WHICH IS THE TWO'S COMPLEMENT OF THE SUM. NEG ON AL ALONE LEAVES AH
    ; AT ZERO, SO AX IS ALREADY THE VALUE TO PRINT.
    ; -------------------------------------------------------------------------
    MOV AX, DI
    NEG AL
    MOV CHECK_B, AL

    LEA DX, M_CHECK
    CALL PRINT_MESSAGE
    CALL PRINT_DECIMAL
    LEA DX, M_OPEN
    CALL PRINT_MESSAGE
    CALL PRINT_HEX
    CALL NEWLINE

    ; -------------------------------------------------------------------------
    ; WITH THE CHECKSUM IN PLACE THE WHOLE FRAME ADDS UP TO A MULTIPLE OF 256,
    ; SO ITS LOW BYTE IS ZERO. THAT SINGLE TEST IS ALL A RECEIVER PERFORMS.
    ; -------------------------------------------------------------------------
    LEA SI, PAYLOAD
    MOV CX, FRAME_W
    CALL SUM_BYTES
    MOV BP, AX

    LEA DX, M_FRAME
    CALL PRINT_MESSAGE
    MOV AX, BP
    CALL PRINT_DECIMAL
    CALL NEWLINE

    LEA DX, M_NOW
    CALL PRINT_MESSAGE
    MOV AX, BP
    AND AX, 00FFH
    CALL PRINT_DECIMAL
    CALL NEWLINE

    ; Disturbing one payload byte by one raises the total by one, so the low
    ; byte stops being zero and the frame is rejected.
    INC PAYLOAD

    LEA SI, PAYLOAD
    MOV CX, FRAME_W
    CALL SUM_BYTES
    AND AX, 00FFH
    MOV BP, AX

    LEA DX, M_BENT
    CALL PRINT_MESSAGE
    MOV AX, BP
    CALL PRINT_DECIMAL
    CALL NEWLINE

    MOV AH, 4CH
    INT 21H

; -----------------------------------------------------------------------------
; SUM_BYTES
;
; Adds CX bytes starting at DS:SI and returns the total in AX. Each byte is
; widened to a word before it is added, because adding a byte into AL alone
; would throw the carry away and give the eight bit sum only.
; -----------------------------------------------------------------------------
SUM_BYTES PROC
    PUSH BX
    PUSH CX
    PUSH SI

    XOR AX, AX
    JCXZ SB_DONE                        ; An empty block sums to nothing

SB_NEXT:
    MOV BL, [SI]
    XOR BH, BH
    ADD AX, BX
    INC SI
    LOOP SB_NEXT

SB_DONE:
    POP SI
    POP CX
    POP BX
    RET
SUM_BYTES ENDP

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
; 1. Why the sum is kept wider than the checksum:
;    - Eight bytes can total 2040, which needs eleven bits to hold.
;    - Adding into AL alone would drop every carry and hide the true total.
;    - The narrowing to one byte is then done once, deliberately, at the end.
; 2. Why the two's complement:
;    - The checksum has to make the low byte of the total come out at zero.
;    - Zero less the sum, taken modulo 256, is exactly what NEG produces.
;    - The receiver then adds everything up and looks for a low byte of zero.
; 3. What this checksum cannot catch:
;    - Two errors that cancel, such as one byte up by one and another down by one.
;    - Bytes rearranged, because addition does not care about their order.
;    - A cyclic redundancy check is the usual answer where those matter.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
