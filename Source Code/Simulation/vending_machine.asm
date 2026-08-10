; =============================================================================
; TITLE: Vending Machine
; DESCRIPTION: Accepts coins until the price is covered, then works out the change with the fewest coins.
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
    PRICE   DW 85

    ; The coins accepted, largest first, which is what makes the greedy choice
    ; of change correct for this set.
    COINS   DW 100, 50, 20, 10, 5
    KINDS   EQU 5

    ; The coins a customer put in, in the order they arrived.
    INSERTED DW 20, 10, 50, 20
    HOWMANY  EQU 4

    M_TITLE DB 'A vending machine taking coins and giving change', 0DH, 0AH, '$'
    M_PRICE DB 'Price: $'
    M_INS   DB 'Inserted $'
    M_TOTAL DB ', running total $'
    M_SHORT DB '   still short by $'
    M_ENOUGH DB '   enough', 0DH, 0AH, '$'
    M_VEND  DB 0DH, 0AH, 'Dispensing the item.', 0DH, 0AH, '$'
    M_CHANGE DB 'Change owed: $'
    M_GIVE  DB 'Giving $'
    M_TIMES DB ' x $'
    M_LEFT  DB 'Coins returned: $'
    M_NL    DB 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA DX, M_TITLE
    CALL PRINT_MESSAGE
    LEA DX, M_PRICE
    CALL PRINT_MESSAGE
    MOV AX, PRICE
    CALL PRINT_DECIMAL
    CALL NEWLINE

    ; -------------------------------------------------------------------------
    ; COINS ARE TAKEN ONE AT A TIME AND THE TOTAL REPORTED AFTER EACH, WHICH IS
    ; WHAT THE DISPLAY ON A REAL MACHINE SHOWS. BP HOLDS THE RUNNING TOTAL.
    ; -------------------------------------------------------------------------
    XOR BP, BP
    XOR SI, SI
    MOV CX, HOWMANY

TAKE_COIN:
    LEA DX, M_INS
    CALL PRINT_MESSAGE
    MOV AX, INSERTED[SI]
    CALL PRINT_DECIMAL

    ADD BP, AX

    LEA DX, M_TOTAL
    CALL PRINT_MESSAGE
    MOV AX, BP
    CALL PRINT_DECIMAL

    ; Report how much is still wanted, or that the price is covered.
    CMP BP, PRICE
    JAE COVERED

    LEA DX, M_SHORT
    CALL PRINT_MESSAGE
    MOV AX, PRICE
    SUB AX, BP
    CALL PRINT_DECIMAL
    CALL NEWLINE
    JMP NEXT_COIN

COVERED:
    LEA DX, M_ENOUGH
    CALL PRINT_MESSAGE

NEXT_COIN:
    ADD SI, 2
    LOOP TAKE_COIN

    LEA DX, M_VEND
    CALL PRINT_MESSAGE

    ; -------------------------------------------------------------------------
    ; THE CHANGE IS WORKED OUT BY TAKING AS MANY OF THE LARGEST COIN AS WILL
    ; FIT, THEN THE NEXT LARGEST, AND SO ON. FOR A SET WHERE EACH COIN DIVIDES
    ; INTO THE NEXT THIS GIVES THE FEWEST COINS; FOR AN AWKWARD SET IT DOES NOT.
    ; -------------------------------------------------------------------------
    MOV DI, BP
    SUB DI, PRICE                       ; What is owed

    LEA DX, M_CHANGE
    CALL PRINT_MESSAGE
    MOV AX, DI
    CALL PRINT_DECIMAL
    CALL NEWLINE

    XOR SI, SI
    XOR BP, BP                          ; Coins handed back
    MOV CX, KINDS

EACH_KIND:
    MOV BX, COINS[SI]

COUNT_THIS_KIND:
    CMP DI, BX
    JB KIND_DONE

    SUB DI, BX
    INC BP

    LEA DX, M_GIVE
    CALL PRINT_MESSAGE
    MOV AX, BX
    CALL PRINT_DECIMAL
    CALL NEWLINE

    JMP COUNT_THIS_KIND

KIND_DONE:
    ADD SI, 2
    LOOP EACH_KIND

    LEA DX, M_LEFT
    CALL PRINT_MESSAGE
    MOV AX, BP
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
; 1. Unsigned comparison throughout:
;    - JAE and JB are the unsigned pair, which is right for money held as a count.
;    - JGE and JL would be wrong the moment a total passed 32767.
;    - Choosing the wrong family is the classic 8086 comparison bug.
; 2. Greedy change is not always least:
;    - Taking the largest coin first is optimal when each coin divides into the next.
;    - For a set like 1, 3 and 4, greedy gives 4+1+1 for six where 3+3 is better.
;    - The coin set here is chosen so the simple method is also the correct one.
; 3. Overpayment is normal:
;    - The machine cannot refuse the coin that takes the total past the price.
;    - So change is the rule rather than the exception, and must always be computed.
;    - The loop keeps taking coins after the price is met, exactly as a real one does.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
