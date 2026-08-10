; =============================================================================
; TITLE: Exchange Two Blocks Of Memory
; DESCRIPTION: Swaps the contents of two separate blocks without a temporary
;              area, by carrying each element through one register and letting
;              XCHG do the crossing over against memory.
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
    ALPHA   DB 'MEMORY'
    ALPHA_W EQU $ - ALPHA                ; Bytes in each of the two text blocks
    BETA    DB 'BLOCKS'

    LEFT_W  DW 11, 22, 33, 44
    LEFT_B  EQU $ - LEFT_W               ; Bytes in each of the two word blocks
    PAIRS   EQU LEFT_B / 2               ; and so how many words there are
    RIGHT_W DW 55, 66, 77, 88

    M_BEFORE DB 'Before the exchange', 0DH, 0AH, '$'
    M_AFTER  DB 'After the exchange', 0DH, 0AH, '$'
    M_FIRST  DB '  first block:  $'
    M_SECOND DB '  second block: $'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA DX, M_BEFORE
    CALL PRINT_MESSAGE
    CALL SHOW_TEXT_BLOCKS
    CALL SHOW_WORD_BLOCKS

    ; -------------------------------------------------------------------------
    ; ONE BYTE AT A TIME. THE 8086 CANNOT MOVE MEMORY TO MEMORY, BUT XCHG WILL
    ; CROSS A REGISTER WITH MEMORY, SO A LOAD, AN EXCHANGE AND A STORE SETTLE
    ; BOTH BLOCKS WITH ONE REGISTER AND NO SCRATCH SPACE AT ALL.
    ; -------------------------------------------------------------------------
    XOR SI, SI
    MOV CX, ALPHA_W
    JCXZ TEXT_SWAPPED                   ; An empty block has nothing to exchange

SWAP_BYTE:
    MOV AL, ALPHA[SI]
    XCHG AL, BETA[SI]                   ; AL takes BETA, BETA takes ALPHA
    MOV ALPHA[SI], AL
    INC SI
    LOOP SWAP_BYTE

TEXT_SWAPPED:
    ; -------------------------------------------------------------------------
    ; THE SAME THREE STEPS ON WORDS INSTEAD OF BYTES. THE INDEX ADVANCES BY TWO
    ; AND THE COUNT IS HALVED, SO AN EVEN BLOCK IS EXCHANGED IN HALF THE PASSES.
    ; -------------------------------------------------------------------------
    XOR SI, SI
    MOV CX, PAIRS
    JCXZ WORDS_SWAPPED

SWAP_WORD:
    MOV AX, LEFT_W[SI]
    XCHG AX, RIGHT_W[SI]
    MOV LEFT_W[SI], AX
    ADD SI, 2
    LOOP SWAP_WORD

WORDS_SWAPPED:
    LEA DX, M_AFTER
    CALL PRINT_MESSAGE
    CALL SHOW_TEXT_BLOCKS
    CALL SHOW_WORD_BLOCKS

    MOV AH, 4CH
    INT 21H

; -----------------------------------------------------------------------------
; SHOW_TEXT_BLOCKS
;
; Prints both byte blocks, one to a line, each behind its own label.
; -----------------------------------------------------------------------------
SHOW_TEXT_BLOCKS PROC
    PUSH AX
    PUSH CX
    PUSH DX
    PUSH SI

    LEA DX, M_FIRST
    CALL PRINT_MESSAGE
    LEA SI, ALPHA
    MOV CX, ALPHA_W
    CALL PRINT_TEXT
    CALL NEWLINE

    LEA DX, M_SECOND
    CALL PRINT_MESSAGE
    LEA SI, BETA
    MOV CX, ALPHA_W
    CALL PRINT_TEXT
    CALL NEWLINE

    POP SI
    POP DX
    POP CX
    POP AX
    RET
SHOW_TEXT_BLOCKS ENDP

; -----------------------------------------------------------------------------
; SHOW_WORD_BLOCKS
;
; Prints both word blocks, one to a line, each behind its own label.
; -----------------------------------------------------------------------------
SHOW_WORD_BLOCKS PROC
    PUSH AX
    PUSH CX
    PUSH DX
    PUSH SI

    LEA DX, M_FIRST
    CALL PRINT_MESSAGE
    LEA SI, LEFT_W
    MOV CX, PAIRS
    CALL SHOW_RUN

    LEA DX, M_SECOND
    CALL PRINT_MESSAGE
    LEA SI, RIGHT_W
    MOV CX, PAIRS
    CALL SHOW_RUN

    POP SI
    POP DX
    POP CX
    POP AX
    RET
SHOW_WORD_BLOCKS ENDP

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
    CALL PRINT_DECIMAL
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
; 1. Why XCHG and not three moves:
;    - A load, an exchange and a store settle both elements with one register.
;    - The plain method needs two registers or a byte of scratch memory.
;    - XCHG against memory is a single instruction on the 8086, not a macro.
; 2. Why the blocks must not overlap:
;    - The exchange writes to both blocks while it is still reading from them.
;    - Where they overlap, an element can be read after it has been replaced.
;    - Unlike a block move, no choice of direction repairs that.
; 3. Bytes against words:
;    - The word loop advances the index by two and runs half as many times.
;    - It needs an even byte count, and an odd tail byte handled separately.
;    - The text blocks here are six bytes, so either width would have served.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
