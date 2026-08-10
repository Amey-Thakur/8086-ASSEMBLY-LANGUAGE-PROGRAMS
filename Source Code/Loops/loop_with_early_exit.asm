; =============================================================================
; TITLE: Leaving a Loop Early
; DESCRIPTION: Stops as soon as a condition is met rather than running to the
;              end, which is what a break statement compiles into.
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
    READINGS DW 12, 19, 24, 71, 33, 15
    HOWMANY  EQU 6
    LIMIT    EQU 50
    M_OVER   DB 'A reading exceeded the limit: $'
    M_OK     DB 'Every reading was within the limit.', 0DH, 0AH, '$'
    M_AFTER  DB 'Readings examined before stopping: $'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA SI, READINGS
    MOV CX, HOWMANY
    XOR BX, BX                          ; How many have been examined

CHECK_LOOP:
    INC BX
    MOV AX, [SI]
    CMP AX, LIMIT
    JA  TOO_HIGH                        ; The early exit

    ADD SI, 2
    LOOP CHECK_LOOP

    LEA DX, M_OK
    MOV AH, 09H
    INT 21H
    JMP FINISH

TOO_HIGH:
    ; -------------------------------------------------------------------------
    ; LEAVING EARLY ABANDONS WHATEVER IS LEFT IN CX. THAT IS HARMLESS HERE,
    ; BUT ANY CODE THAT RELIED ON CX BEING ZERO AFTERWARDS WOULD BE WRONG.
    ; -------------------------------------------------------------------------
    MOV DI, AX

    LEA DX, M_OVER
    MOV AH, 09H
    INT 21H
    MOV AX, DI
    CALL PRINT_DECIMAL
    CALL NEWLINE

    LEA DX, M_AFTER
    MOV AH, 09H
    INT 21H
    MOV AX, BX
    CALL PRINT_DECIMAL
    CALL NEWLINE

FINISH:
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

END START

; =============================================================================
; TECHNICAL NOTES
; =============================================================================
; 1. THE COUNT IS LEFT BEHIND:
;    - CX holds however many passes were still to come. That is often
;    - useful: it says where the loop stopped without a second counter.
; 2. WHERE TO PUT THE TEST:
;    - Testing at the top skips the body on the failing element. Testing
;    - at the bottom runs it first. Which is wanted depends on whether
;    - the body has an effect worth avoiding.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
