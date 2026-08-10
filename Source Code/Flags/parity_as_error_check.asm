; =============================================================================
; TITLE: The Parity Flag As A Transmission Check
; DESCRIPTION: Builds an odd parity bit onto each of four bytes, damages one
;              bit of one byte, and uses the flag again to find the damage.
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
    ; Seven bit values, so that bit 7 is free to carry the parity.
    PAYLOAD  DB 41H, 42H, 43H, 7FH
    HOWMANY  EQU 4

    SENT     DB 4 DUP(0)                ; Each payload with its parity bit added
    RECEIVED DB 4 DUP(0)                ; The same bytes after the line damages one

    DAMAGE   EQU 08H                    ; The single bit that flips in transit

    M_TITLE  DB 'The parity flag as a transmission check', 0DH, 0AH, 0DH, 0AH
             DB 'Odd parity adds one bit to each byte so that the count of ones '
             DB 'is always', 0DH, 0AH
             DB 'odd. A receiver rejects any byte whose count comes out even.'
             DB 0DH, 0AH, 0DH, 0AH, '$'
    M_HEAD1  DB '  data  sent', 0DH, 0AH
             DB '  ----  ----', 0DH, 0AH, '$'
    M_BREAK  DB 0DH, 0AH
             DB 'One bit of the third byte is now flipped, as a noisy line '
             DB 'would flip it.', 0DH, 0AH, 0DH, 0AH, '$'
    M_HEAD2  DB '  byte  verdict', 0DH, 0AH
             DB '  ----  --------', 0DH, 0AH, '$'
    M_LEAD   DB '   $'
    M_GOOD   DB '  accepted', 0DH, 0AH, '$'
    M_BAD    DB '  REJECTED', 0DH, 0AH, '$'
    M_CLOSE  DB 0DH, 0AH
             DB 'One flipped bit always changes the count, so it is always '
             DB 'caught. Two', 0DH, 0AH
             DB 'flipped bits restore the count, so they are not caught at all.'
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
    LEA DX, M_HEAD1
    CALL PRINT_MESSAGE

    ; -------------------------------------------------------------------------
    ; ENCODING. OR OF A REGISTER WITH ITSELF CHANGES NOTHING BUT SETS THE
    ; FLAGS, WHICH IS THE ONLY WAY TO ASK THE PROCESSOR TO COUNT THE ONES.
    ; -------------------------------------------------------------------------
    LEA SI, PAYLOAD
    LEA DI, SENT
    MOV CX, HOWMANY
    JCXZ ENCODED

ENCODE_ONE:
    PUSH CX

    MOV AL, [SI]
    OR  AL, AL
    JP  NEEDS_A_BIT                     ; Parity set means the count is even
    JMP KEEP_AS_IS

NEEDS_A_BIT:
    OR  AL, 80H                         ; The spare bit makes the count odd

KEEP_AS_IS:
    MOV [DI], AL

    ; ---- show the pair ------------------------------------------------------
    LEA DX, M_LEAD
    CALL PRINT_MESSAGE
    MOV AL, [SI]
    CALL PRINT_HEX_BYTE

    LEA DX, M_LEAD
    CALL PRINT_MESSAGE
    MOV AL, [DI]
    CALL PRINT_HEX_BYTE
    CALL NEWLINE

    INC SI
    INC DI
    POP CX
    LOOP ENCODE_ONE

ENCODED:
    ; -------------------------------------------------------------------------
    ; THE LINE. THE BYTES ARE COPIED ACROSS AND ONE BIT OF ONE OF THEM IS
    ; INVERTED, WHICH IS ALL A SINGLE BIT FAULT EVER IS.
    ; -------------------------------------------------------------------------
    LEA SI, SENT
    LEA DI, RECEIVED
    MOV CX, HOWMANY
    JCXZ SENT_ALL

COPY_ONE:
    MOV AL, [SI]
    MOV [DI], AL
    INC SI
    INC DI
    LOOP COPY_ONE

SENT_ALL:
    LEA SI, RECEIVED
    MOV AL, [SI+2]
    XOR AL, DAMAGE
    MOV [SI+2], AL

    LEA DX, M_BREAK
    CALL PRINT_MESSAGE
    LEA DX, M_HEAD2
    CALL PRINT_MESSAGE

    ; -------------------------------------------------------------------------
    ; CHECKING. THE VERDICT IS TAKEN INTO BP FIRST, BECAUSE PRINTING THE BYTE
    ; WOULD REPLACE THE PARITY FLAG LONG BEFORE THE BRANCH ON IT.
    ; -------------------------------------------------------------------------
    LEA SI, RECEIVED
    MOV CX, HOWMANY
    JCXZ CHECKED

CHECK_ONE:
    PUSH CX

    MOV AL, [SI]
    OR  AL, AL
    MOV BP, 0                           ; Assume the byte survived
    JNP VERDICT_TAKEN                   ; Odd count, which is what was sent
    MOV BP, 1

VERDICT_TAKEN:
    LEA DX, M_LEAD
    CALL PRINT_MESSAGE
    MOV AL, [SI]
    CALL PRINT_HEX_BYTE

    OR  BP, BP
    JNZ SAY_REJECTED
    LEA DX, M_GOOD
    JMP SAY_VERDICT

SAY_REJECTED:
    LEA DX, M_BAD

SAY_VERDICT:
    CALL PRINT_MESSAGE

    INC SI
    POP CX
    LOOP CHECK_ONE

CHECKED:
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
; 1. WHY THE FLAG EXISTS AT ALL:
;    - The 8086 inherited it from the 8080, which drove serial lines that
;    - carried a parity bit per character. Counting the bits in software
;    - would have cost more than the whole transfer.
; 2. THE LOW BYTE ONLY:
;    - Parity is computed on the bottom eight bits of the result even when
;    - the operation was sixteen bits wide. A word is checked by testing
;    - each half separately.
; 3. WHAT IT CANNOT DO:
;    - Parity detects an odd number of flipped bits and nothing more. It
;    - never says which bit moved, and it never repairs anything, which
;    - is why real links use a checksum on top of it.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
