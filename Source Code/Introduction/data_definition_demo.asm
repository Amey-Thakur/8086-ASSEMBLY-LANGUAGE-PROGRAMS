; =============================================================================
; TITLE: Code And Data Are The Same Bytes
; DESCRIPTION: Lays out the machine code of three instructions as raw bytes,
;              names every one of them, and then runs the instructions they
;              spell so the two can be compared.
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
    ; The machine code of three instructions, written out by hand.
    ;
    ;     A0 08 01     MOV AL, [0108h]
    ;     8B 1E 09 01  MOV BX, [0109h]
    ;     C3           RET
    ;
    ; Nothing marks these as instructions. They are bytes in memory, and the
    ; only thing that would make them code is the instruction pointer arriving
    ; at them.
    OPCODES DB 0A0H, 008H, 001H, 08BH, 01EH, 009H, 001H, 0C3H
    HOWMANY EQU $ - OPCODES

    ; What each byte means, in the same order.
    N_0     DB 'opcode: MOV AL, from a direct address', 0DH, 0AH, '$'
    N_1     DB 'the low byte of that address', 0DH, 0AH, '$'
    N_2     DB 'the high byte, so the address is 0108h', 0DH, 0AH, '$'
    N_3     DB 'opcode: MOV a word register, from memory', 0DH, 0AH, '$'
    N_4     DB 'which register, and that it is a direct address', 0DH, 0AH, '$'
    N_5     DB 'the low byte of that address', 0DH, 0AH, '$'
    N_6     DB 'the high byte, so the address is 0109h', 0DH, 0AH, '$'
    N_7     DB 'opcode: RET', 0DH, 0AH, '$'
    MEANING DW N_0, N_1, N_2, N_3, N_4, N_5, N_6, N_7

    ; The data those instructions would have read, laid out the same way.
    VAR1    DB 7
    VAR2    DW 1234H

    M_TITLE DB 'Three instructions, written as the bytes they are', 0DH, 0AH, 0DH, 0AH, '$'
    M_BYTE  DB '  $'
    M_GAP   DB '    $'
    M_THEN  DB 0DH, 0AH, 'Now the same three instructions, assembled normally:'
            DB 0DH, 0AH, '$'
    M_AL    DB '  MOV AL, VAR1   gives AL = $'
    M_BX    DB '  MOV BX, VAR2   gives BX = $'
    M_NL    DB 0DH, 0AH, '$'
    M_WHY   DB 0DH, 0AH
            DB 'The eight bytes above and the two instructions below are the '
            DB 'same thing. Memory does not distinguish them; only the '
            DB 'instruction pointer does.', 0DH, 0AH, '$'
    M_MORE  DB 'That is why a stray jump into a data table executes it, and why '
            DB 'DB can be used to write an opcode the assembler does not know.'
            DB 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA DX, M_TITLE
    CALL SAY

    ; -------------------------------------------------------------------------
    ; EVERY BYTE, IN HEXADECIMAL, WITH WHAT IT MEANS. THE NAMES ARE HELD AS A
    ; TABLE OF ADDRESSES, SO THE LOOP INDEXES IT BY THE BYTE NUMBER DOUBLED.
    ; -------------------------------------------------------------------------
    XOR SI, SI
    MOV CX, HOWMANY

