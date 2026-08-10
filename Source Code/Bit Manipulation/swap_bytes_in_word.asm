; =============================================================================
; TITLE: Swap the Two Bytes of a Word
; DESCRIPTION: Exchanges the high and low bytes of a word by two routes, one
;              instruction each, and shows why the exchange is needed when data
;              arrives with the most significant byte first.
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
    SAMPLES DW 1234H, 0ABCDH, 00FFH, 0FF00H, 0000H, 0AAAAH
    SPAN    EQU $ - SAMPLES             ; Measured, never counted by hand
    HOWMANY EQU SPAN / 2

    BIGEND  DB 12H, 34H                 ; Two bytes laid down high half first

    M_TITLE DB 'Each word, then the same bytes exchanged twice over'
            DB 0DH, 0AH, '$'
    M_GAP   DB '   $'
    M_AGREE DB 'Both routes gave the same answer for every word.', 0DH, 0AH, '$'
    M_DIFF  DB 'The two routes disagreed, so one of them is wrong.', 0DH, 0AH, '$'
    M_BE1   DB 'Bytes stored as 12H then 34H are read back as $'
    M_BE2   DB ', and once exchanged they read as $'
    M_BE3   DB ', which is $'
    M_BE4   DB ' in decimal.', 0DH, 0AH, '$'

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
    XOR DI, DI                          ; How often the two routes differed
    MOV CX, HOWMANY

EACH_WORD:
    MOV AX, SAMPLES[SI]
    CALL PRINT_HEX
    LEA DX, M_GAP
    CALL PRINT_MESSAGE

    ; -------------------------------------------------------------------------
    ; ROUTE ONE: EXCHANGE THE TWO HALVES OF AX
    ;
    ; AX is one of the four registers that can be addressed as two bytes, so
    ; the whole operation is a single exchange with nothing to mask or shift.
    ; -------------------------------------------------------------------------
    XCHG AL, AH
    CALL PRINT_HEX
    MOV BP, AX                          ; Hold this answer for the comparison

    LEA DX, M_GAP
    CALL PRINT_MESSAGE

    ; -------------------------------------------------------------------------
    ; ROUTE TWO: ROTATE BY HALF THE WIDTH
    ;
    ; A rotate of eight places moves every bit exactly one byte along and wraps
    ; what leaves the top back in at the bottom, which is the same exchange.
    ; This route works on registers that have no addressable halves.
    ; -------------------------------------------------------------------------
    MOV BX, SAMPLES[SI]
    ROL BX, 8
    MOV AX, BX
    CALL PRINT_HEX
    CALL NEWLINE

    CMP AX, BP
    JE  ROUTES_AGREE
    INC DI

ROUTES_AGREE:
    ADD SI, 2
    LOOP EACH_WORD

    OR  DI, DI
    JNZ SOMETHING_DIFFERED
    LEA DX, M_AGREE
    JMP REPORT_ORDER

SOMETHING_DIFFERED:
    LEA DX, M_DIFF

REPORT_ORDER:
    CALL PRINT_MESSAGE

    ; -------------------------------------------------------------------------
    ; WHY THE EXCHANGE IS WORTH KNOWING
    ;
    ; The 8086 stores the low byte of a word at the lower address, so bytes
    ; written down in the order a person reads them come back the wrong way
    ; about. One exchange puts them right.
    ; -------------------------------------------------------------------------
    LEA DX, M_BE1
    CALL PRINT_MESSAGE
    MOV AX, WORD PTR BIGEND
    CALL PRINT_HEX

    LEA DX, M_BE2
    CALL PRINT_MESSAGE
    XCHG AL, AH
    CALL PRINT_HEX

    LEA DX, M_BE3
    CALL PRINT_MESSAGE
    CALL PRINT_DECIMAL
    LEA DX, M_BE4
    CALL PRINT_MESSAGE

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
; 1. WHY A ROTATE OF EIGHT IS AN EXCHANGE:
;    - A rotate loses nothing, and eight places is exactly half of sixteen, so
;    - each byte lands where the other one was.
;    - The same reasoning gives the nibble exchange of a byte at four places.
; 2. WHEN XCHG CANNOT BE USED:
;    - Only AX, BX, CX and DX have separately named halves, so a word held in
;    - SI, DI, BP or SP has no two bytes to exchange with each other.
;    - The rotate has no such restriction, which is why both are checked here.
; 3. WHY THE ORDER OF BYTES MATTERS AT ALL:
;    - The 8086 keeps the low byte of a word at the lower address, so a file or
;    - a protocol that writes the high byte first reads back reversed.
;    - Nothing is corrupted, and one exchange per word is the whole correction.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
