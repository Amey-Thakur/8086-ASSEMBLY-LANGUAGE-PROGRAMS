; =============================================================================
; TITLE: Calling a Procedure Through a Pointer
; DESCRIPTION: One walker over an array calls whatever procedure BX happens to
;              point at, so the same loop performs four different jobs without
;              a single test of which job it is doing.
; AUTHOR: Amey Thakur (https://github.com/Amey-Thakur)
; REPOSITORY: https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
; LICENSE: MIT License
; =============================================================================

.MODEL SMALL
.STACK 200H

; -----------------------------------------------------------------------------
; DATA SEGMENT
; -----------------------------------------------------------------------------
.DATA
    VALUES  DW 2, 4, 7, 9, 12, 15
    SPAN    EQU $ - VALUES              ; Measured, never counted by hand

    ACTION  DW ?                        ; The chosen procedure, held as data

    M_TITLE DB 'One walker, four jobs, chosen by a pointer', 0DH, 0AH, '$'
    M_SRC   DB 'given      $'
    M_TRIP  DB 'tripled    $'
    M_SQR   DB 'squared    $'
    M_HALF  DB 'halved     $'
    M_GAP   DB '  $'
    M_CLOSE DB 0DH, 0AH
            DB 'WALK_ARRAY was assembled before any of the four transforms '
            DB 'existed, and it never learns which one it is calling. A fifth '
            DB 'could be added without touching it.', 0DH, 0AH, '$'

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
    ; THE UNTOUCHED ARRAY FIRST, BY POINTING THE WALKER AT A PROCEDURE THAT
    ; CHANGES NOTHING. AN IDENTITY IS OFTEN THE TIDIEST WAY TO SAY NO CHANGE.
    ; -------------------------------------------------------------------------
    LEA DX, M_SRC
    CALL PRINT_MESSAGE
    MOV AX, OFFSET UNCHANGED
    MOV ACTION, AX
    CALL RUN_CHOSEN

    LEA DX, M_TRIP
    CALL PRINT_MESSAGE
    MOV AX, OFFSET TRIPLE
    MOV ACTION, AX
    CALL RUN_CHOSEN

    LEA DX, M_SQR
    CALL PRINT_MESSAGE
    MOV AX, OFFSET SQUARE
    MOV ACTION, AX
    CALL RUN_CHOSEN

    LEA DX, M_HALF
    CALL PRINT_MESSAGE
    MOV AX, OFFSET HALVE
    MOV ACTION, AX
    CALL RUN_CHOSEN

    LEA DX, M_CLOSE
    CALL PRINT_MESSAGE

    MOV AH, 4CH
    INT 21H

; -----------------------------------------------------------------------------
; RUN_CHOSEN
;
; Loads the pointer out of memory and hands the whole array to the walker. The
; pointer is an ordinary word, which is the entire point of the exercise.
; -----------------------------------------------------------------------------
RUN_CHOSEN PROC
    PUSH BX
    PUSH CX
    PUSH SI

    LEA SI, VALUES
    MOV CX, SPAN
    SHR CX, 1                           ; Bytes to elements, each a word
    MOV BX, ACTION
    CALL WALK_ARRAY

    POP SI
    POP CX
    POP BX
    RET
RUN_CHOSEN ENDP

; -----------------------------------------------------------------------------
; WALK_ARRAY
;
; Entry: SI = first word, CX = how many, BX = the procedure to apply.
;
; CALL BX transfers control to whatever address BX holds. The transform must
; therefore leave BX, CX and SI exactly as it found them, or the loop would
; lose its own place on the first element.
; -----------------------------------------------------------------------------
WALK_ARRAY PROC
    PUSH AX
    PUSH CX
    PUSH DX
    PUSH SI

    JCXZ WA_DONE                        ; LOOP with CX at zero would run forever

WA_NEXT:
    MOV AX, [SI]
    CALL BX                             ; The indirect call, and the whole trick
    CALL PRINT_DECIMAL

    CMP CX, 1
    JBE WA_STEP                         ; No separator after the final element
    LEA DX, M_GAP
    CALL PRINT_MESSAGE

WA_STEP:
    ADD SI, 2
    LOOP WA_NEXT

WA_DONE:
    CALL NEWLINE

    POP SI
    POP DX
    POP CX
    POP AX
    RET
WALK_ARRAY ENDP

; -----------------------------------------------------------------------------
; UNCHANGED
;
; Entry and exit: AX. Returning the argument untouched gives the walker a
; procedure to call when the array is only to be shown.
; -----------------------------------------------------------------------------
UNCHANGED PROC
    RET
UNCHANGED ENDP

; -----------------------------------------------------------------------------
; TRIPLE
;
; Entry and exit: AX. Doubling and adding one more avoids MUL, which would
; overwrite DX and force another save and restore.
; -----------------------------------------------------------------------------
TRIPLE PROC
    PUSH DX

    MOV DX, AX
    SHL AX, 1                           ; Two of them
    ADD AX, DX                          ; And the original makes three

    POP DX
    RET
TRIPLE ENDP

; -----------------------------------------------------------------------------
; SQUARE
;
; Entry and exit: AX. MUL AX multiplies the accumulator by itself and puts the
; high half in DX, which is saved because the walker is using it for messages.
; -----------------------------------------------------------------------------
SQUARE PROC
    PUSH DX

    MUL AX                              ; The data is small enough to stay in AX

    POP DX
    RET
SQUARE ENDP

; -----------------------------------------------------------------------------
; HALVE
;
; Entry and exit: AX. A logical shift brings in a zero at the top, which is the
; right choice here because every value is unsigned.
; -----------------------------------------------------------------------------
HALVE PROC
    SHR AX, 1                           ; Anything odd loses its remainder
    RET
HALVE ENDP

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
; 1. WHAT CALL BX ACTUALLY DOES:
;    - It pushes the address of the next instruction, then loads IP from BX.
;    - The return is an ordinary RET, which knows nothing of how it was reached.
;    - Only a near call is possible this way, so the target must share CS.
; 2. THE CONTRACT A TRANSFORM MUST KEEP:
;    - It takes AX and returns AX, and leaves BX, CX and SI alone.
;    - Breaking that costs the walker its pointer, its count or its place.
;    - Nothing in the machine enforces it, so the header has to state it.
; 3. WHY THIS IS WORTH THE INDIRECTION:
;    - A fifth transform needs no change at all to the walker.
;    - The alternative is a comparison per element against every case.
;    - It is how a callback, a device driver and a virtual method all work.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