EACH_BYTE:
    LEA DX, M_BYTE
    CALL SAY

    MOV BL, OPCODES[SI]
    CALL PRINT_HEX_BYTE

    LEA DX, M_GAP
    CALL SAY

    MOV DI, SI
    SHL DI, 1
    MOV DX, MEANING[DI]
    CALL SAY

    INC SI
    LOOP EACH_BYTE

    ; -------------------------------------------------------------------------
    ; AND THE INSTRUCTIONS THEMSELVES. THESE ARE ASSEMBLED IN THE ORDINARY WAY
    ; AND READ THE SAME TWO VARIABLES THE BYTES ABOVE POINT AT.
    ; -------------------------------------------------------------------------
    LEA DX, M_THEN
    CALL SAY

    MOV AL, VAR1
    XOR AH, AH
    MOV BP, AX
    LEA DX, M_AL
    CALL SAY
    MOV AX, BP
    CALL PRINT_DECIMAL
    LEA DX, M_NL
    CALL SAY

    MOV BX, VAR2
    LEA DX, M_BX
    CALL SAY
    MOV AX, BX
    CALL PRINT_DECIMAL
    LEA DX, M_NL
    CALL SAY

    LEA DX, M_WHY
    CALL SAY
    LEA DX, M_MORE
    CALL SAY

    MOV AH, 4CH
    INT 21H

; -----------------------------------------------------------------------------
; PRINT_HEX_BYTE
;
; Prints BL as two hexadecimal digits. The high nibble is shifted down first,
; because printing the low one would destroy the byte.
; -----------------------------------------------------------------------------
PRINT_HEX_BYTE PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX

    MOV BH, BL                          ; Keep the whole byte
    MOV CL, 4
    SHR BL, CL
    CALL PRINT_NIBBLE

    MOV BL, BH
    AND BL, 0FH
    CALL PRINT_NIBBLE

    POP DX
    POP CX
    POP BX
    POP AX
    RET
PRINT_HEX_BYTE ENDP

; -----------------------------------------------------------------------------
; PRINT_NIBBLE
;
; Prints the low four bits of BL as one hexadecimal digit. Ten and above need
; seven added as well, because the letters do not follow the digits in ASCII.
; -----------------------------------------------------------------------------
PRINT_NIBBLE PROC
    PUSH AX
    PUSH DX

    MOV DL, BL
    AND DL, 0FH
    ADD DL, '0'
    CMP DL, '9'
    JBE NIBBLE_READY
    ADD DL, 7

NIBBLE_READY:
    MOV AH, 02H
    INT 21H

    POP DX
    POP AX
    RET
PRINT_NIBBLE ENDP

; -----------------------------------------------------------------------------
; SAY
;
; Prints the dollar terminated string at DS:DX, leaving AX alone.
; -----------------------------------------------------------------------------
SAY PROC
    PUSH AX
    MOV AH, 09H
    INT 21H
    POP AX
    RET
SAY ENDP

; -----------------------------------------------------------------------------
; PRINT_DECIMAL
;
; Prints the unsigned value in AX as decimal.
; -----------------------------------------------------------------------------
PRINT_DECIMAL PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX

    XOR CX, CX
    MOV BX, 10

SPLIT_ONE:
    XOR DX, DX
    DIV BX
    PUSH DX
    INC CX
    CMP AX, 0
    JNE SPLIT_ONE

EMIT_ONE:
    POP DX
    ADD DL, '0'
    MOV AH, 02H
    INT 21H
    LOOP EMIT_ONE

    POP DX
    POP CX
    POP BX
    POP AX
    RET
PRINT_DECIMAL ENDP

END START

; =============================================================================
; TECHNICAL NOTES
; =============================================================================
; 1. MEMORY DOES NOT KNOW THE DIFFERENCE:
;    - The eight bytes in OPCODES and the instructions further down are the
;      same thing expressed twice.
;    - Nothing in memory marks a byte as code. Only the instruction pointer
;      arriving at it makes it so.
;    - That is why a jump into a data table executes the table.
;
; 2. WHY DB IS STILL USEFUL:
;    - An assembler that does not know an opcode can still be made to emit it,
;      one byte at a time.
;    - The same trick embeds a lookup table, a jump table or a font inside the
;      code segment.
;    - It is also how self modifying code was written, before caches made that
;      unwise.
;
; 3. LITTLE ENDIAN, TWICE OVER:
;    - The address 0108h is stored as 08 then 01, low byte first.
;    - So is the word 1234h, stored as 34 then 12.
;    - Addresses and data follow the same rule, because to the processor there
;      is no difference between them.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
