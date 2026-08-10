; =============================================================================
; TITLE: Reading A Hexadecimal Number
; DESCRIPTION: Accepts the digits 0 to 9 and the letters A to F in either case, which needs three ranges rather than one.
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
    ; Fixed input rather than typed, so the three ranges are all exercised on
    ; every run and the answers can be checked against the source.
    CASE_1  DB '00FF'
    CASE_2  DB 'beef'
    CASE_3  DB '1A2b'
    CASE_4  DB '7fFf'
    CASE_5  DB '12G4'
    WIDTH   EQU 4

    M_TITLE DB 'Reading hexadecimal, upper and lower case', 0DH, 0AH, '$'
    M_TEXT  DB 0DH, 0AH, 'text: $'
    M_VALUE DB '   value: $'
    M_HEX   DB '   back as hex: $'
    M_BAD   DB '   rejected, not a hex digit', 0DH, 0AH, '$'
    M_WHY   DB 0DH, 0AH, 0DH, 0AH
            DB 'Three ranges, and the letters are worth ten more than their '
            DB 'position suggests, which is where the plus ten comes from.'
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

    LEA SI, CASE_1
    CALL REPORT
    LEA SI, CASE_2
    CALL REPORT
    LEA SI, CASE_3
    CALL REPORT
    LEA SI, CASE_4
    CALL REPORT
    LEA SI, CASE_5
    CALL REPORT

    LEA DX, M_WHY
    CALL PRINT_MESSAGE

    MOV AH, 4CH
    INT 21H

; -----------------------------------------------------------------------------
; REPORT
;
; Converts the four characters at DS:SI and prints the text and the result.
; -----------------------------------------------------------------------------
REPORT PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI

    LEA DX, M_TEXT
    CALL PRINT_MESSAGE
    MOV CX, WIDTH
    CALL PRINT_TEXT

    CALL PARSE_HEX                      ; AX = value, carry set when refused
    JC REPORT_BAD

    MOV BX, AX
    LEA DX, M_VALUE
    CALL PRINT_MESSAGE
    MOV AX, BX
    CALL PRINT_DECIMAL

    LEA DX, M_HEX
    CALL PRINT_MESSAGE
    MOV AX, BX
    CALL PRINT_HEX
    CALL NEWLINE
    JMP REPORT_DONE

REPORT_BAD:
    LEA DX, M_BAD
    CALL PRINT_MESSAGE

REPORT_DONE:
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
REPORT ENDP

; -----------------------------------------------------------------------------
; PARSE_HEX
;
; Converts the WIDTH characters at DS:SI to a word in AX. The carry flag is set
; when a character is not a hexadecimal digit, and AX is then meaningless.
;
; Each digit shifts the total left four bits, because one hex digit is exactly
; four bits. No multiplication is needed at all.
; -----------------------------------------------------------------------------
PARSE_HEX PROC
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI

    XOR BX, BX                          ; The running value
    MOV CX, WIDTH

EACH_HEX:
    MOV AL, [SI]
    INC SI

    ; ---- 0 to 9 -------------------------------------------------------------
    CMP AL, '0'
    JB HEX_BAD
    CMP AL, '9'
    JA TRY_UPPER
    SUB AL, '0'
    JMP HEX_HAVE

    ; ---- A to F -------------------------------------------------------------
TRY_UPPER:
    CMP AL, 'A'
    JB HEX_BAD
    CMP AL, 'F'
    JA TRY_LOWER
    SUB AL, 'A'
    ADD AL, 10
    JMP HEX_HAVE

    ; ---- a to f -------------------------------------------------------------
TRY_LOWER:
    CMP AL, 'a'
    JB HEX_BAD
    CMP AL, 'f'
    JA HEX_BAD
    SUB AL, 'a'
    ADD AL, 10

HEX_HAVE:
    ; Four bits along, then drop the new digit into the space made.
    ;
    ; The shift count has to be in CL, which is the low half of the loop
    ; counter, so CX is saved before CL is loaded and not after. Loading CL
    ; first would set the counter back to four on every pass and the loop would
    ; never end.
    PUSH CX
    MOV CL, 4
    SHL BX, CL
    POP CX

    XOR AH, AH
    ADD BX, AX
    LOOP EACH_HEX

    MOV AX, BX
    CLC                                 ; Accepted
    JMP HEX_DONE

HEX_BAD:
    STC                                 ; Refused

HEX_DONE:
    POP SI
    POP DX
    POP CX
    POP BX
    RET
PARSE_HEX ENDP

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
; 1. Shift, do not multiply:
;    - One hexadecimal digit is exactly four bits, so the total shifts left four.
;    - Decimal needs a multiply by ten; hexadecimal needs only a shift.
;    - That is the practical reason hexadecimal was chosen for machine work.
; 2. Three ranges, not one:
;    - Digits, upper case letters and lower case letters are three separate spans.
;    - A letter is worth ten more than its offset from A, hence the plus ten.
;    - Folding the case first with an OR of 20h would reduce it to two ranges.
; 3. The carry flag reports the refusal:
;    - Returning a value and a validity separately would need two registers.
;    - The carry flag is the conventional place, and matches what DOS itself does.
;    - CLC and STC set it deliberately rather than leaving it to whatever ran last.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
