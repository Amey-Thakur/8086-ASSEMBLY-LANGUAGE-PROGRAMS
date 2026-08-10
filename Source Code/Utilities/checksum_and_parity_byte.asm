; =============================================================================
; TITLE: A Checksum And A Parity Byte For A Block
; DESCRIPTION: Builds the two guards a serial link relies on, a modulo 256
;              checksum and a longitudinal parity byte, then alters one byte
;              and shows both of them reject the block.
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
    BLOCK   DB 17, 42, 200, 91, 6, 255, 128, 64, 33, 7, 19, 250
    SPAN    EQU $ - BLOCK               ; Measured, never counted by hand
    FRAME   DB 13 DUP(0)                ; The block with its checksum appended
    GUARD   DB 0                        ; The checksum byte once it is known

    M_TITLE DB 'A checksum and a parity byte over twelve bytes'
            DB 0DH, 0AH, 0DH, 0AH, '$'
    M_BYTES DB 'Block:   $'
    M_TOTAL DB 'Total of the bytes:      $'
    M_MOD   DB 'Total modulo 256:        $'
    M_GUARD DB 'Checksum byte:           $'
    M_PAR   DB 'Longitudinal parity:     $'
    M_FRAME DB 0DH, 0AH
            DB 'The frame is the block with the checksum on the end, so the '
            DB 'thirteen bytes must now total a multiple of 256.', 0DH, 0AH, '$'
    M_RES1  DB 'Residue over the frame:  $'
    M_OK    DB '   the frame is accepted$'
    M_ALTER DB 0DH, 0AH, 'One byte is altered from 200 to 201.', 0DH, 0AH, '$'
    M_RES2  DB 'Residue over the frame:  $'
    M_BAD   DB '   the frame is rejected$'
    M_PAR2  DB 'Parity byte now:         $'
    M_SPACE DB ' $'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA DX, M_TITLE
    CALL PRINT_MESSAGE

    LEA DX, M_BYTES
    CALL PRINT_MESSAGE
    LEA SI, BLOCK
    MOV CX, SPAN
    CALL SHOW_BYTES

    ; -------------------------------------------------------------------------
    ; THE TOTAL IS KEPT IN A WORD. TWELVE BYTES CAN REACH 3060, WHICH A BYTE
    ; COULD NOT HOLD, AND THE CHECKSUM WANTS THE LOW EIGHT BITS OF THE TRUE
    ; TOTAL RATHER THAN OF A TOTAL THAT HAS ALREADY WRAPPED.
    ; -------------------------------------------------------------------------
    LEA SI, BLOCK
    MOV CX, SPAN
    CALL SUM_BYTES
    PUSH AX                             ; The total is wanted twice

    LEA DX, M_TOTAL
    CALL PRINT_MESSAGE
    CALL PRINT_DECIMAL
    CALL NEWLINE

    POP AX
    AND AX, 0FFH                        ; The residue modulo 256
    PUSH AX

    LEA DX, M_MOD
    CALL PRINT_MESSAGE
    CALL PRINT_DECIMAL
    CALL NEWLINE

    ; -------------------------------------------------------------------------
    ; THE CHECKSUM IS THE BYTE THAT BRINGS THE TOTAL TO A MULTIPLE OF 256,
    ; WHICH IS THE TWO'S COMPLEMENT OF THE RESIDUE. NEG ON A BYTE PRODUCES IT
    ; DIRECTLY, AND GIVES ZERO WHEN THE RESIDUE IS ALREADY ZERO.
    ; -------------------------------------------------------------------------
    POP AX
    NEG AL
    XOR AH, AH
    MOV GUARD, AL

    LEA DX, M_GUARD
    CALL PRINT_MESSAGE
    CALL PRINT_DECIMAL
    CALL NEWLINE

    LEA SI, BLOCK
    MOV CX, SPAN
    CALL XOR_BYTES
    LEA DX, M_PAR
    CALL PRINT_MESSAGE
    CALL PRINT_HEX
    CALL NEWLINE

    ; -------------------------------------------------------------------------
    ; BUILD THE FRAME, THEN VERIFY IT THE WAY A RECEIVER WOULD: ADD EVERY BYTE
    ; INCLUDING THE CHECKSUM AND EXPECT NOTHING LEFT OVER.
    ; -------------------------------------------------------------------------
    LEA DX, M_FRAME
    CALL PRINT_MESSAGE

    LEA SI, BLOCK
    LEA DI, FRAME
    MOV CX, SPAN

