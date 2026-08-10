; =============================================================================
; TITLE: Union and Intersection of Two Sets
; DESCRIPTION: Combines and compares two collections of small numbers using a
;              bitmap, where each value is one bit.
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
    SET_A   DB 3, 7, 1, 12, 5
    A_SIZE  EQU $ - SET_A
    SET_B   DB 7, 2, 12, 9
    B_SIZE  EQU $ - SET_B

    BITS_A  DW 0                        ; One bit per value, 0 to 15
    BITS_B  DW 0

    M_A     DB 'A:            $'
    M_B     DB 'B:            $'
    M_UNION DB 'A or B:       $'
    M_INTER DB 'A and B:      $'
    M_ONLYA DB 'In A only:    $'
    SPACE   DB ' $'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    ; -------------------------------------------------------------------------
    ; EACH VALUE BECOMES ONE BIT, SO A SET OF SMALL NUMBERS FITS IN A SINGLE
    ; WORD. ONCE THAT IS DONE, UNION IS OR, INTERSECTION IS AND, AND
    ; DIFFERENCE IS AND WITH NOT. THE SET OPERATIONS BECOME ONE INSTRUCTION
    ; EACH, WHATEVER THE SIZE OF THE SETS.
    ; -------------------------------------------------------------------------
    LEA SI, SET_A
    MOV CX, A_SIZE
    CALL BUILD_BITS
    MOV BITS_A, AX

    LEA SI, SET_B
    MOV CX, B_SIZE
    CALL BUILD_BITS
    MOV BITS_B, AX

    LEA DX, M_A
    MOV AH, 09H
    INT 21H
    MOV AX, BITS_A
    CALL SHOW_SET

    LEA DX, M_B
    MOV AH, 09H
    INT 21H
    MOV AX, BITS_B
    CALL SHOW_SET

    LEA DX, M_UNION
    MOV AH, 09H
    INT 21H
    MOV AX, BITS_A
    OR  AX, BITS_B
    CALL SHOW_SET

    LEA DX, M_INTER
    MOV AH, 09H
    INT 21H
    MOV AX, BITS_A
    AND AX, BITS_B
    CALL SHOW_SET

    LEA DX, M_ONLYA
    MOV AH, 09H
    INT 21H
    MOV AX, BITS_B
    NOT AX
    AND AX, BITS_A
    CALL SHOW_SET

    MOV AH, 4CH
    INT 21H

; -----------------------------------------------------------------------------
; BUILD_BITS
;
; Turns CX values at DS:SI into a bitmap in AX.
; -----------------------------------------------------------------------------
BUILD_BITS PROC
    PUSH BX
    PUSH CX
    PUSH SI

    XOR AX, AX

BB_LOOP:
    JCXZ BB_DONE

    MOV BX, 1
    PUSH CX
    MOV CL, [SI]
    SHL BX, CL                          ; The bit for this value
    POP CX
    OR  AX, BX

    INC SI
    LOOP BB_LOOP

BB_DONE:
    POP SI
    POP CX
    POP BX
    RET
BUILD_BITS ENDP

; -----------------------------------------------------------------------------
; SHOW_SET
;
; Lists the values a bitmap in AX stands for.
; -----------------------------------------------------------------------------
SHOW_SET PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX

    MOV BX, AX
    XOR CX, CX                          ; The value being considered

SS_LOOP:
    CMP CX, 16
    JAE SS_DONE

    MOV AX, 1
    PUSH CX
    SHL AX, CL
    POP CX
    TEST BX, AX
    JZ  SS_NEXT

    PUSH BX
    PUSH CX
    MOV AX, CX
    CALL PRINT_DECIMAL
    LEA DX, SPACE
    MOV AH, 09H
    INT 21H
    POP CX
    POP BX

SS_NEXT:
    INC CX
    JMP SS_LOOP

SS_DONE:
    CALL NEWLINE

    POP DX
    POP CX
    POP BX
    POP AX
    RET
SHOW_SET ENDP

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
; 1. THE LIMIT IS THE WORD:
;    - Sixteen possible values in one word. For a larger universe an array
;    - of words is used, and the operations become a loop over that array
;    - rather than a single instruction.
; 2. DIFFERENCE IS AND NOT:
;    - Everything in A that is not in B is A masked with the complement
;    - of B. It is the same identity that set theory uses, expressed in
;    - the instructions the processor already has.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
