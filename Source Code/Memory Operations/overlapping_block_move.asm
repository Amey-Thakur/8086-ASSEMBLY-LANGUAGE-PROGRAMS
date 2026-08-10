; =============================================================================
; TITLE: Overlapping Block Move Copied Backwards
; DESCRIPTION: Moves a block three places up inside itself, first forwards to
;              show the damage that does, then backwards with the direction
;              flag set, which is the only order that survives the overlap.
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
    ARENA   DB 'ABCDEFGHIJ...'           ; The three stops are the room to move into
    ARENA_W EQU $ - ARENA                ; Measured, so no count can drift
    FRESH   DB 'ABCDEFGHIJ...'           ; An untouched copy, to undo the first attempt

    SHIFTBY EQU 3                        ; How far up the block is asked to move
    SPAN    EQU ARENA_W - SHIFTBY        ; How many bytes actually travel

    M_START DB 'At the start: $'
    M_FWD   DB 'Forwards:     $'
    M_AGAIN DB 'Restored:     $'
    M_BACK  DB 'Backwards:    $'
    M_WHY   DB 'Forwards, every byte written lands on a byte not yet read, so the'
            DB 0DH, 0AH
            DB 'first three bytes are stamped out along the whole block. Backwards,'
            DB 0DH, 0AH
            DB 'the highest byte moves first and nothing is read after it is written.'
            DB 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX
    MOV ES, AX                          ; MOVSB writes to ES:DI and to nowhere else

    LEA DX, M_START
    CALL PRINT_MESSAGE
    LEA SI, ARENA
    MOV CX, ARENA_W
    CALL PRINT_TEXT
    CALL NEWLINE

    ; -------------------------------------------------------------------------
    ; THE WRONG ORDER FIRST. THE DESTINATION SITS ABOVE THE SOURCE AND THE TWO
    ; OVERLAP, SO A FORWARD COPY REVISITS BYTES IT HAS ALREADY OVERWRITTEN AND
    ; THE RESULT REPEATS WITH A PERIOD OF THREE.
    ; -------------------------------------------------------------------------
    LEA SI, ARENA
    LEA DI, ARENA
    ADD DI, SHIFTBY
    MOV CX, SPAN
    CLD
    REP MOVSB

    LEA DX, M_FWD
    CALL PRINT_MESSAGE
    LEA SI, ARENA
    MOV CX, ARENA_W
    CALL PRINT_TEXT
    CALL NEWLINE

    ; -------------------------------------------------------------------------
    ; PUT THE BLOCK BACK FROM THE SPARE COPY. THESE TWO REGIONS DO NOT OVERLAP,
    ; SO THE DIRECTION IS FREE AND FORWARDS IS AS GOOD AS ANY.
    ; -------------------------------------------------------------------------
    LEA SI, FRESH
    LEA DI, ARENA
    MOV CX, ARENA_W
    CLD
    REP MOVSB

    LEA DX, M_AGAIN
    CALL PRINT_MESSAGE
    LEA SI, ARENA
    MOV CX, ARENA_W
    CALL PRINT_TEXT
    CALL NEWLINE

    ; -------------------------------------------------------------------------
    ; NOW BACKWARDS. STD MAKES BOTH POINTERS COUNT DOWN, WHICH IS WHY EACH ONE
    ; STARTS AT THE LAST BYTE THAT TAKES PART RATHER THAN THE FIRST.
    ; -------------------------------------------------------------------------
    LEA SI, ARENA
    ADD SI, SPAN - 1                    ; The last byte read
    LEA DI, ARENA
    ADD DI, ARENA_W - 1                 ; The last byte written
    MOV CX, SPAN
    STD
    REP MOVSB
    CLD                                 ; Left set, DF would reverse the next copy

    LEA DX, M_BACK
    CALL PRINT_MESSAGE
    LEA SI, ARENA
    MOV CX, ARENA_W
    CALL PRINT_TEXT
    CALL NEWLINE

    LEA DX, M_WHY
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
; 1. Which direction is safe:
;    - Copy forwards when the destination lies below the source.
;    - Copy backwards when the destination lies above it and the two overlap.
;    - When they do not overlap at all, either direction gives the same answer.
; 2. Where the pointers start:
;    - Forwards, SI and DI hold the first byte of each region.
;    - Backwards, they hold the last, which is the start plus the count less one.
;    - Forgetting the less one is the usual mistake and writes one byte too high.
; 3. Restoring the direction flag:
;    - DF is part of the machine state, not part of one instruction.
;    - A procedure that sets it and returns leaves every later copy reversed.
;    - CLD immediately after the backward move keeps that fault from spreading.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
