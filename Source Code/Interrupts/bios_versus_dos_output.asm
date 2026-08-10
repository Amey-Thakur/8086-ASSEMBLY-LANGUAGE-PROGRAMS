; =============================================================================
; TITLE: BIOS Output Against DOS Output
; DESCRIPTION: The same characters written three ways, and what each layer costs and offers.
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
    TEXT_W  DB 'INTEL 8086'
    SPAN    EQU $ - TEXT_W

    M_TITLE DB 'One string, written by DOS twice and by the BIOS once', 0DH, 0AH, '$'
    M_DOS9  DB 0DH, 0AH, 'DOS 09h, whole string at once: $'
    M_DOS2  DB 0DH, 0AH, 'DOS 02h, one character at a time: $'
    M_BIOS  DB 0DH, 0AH, 'BIOS 0Eh teletype, one at a time: $'
    M_CALLS DB 0DH, 0AH, 0DH, 0AH, 'Interrupts issued: 09h once, 02h $'
    M_TIMES DB ' times, 0Eh $'
    M_MORE  DB ' times.', 0DH, 0AH, '$'
    M_WHY   DB 0DH, 0AH
            DB '09h is one call for the whole string, so it is much the cheapest '
            DB 'when the text is ready and dollar terminated.', 0DH, 0AH, '$'
    M_WHY2  DB '02h goes through DOS, so it can be redirected to a file. 0Eh '
            DB 'goes to the BIOS and always reaches the screen.', 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA DX, M_TITLE
    CALL PRINT_MESSAGE

    ; -------------------------------------------------------------------------
    ; 09H TAKES THE WHOLE STRING, WHICH IS WHY IT NEEDS THE DOLLAR TERMINATOR.
    ; ONE INTERRUPT WRITES ALL TEN CHARACTERS.
    ; -------------------------------------------------------------------------
    LEA DX, M_DOS9
    CALL PRINT_MESSAGE

    LEA SI, TEXT_W
    MOV CX, SPAN
    CALL PRINT_TEXT                     ; Which is itself a loop of 02h

    ; ---- 02h, spelled out ---------------------------------------------------
    LEA DX, M_DOS2
    CALL PRINT_MESSAGE

    LEA SI, TEXT_W
    MOV CX, SPAN
    XOR BP, BP
EACH_DOS:
    MOV DL, [SI]
    MOV AH, 02H
    INT 21H
    INC BP
    INC SI
    LOOP EACH_DOS

    ; -------------------------------------------------------------------------
    ; THE BIOS TELETYPE SERVICE TAKES THE CHARACTER IN AL RATHER THAN DL, AND
    ; BH SELECTS THE DISPLAY PAGE. IT WRITES TO THE SCREEN WHATEVER DOS HAS BEEN
    ; TOLD ABOUT REDIRECTION.
    ; -------------------------------------------------------------------------
    LEA DX, M_BIOS
    CALL PRINT_MESSAGE

    LEA SI, TEXT_W
    MOV CX, SPAN
    XOR DI, DI
EACH_BIOS:
    MOV AL, [SI]
    MOV AH, 0EH
    MOV BH, 0
    INT 10H
    INC DI
    INC SI
    LOOP EACH_BIOS

    LEA DX, M_CALLS
    CALL PRINT_MESSAGE
    MOV AX, BP
    CALL PRINT_DECIMAL
    LEA DX, M_TIMES
    CALL PRINT_MESSAGE
    MOV AX, DI
    CALL PRINT_DECIMAL
    LEA DX, M_MORE
    CALL PRINT_MESSAGE

    LEA DX, M_WHY
    CALL PRINT_MESSAGE
    LEA DX, M_WHY2
    CALL PRINT_MESSAGE

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
; 1. Different registers for the character:
;    - DOS service 02h takes it in DL; BIOS service 0Eh takes it in AL.
;    - Mixing the two up prints whatever happened to be in the other register.
;    - BH selects the display page for the BIOS call and is zero for ordinary output.
; 2. One call or many:
;    - 09h writes a whole string for the price of one interrupt.
;    - The others are one interrupt per character, which is ten times the overhead here.
;    - The cost of 09h is needing the text terminated with a dollar sign in advance.
; 3. Which layer you are talking to:
;    - DOS output can be redirected to a file or a pipe by the command line.
;    - BIOS output goes to the display regardless, which is what a full screen program wants.
;    - A program that mixes them will find its output arriving in two different places.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
