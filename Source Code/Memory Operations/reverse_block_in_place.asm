; =============================================================================
; TITLE: Reverse A Block In Place
; DESCRIPTION: Turns a block of bytes end for end without a second buffer, by
;              walking one pointer up and one pointer down and exchanging the
;              pair they meet on until the two of them collide.
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
    TEXT_B  DB 'MEMORY OPERATIONS'
    SPAN    EQU $ - TEXT_B               ; Measured, never counted by hand
    HALVES  DW 0                         ; How many exchanges the walk will need
    MIDDLE  DW 0                         ; Where the two pointers finally met

    M_BEFORE DB 'Before: $'
    M_AFTER  DB 'After:  $'
    M_SPAN   DB 'Bytes in the block: $'
    M_SWAPS  DB 'Exchanges made:     $'
    M_MID    DB 'The count is odd, so one byte never moved: $'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA DX, M_BEFORE
    CALL PRINT_MESSAGE
    LEA SI, TEXT_B
    MOV CX, SPAN
    CALL PRINT_TEXT
    CALL NEWLINE

    ; -------------------------------------------------------------------------
    ; A BLOCK OF N BYTES NEEDS N HALVED EXCHANGES. THE HALVING THROWS AWAY THE
    ; REMAINDER, AND THAT IS EXACTLY WHAT LEAVES THE MIDDLE BYTE OF AN ODD
    ; BLOCK ALONE: IT IS ALREADY IN ITS FINAL PLACE.
    ; -------------------------------------------------------------------------
    MOV AX, SPAN
    SHR AX, 1
    MOV HALVES, AX

    LEA SI, TEXT_B                      ; Climbs from the first byte
    LEA DI, TEXT_B
    ADD DI, SPAN - 1                    ; Descends from the last

    MOV CX, HALVES
    JCXZ REVERSED                       ; A block of one byte is already reversed

SWAP_ENDS:
    ; The 8086 has no memory to memory move, so the two bytes are lifted into
    ; the halves of one register and put back the other way round.
    MOV AL, [SI]
    MOV AH, [DI]
    MOV [SI], AH
    MOV [DI], AL

    INC SI
    DEC DI
    LOOP SWAP_ENDS

REVERSED:
    LEA DX, M_AFTER
    CALL PRINT_MESSAGE
    LEA SI, TEXT_B
    MOV CX, SPAN
    CALL PRINT_TEXT
    CALL NEWLINE

    LEA DX, M_SPAN
    CALL PRINT_MESSAGE
    MOV AX, SPAN
    CALL PRINT_DECIMAL
    CALL NEWLINE

    LEA DX, M_SWAPS
    CALL PRINT_MESSAGE
    MOV AX, HALVES
    CALL PRINT_DECIMAL
    CALL NEWLINE

    ; SI and DI have met, and on an odd count they met on the same byte. Showing
    ; that byte proves the walk stopped where the arithmetic said it would.
    LEA DX, M_MID
    CALL PRINT_MESSAGE
    MOV DL, [SI]
    MOV AH, 02H
    INT 21H
    CALL NEWLINE

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
; 1. Why the loop runs half the length:
;    - Each pass settles two bytes, the one at each end of what is left.
;    - Running the full length would exchange every pair twice and undo itself.
;    - The result of that mistake is the block it started with, which reads
;      like the reversal never happened at all.
; 2. The middle byte of an odd block:
;    - Halving an odd count discards the remainder, so the loop stops one short.
;    - The byte the two pointers land on is already in its final position.
;    - Nothing needs to be done to it, and doing something would be wrong.
; 3. No temporary buffer:
;    - In place work costs one register rather than a second block of memory.
;    - AL and AH hold the pair for the moment it takes to cross them over.
;    - On a machine with sixty four kilobytes to a segment, that saving is real.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
