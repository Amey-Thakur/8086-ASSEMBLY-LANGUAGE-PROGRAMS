; =============================================================================
; TITLE: The Auxiliary Carry Behind The BCD Adjust
; DESCRIPTION: Adds four pairs of packed decimal bytes, shows the auxiliary
;              carry the addition left, and shows what DAA does with it.
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
    ; Packed decimal, so each nibble holds one decimal digit and 25h means
    ; twenty five rather than thirty seven.
    SUMS     DB 25H, 36H, 48H, 39H, 59H, 47H, 90H, 80H
    HOWMANY  EQU 4

    RAW      DB 0                       ; The binary sum, before any repair
    FIXED    DB 0                       ; And the same byte after DAA

    AF_MASK  EQU 0010H                  ; The auxiliary carry lives in bit 4
    CF_MASK  EQU 0001H                  ; The carry lives in bit 0

    M_TITLE  DB 'The auxiliary carry behind the BCD adjust', 0DH, 0AH, 0DH, 0AH
             DB 'AF is the carry out of bit 3, which is the boundary between '
             DB 'the two', 0DH, 0AH
             DB 'decimal digits packed into a byte. No branch reads it and no '
             DB 'instruction', 0DH, 0AH
             DB 'uses it except the decimal adjusts, which cannot work without '
             DB 'it.', 0DH, 0AH, 0DH, 0AH, '$'
    M_HEAD   DB '    A    B  sum   AF  DAA   CF', 0DH, 0AH
             DB '  ---  ---  ---   --  ---   --', 0DH, 0AH, '$'
    M_GAP2   DB '  $'
    M_GAP4   DB '    $'
    M_CLOSE  DB 0DH, 0AH
             DB 'Row one needed no auxiliary carry, because 5 and 6 fit in a '
             DB 'nibble. The', 0DH, 0AH
             DB 'adjust still fired, because 0Bh is not a decimal digit. Both '
             DB 'tests are', 0DH, 0AH
             DB 'needed, and a nibble above nine is the one AF cannot see.'
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

    LEA SI, SUMS
    MOV CX, HOWMANY

EACH_SUM:
    PUSH CX

    LEA DX, M_GAP2
    CALL PRINT_MESSAGE
    MOV AL, [SI]
    CALL PRINT_HEX_BYTE

    LEA DX, M_GAP2
    CALL PRINT_MESSAGE
    MOV AL, [SI+1]
    CALL PRINT_HEX_BYTE

    ; -------------------------------------------------------------------------
    ; THE ADDITION, THEN THE ADJUST. NOTHING MAY COME BETWEEN THEM EXCEPT MOV
    ; AND POP, WHICH ARE THE TWO INSTRUCTIONS THAT LEAVE THE FLAGS ALONE. DAA
    ; READS THE CARRY AND THE AUXILIARY CARRY THAT THE ADDITION LEFT.
    ; -------------------------------------------------------------------------
    MOV AL, [SI]
    ADD AL, [SI+1]
    MOV RAW, AL
    PUSHF
    POP BP                              ; The flags the adjust is about to read
    DAA
    MOV FIXED, AL
    PUSHF
    POP DI                              ; And the flags it leaves behind

    LEA DX, M_GAP2
    CALL PRINT_MESSAGE
    MOV AL, RAW
    CALL PRINT_HEX_BYTE

    ; ---- the auxiliary carry from the addition ------------------------------
    LEA DX, M_GAP4
    CALL PRINT_MESSAGE
    MOV AX, BP
    AND AX, AF_MASK
    JZ  NO_AUXILIARY
    MOV AX, 1                           ; A flag prints as one column, not as a mask

NO_AUXILIARY:
    CALL PRINT_DECIMAL

    LEA DX, M_GAP2
    CALL PRINT_MESSAGE
    MOV AL, FIXED
    CALL PRINT_HEX_BYTE

    ; ---- and the carry the adjust left, which is the hundreds digit ---------
    LEA DX, M_GAP4
    CALL PRINT_MESSAGE
    MOV AX, DI
    AND AX, CF_MASK
    JZ  NO_CARRY
    MOV AX, 1

NO_CARRY:
    CALL PRINT_DECIMAL
    CALL NEWLINE

    POP CX
    ADD SI, 2                           ; Two bytes to the next pair
    LOOP EACH_SUM

    LEA DX, M_CLOSE
    CALL PRINT_MESSAGE

    MOV AH, 4CH
    INT 21H

; -----------------------------------------------------------------------------
; PRINT_HEX_BYTE
; -----------------------------------------------------------------------------
PRINT_HEX_BYTE PROC
    PUSH AX
    PUSH CX
    PUSH DX

    MOV CL, AL
    SHR AL, 4
    CALL EMIT_NIBBLE
    MOV AL, CL
    AND AL, 0FH
    CALL EMIT_NIBBLE

    MOV DL, 'h'
    MOV AH, 02H
    INT 21H

    POP DX
    POP CX
    POP AX
    RET
PRINT_HEX_BYTE ENDP

EMIT_NIBBLE PROC
    ADD AL, '0'
    CMP AL, '9'
    JBE EN_EMIT
    ADD AL, 7

EN_EMIT:
    MOV DL, AL
    MOV AH, 02H
    INT 21H
    RET
EMIT_NIBBLE ENDP

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
; 1. WHAT THE ADJUST ACTUALLY DOES:
;    - It adds 6 to the low nibble when that nibble is above nine or AF is
;    - set, and 0x60 to the high nibble when that one is above nine or the
;    - carry is set. Six is the gap between sixteen and ten.
; 2. WHY THE CARRY MATTERS ON THE LAST ROW:
;    - 90 plus 80 is 170, and 70 is all that fits in one byte. The carry
;    - out of DAA is the hundreds digit, so a longer number is carried
;    - between bytes exactly as it would be in binary.
; 3. WHERE PACKED DECIMAL EARNS ITS PLACE:
;    - Money. A tenth cannot be written exactly in binary, so a currency
;    - total kept in binary drifts. Two digits to a byte costs speed and
;    - buys an answer that agrees with the ledger.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