COPY_ONE:
    MOV AL, [SI]
    MOV [DI], AL
    INC SI
    INC DI
    LOOP COPY_ONE

    MOV AL, GUARD
    MOV [DI], AL                        ; DI now sits one past the copied bytes

    LEA SI, FRAME
    MOV CX, SPAN
    INC CX                              ; The checksum byte counts as well
    CALL SUM_BYTES
    AND AX, 0FFH

    LEA DX, M_RES1
    CALL PRINT_MESSAGE
    CALL PRINT_DECIMAL
    LEA DX, M_OK
    CALL PRINT_MESSAGE
    CALL NEWLINE

    ; -------------------------------------------------------------------------
    ; ALTER ONE BYTE AND VERIFY AGAIN. A SINGLE BYTE CHANGED BY ONE SHIFTS THE
    ; RESIDUE BY ONE, SO THE FRAME NO LONGER ADDS UP.
    ; -------------------------------------------------------------------------
    LEA DX, M_ALTER
    CALL PRINT_MESSAGE

    LEA SI, FRAME
    INC BYTE PTR [SI+2]

    MOV CX, SPAN
    INC CX
    CALL SUM_BYTES
    AND AX, 0FFH

    LEA DX, M_RES2
    CALL PRINT_MESSAGE
    CALL PRINT_DECIMAL
    LEA DX, M_BAD
    CALL PRINT_MESSAGE
    CALL NEWLINE

    LEA SI, FRAME
    MOV CX, SPAN
    CALL XOR_BYTES
    LEA DX, M_PAR2
    CALL PRINT_MESSAGE
    CALL PRINT_HEX
    CALL NEWLINE

    MOV AH, 4CH
    INT 21H

; -----------------------------------------------------------------------------
; SUM_BYTES
;
; Adds the CX bytes at DS:SI and returns the total in AX.
;
; Each byte is widened before it is added. Adding AL alone would leave whatever
; happened to be in AH sitting in the running total.
; -----------------------------------------------------------------------------
SUM_BYTES PROC
    PUSH BX
    PUSH CX
    PUSH SI

    XOR BX, BX                          ; The running total
    JCXZ SB_DONE                        ; A count of zero would loop 65536 times

SB_LOOP:
    MOV AL, [SI]
    XOR AH, AH
    ADD BX, AX
    INC SI
    LOOP SB_LOOP

SB_DONE:
    MOV AX, BX

    POP SI
    POP CX
    POP BX
    RET
SUM_BYTES ENDP

; -----------------------------------------------------------------------------
; XOR_BYTES
;
; Returns the exclusive or of the CX bytes at DS:SI in AX, the high half zero.
; This is the longitudinal parity of the block: bit by bit it records whether
; each column held an even or an odd number of ones.
; -----------------------------------------------------------------------------
XOR_BYTES PROC
    PUSH BX
    PUSH CX
    PUSH SI

    XOR BX, BX
    JCXZ XB_DONE

XB_LOOP:
    MOV AL, [SI]
    XOR BL, AL
    INC SI
    LOOP XB_LOOP

XB_DONE:
    MOV AL, BL
    XOR AH, AH

    POP SI
    POP CX
    POP BX
    RET
XOR_BYTES ENDP

; -----------------------------------------------------------------------------
; SHOW_BYTES
;
; Prints the CX bytes at DS:SI as decimal numbers, then a newline.
; -----------------------------------------------------------------------------
SHOW_BYTES PROC
    PUSH AX
    PUSH CX
    PUSH DX
    PUSH SI

    JCXZ SH_DONE

SH_LOOP:
    MOV AL, [SI]
    XOR AH, AH
    CALL PRINT_DECIMAL
    LEA DX, M_SPACE
    CALL PRINT_MESSAGE
    INC SI
    LOOP SH_LOOP

SH_DONE:
    CALL NEWLINE

    POP SI
    POP DX
    POP CX
    POP AX
    RET
SHOW_BYTES ENDP

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
; 1. WHY THE CHECKSUM IS A NEGATION:
;    - Appending the two's complement of the residue makes the whole frame
;    - total a multiple of 256, so the receiver adds everything up and only
;    - has to test the low byte against zero.
; 2. WHAT THE PARITY BYTE ADDS:
;    - The checksum reports the total, the parity byte reports each bit
;    - column separately. Two errors that cancel in the sum, such as one
;    - byte up by five and another down by five, still disturb the parity.
; 3. WHAT NEITHER OF THEM CATCHES:
;    - Reordering. Both are built from operations that do not care about
;    - position, so two swapped bytes leave the sum and the parity alike.
;    - A cyclic redundancy check feeds position in and does catch it.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
