; =============================================================================
; TITLE: Count Set Bits with a Nibble Table
; DESCRIPTION: Counts the one bits of a word four at a time, by looking every
;              nibble up in a sixteen entry table with XLAT.
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
    ; Sixteen bytes hold the answer for every nibble that can exist, so the
    ; count of four bits costs one memory read rather than four tests.
    ONES_IN DB 0, 1, 1, 2, 1, 2, 2, 3, 1, 2, 2, 3, 2, 3, 3, 4

    SAMPLES DW 0000H, 0001H, 00FFH, 0F0F0H, 0FFFFH, 0B4D2H, 8000H, 1234H
    SPAN    EQU $ - SAMPLES             ; Measured, never counted by hand
    HOWMANY EQU SPAN / 2

    TALLY   DW 0                        ; Bits found in the word being read

    M_TITLE DB 'Counting one bits four at a time with a lookup table', 0DH, 0AH, '$'
    M_WORD  DB 'Word $'
    M_COUNT DB '   set bits: $'
    M_TOTAL DB 'Set bits across all eight words: $'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    ; Context setup
    MOV AX, @DATA
    MOV DS, AX

    LEA DX, M_TITLE
    CALL PRINT_MESSAGE

    XOR SI, SI                          ; Byte offset into the sample list
    XOR DI, DI                          ; Bits found across every sample
    MOV CX, HOWMANY

    ; -------------------------------------------------------------------------
    ; ONE SAMPLE AT A TIME
    ;
    ; The outer count is stacked because the nibble loop needs CX as well, and
    ; LOOP has no other counter it can be given.
    ; -------------------------------------------------------------------------
EACH_SAMPLE:
    PUSH CX
    MOV BP, SAMPLES[SI]                 ; The word under test, kept clear of DX

    LEA DX, M_WORD
    CALL PRINT_MESSAGE
    MOV AX, BP
    CALL PRINT_HEX

    MOV TALLY, 0
    LEA BX, ONES_IN                     ; XLAT reads from DS:BX plus AL
    MOV CX, 4                           ; Four nibbles make a word

    ; -------------------------------------------------------------------------
    ; ONE NIBBLE AT A TIME
    ;
    ; Four rotations of four places return the word to where it started, so
    ; nothing has to be saved and restored around the loop.
    ; -------------------------------------------------------------------------
NEXT_NIBBLE:
    ROL BP, 4                           ; Bring the next nibble to the bottom
    MOV AX, BP
    AND AX, 000FH                       ; AL is the nibble, and AH is cleared with it
    XLAT                                ; AL becomes the count for that nibble
    ADD TALLY, AX
    LOOP NEXT_NIBBLE

    LEA DX, M_COUNT
    CALL PRINT_MESSAGE
    MOV AX, TALLY
    CALL PRINT_DECIMAL
    CALL NEWLINE

    ADD DI, TALLY
    ADD SI, 2
    POP CX
    LOOP EACH_SAMPLE

    LEA DX, M_TOTAL
    CALL PRINT_MESSAGE
    MOV AX, DI
    CALL PRINT_DECIMAL
    CALL NEWLINE

    ; End process
    MOV AH, 4CH
    INT 21H

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
; 1. WHY A NIBBLE AND NOT A BYTE:
;    - A byte wide table would answer twice as fast but would need 256 entries.
;    - Sixteen entries fit in one line of source and still halve the work of
;    - testing each of the sixteen bits in turn.
; 2. WHAT XLAT ACTUALLY DOES:
;    - It reads the byte at DS:BX plus AL and puts it back in AL, which is one
;    - instruction for the whole index, fetch and store.
;    - AH is untouched, so clearing it beforehand leaves a usable word result.
; 3. WHY THE COUNT LIVES IN MEMORY:
;    - Every general register is already committed: BX to the table, CX to the
;    - two loops, DX to the messages and BP to the word being taken apart.
;    - A word of memory costs one read and keeps the register discipline plain.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
