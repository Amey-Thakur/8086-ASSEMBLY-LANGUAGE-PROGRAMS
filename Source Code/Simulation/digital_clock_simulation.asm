; =============================================================================
; TITLE: Digital Clock Simulation
; DESCRIPTION: Advances hours, minutes and seconds with the carries that make midnight work, printed as a proper two digit display.
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
    HOUR_W  DW 23
    MIN_W   DW 59
    SEC_W   DW 55

    M_TITLE DB 'A clock ticking through midnight', 0DH, 0AH, '$'
    M_START DB 'Starting at 23:59:55 and ticking ten times.', 0DH, 0AH, '$'
    M_COLON DB ':$'
    M_ROLL  DB '   <- the day rolled over', 0DH, 0AH, '$'
    M_PLAIN DB 0DH, 0AH, '$'
    M_WHY   DB 0DH, 0AH
            DB 'Each carry is a separate test. Seconds reaching sixty advance '
            DB 'the minute, and only then can the minute reach sixty.', 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA DX, M_TITLE
    CALL PRINT_MESSAGE
    LEA DX, M_START
    CALL PRINT_MESSAGE

    MOV CX, 10

EACH_TICK:
    CALL ADVANCE_ONE_SECOND
    CALL SHOW_TIME
    LOOP EACH_TICK

    LEA DX, M_WHY
    CALL PRINT_MESSAGE

    MOV AH, 4CH
    INT 21H

; -----------------------------------------------------------------------------
; ADVANCE_ONE_SECOND
;
; Adds a second and carries into the minute, the hour and the day.
;
; The carries have to be tested in that order. Testing the hour before the
; minute has been carried into would miss midnight by a whole minute.
; -----------------------------------------------------------------------------
ADVANCE_ONE_SECOND PROC
    PUSH AX

    MOV AX, SEC_W
    INC AX
    MOV SEC_W, AX
    CMP AX, 60
    JB SECOND_DONE

    MOV SEC_W, 0
    MOV AX, MIN_W
    INC AX
    MOV MIN_W, AX
    CMP AX, 60
    JB SECOND_DONE

    MOV MIN_W, 0
    MOV AX, HOUR_W
    INC AX
    MOV HOUR_W, AX
    CMP AX, 24
    JB SECOND_DONE

    MOV HOUR_W, 0                       ; Midnight

SECOND_DONE:
    POP AX
    RET
ADVANCE_ONE_SECOND ENDP

; -----------------------------------------------------------------------------
; SHOW_TIME
;
; Prints the clock as HH:MM:SS, noting the moment the day rolls over.
; -----------------------------------------------------------------------------
SHOW_TIME PROC
    PUSH AX
    PUSH DX

    MOV AX, HOUR_W
    CALL PRINT_TWO_DIGITS
    LEA DX, M_COLON
    CALL PRINT_MESSAGE

    MOV AX, MIN_W
    CALL PRINT_TWO_DIGITS
    LEA DX, M_COLON
    CALL PRINT_MESSAGE

    MOV AX, SEC_W
    CALL PRINT_TWO_DIGITS

    ; Midnight exactly is worth pointing out, since it is the case the carries
    ; exist for.
    CMP HOUR_W, 0
    JNE PLAIN_LINE
    CMP MIN_W, 0
    JNE PLAIN_LINE
    CMP SEC_W, 0
    JNE PLAIN_LINE

    LEA DX, M_ROLL
    CALL PRINT_MESSAGE
    JMP SHOW_DONE

PLAIN_LINE:
    LEA DX, M_PLAIN
    CALL PRINT_MESSAGE

SHOW_DONE:
    POP DX
    POP AX
    RET
SHOW_TIME ENDP

; -----------------------------------------------------------------------------
; PRINT_TWO_DIGITS
;
; Prints AX as exactly two digits, so nine appears as 09 and the columns of a
; clock display line up.
; -----------------------------------------------------------------------------
PRINT_TWO_DIGITS PROC
    PUSH AX
    PUSH BX
    PUSH DX

    XOR DX, DX
    MOV BX, 10
    DIV BX                              ; AX = tens, DX = units

    ; DL is needed after the DOS call, so the units digit is kept in BL.
    MOV BL, DL

    ADD AL, '0'
    MOV DL, AL
    MOV AH, 02H
    INT 21H

    MOV DL, BL
    ADD DL, '0'
    MOV AH, 02H
    INT 21H

    POP DX
    POP BX
    POP AX
    RET
PRINT_TWO_DIGITS ENDP

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
; 1. The carries are ordered:
;    - A second carries into the minute, which can then carry into the hour.
;    - Each test falls through to the next only when the one before overflowed.
;    - Testing them independently would miss the case where all three roll at once.
; 2. Leading zeros matter:
;    - A clock printed with PRINT_DECIMAL would show 0:0:0 at midnight.
;    - Dividing by ten and printing both digits always gives two characters.
;    - The same routine is what any fixed width numeric display needs.
; 3. Why DL is copied to BL:
;    - DIV leaves the remainder in DX, and DOS service 02H wants the character in DL.
;    - Printing the tens digit therefore destroys the units digit still sitting in DL.
;    - Moving it to BL first is the smallest fix; pushing DX would work too.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
