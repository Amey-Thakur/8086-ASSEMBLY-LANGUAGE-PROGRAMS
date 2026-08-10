; =============================================================================
; TITLE: Based Addressing Mode
; DESCRIPTION: A base register plus a constant displacement, the mode that reads a named field out of a record.
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
    ; One record: three fields at fixed distances from the start.
    RECORD  DW 1985                     ; +0  year
            DW 42                       ; +2  quantity
            DW 995                      ; +4  price

    DATA_W  DW 10, 20, 30, 40, 50

    M_TITLE DB 'Based addressing: a base register plus a constant', 0DH, 0AH, '$'
    M_YEAR  DB '[BX+0] year     = $'
    M_QTY   DB '[BX+2] quantity = $'
    M_PRICE DB '[BX+4] price    = $'
    M_NAMED DB 'The other spelling, DATA_W[BX], puts the constant first.', 0DH, 0AH, '$'
    M_ZERO  DB 'BX = 0 gives $'
    M_TWO   DB ', BX = 2 gives $'
    M_EIGHT DB ', BX = 8 gives $'

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
    ; BX POINTS AT THE RECORD AND THE DISPLACEMENT PICKS THE FIELD. THE BASE
    ; CAN THEN BE MOVED TO THE NEXT RECORD WITHOUT ANY OF THE FIELD OFFSETS
    ; CHANGING, WHICH IS THE WHOLE POINT OF THE MODE.
    ; -------------------------------------------------------------------------
    LEA BX, RECORD

    MOV AX, [BX]
    LEA DX, M_YEAR
    CALL PRINT_MESSAGE
    CALL PRINT_DECIMAL
    CALL NEWLINE

    MOV AX, [BX+2]
    LEA DX, M_QTY
    CALL PRINT_MESSAGE
    CALL PRINT_DECIMAL
    CALL NEWLINE

    MOV AX, [BX+4]
    LEA DX, M_PRICE
    CALL PRINT_MESSAGE
    CALL PRINT_DECIMAL
    CALL NEWLINE
    CALL NEWLINE

    ; -------------------------------------------------------------------------
    ; DATA_W[BX] MEANS THE SAME AS [DATA_W+BX]. HERE THE NAME SUPPLIES THE
    ; FIXED PART AND BX SUPPLIES THE VARIABLE PART, WHICH IS THE REVERSE OF
    ; THE ARRANGEMENT ABOVE. BX HOLDS A BYTE OFFSET, NOT AN ELEMENT NUMBER.
    ; -------------------------------------------------------------------------
    LEA DX, M_NAMED
    CALL PRINT_MESSAGE

    LEA DX, M_ZERO

    CALL PRINT_MESSAGE
    XOR BX, BX
    MOV AX, DATA_W[BX]
    CALL PRINT_DECIMAL

    LEA DX, M_TWO

    CALL PRINT_MESSAGE
    MOV BX, 2
    MOV AX, DATA_W[BX]
    CALL PRINT_DECIMAL

    LEA DX, M_EIGHT

    CALL PRINT_MESSAGE
    MOV BX, 8
    MOV AX, DATA_W[BX]
    CALL PRINT_DECIMAL
    CALL NEWLINE

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
; 1. Records are what it is for:
;    - The displacement names a field and the base names the record.
;    - ADD BX, 6 moves to the next record and every field offset still works.
;    - A compiler emits exactly this shape for a structure member access.
; 2. Two spellings, one meaning:
;    - [BX+4] and RECORD[BX] both add a register to a constant.
;    - The assembler folds whichever part it knows into the displacement field.
;    - RECORD[BX] with BX already holding OFFSET RECORD would add the base twice.
; 3. The displacement is signed:
;    - It is one byte when it fits in the range -128 to 127, and two bytes otherwise.
;    - [BX-2] is legal and reads the word before the base.
;    - The assembler chooses the shorter encoding on its own.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
