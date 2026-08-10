; =============================================================================
; TITLE: Random Access To Fixed Length Records
; DESCRIPTION: With records all the same size, the position of record n is just n times the size, so any one can be read or written.
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
    FILENAME DB 'STOCK.DAT', 0

    RECSIZE EQU 8                       ; Eight bytes to a record
    RECORDS EQU 5

    ; Five records of eight bytes, laid out as a name and nothing else, so the
    ; arithmetic is easy to follow in the output.
    ALL_REC DB 'BOLT-M6 '
            DB 'NUT-M6  '
            DB 'WASHER-A'
            DB 'SCREW-M4'
            DB 'RIVET-3M'

    REPLACE DB 'SPRING-2'
    BUFFER  DB RECSIZE DUP (0)

    M_TITLE DB 'Random access with fixed length records', 0DH, 0AH, '$'
    M_SETUP DB 'Wrote five records of eight bytes each.', 0DH, 0AH, '$'
    M_READ  DB 0DH, 0AH, 'Reading them out of order:', 0DH, 0AH, '$'
    M_REC   DB 'record $'
    M_AT    DB ' at offset $'
    M_IS    DB ' is $'
    M_OVER  DB 0DH, 0AH, 'Overwriting record 1 in place.', 0DH, 0AH, '$'
    M_AFTER DB 0DH, 0AH, 'All five records afterwards:', 0DH, 0AH, '$'
    M_WHY   DB 0DH, 0AH
            DB 'Only the fixed size makes this possible. Variable length '
            DB 'records need an index of where each one starts.', 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA DX, M_TITLE
    CALL PRINT_MESSAGE

    ; ---- lay the file down --------------------------------------------------
    LEA DX, FILENAME
    MOV CX, 0
    MOV AH, 3CH
    INT 21H
    JC FINISHED
    MOV BX, AX

    LEA DX, ALL_REC
    MOV CX, RECSIZE * RECORDS
    MOV AH, 40H
    INT 21H

    MOV AH, 3EH
    INT 21H

    LEA DX, M_SETUP
    CALL PRINT_MESSAGE

    ; -------------------------------------------------------------------------
    ; RECORDS 3, 0 AND 2, IN THAT ORDER, TO SHOW THAT THE ORDER OF ACCESS HAS
    ; NOTHING TO DO WITH THE ORDER ON DISC.
    ; -------------------------------------------------------------------------
    LEA DX, M_READ
    CALL PRINT_MESSAGE

    MOV SI, 3
    CALL READ_RECORD
    MOV SI, 0
    CALL READ_RECORD
    MOV SI, 2
    CALL READ_RECORD

    ; -------------------------------------------------------------------------
    ; A WRITE AT A COMPUTED POSITION REPLACES ONE RECORD AND LEAVES THE REST
    ; ALONE, WHICH IS WHAT A DATABASE UPDATE IS AT THE BOTTOM.
    ; -------------------------------------------------------------------------
    LEA DX, M_OVER
    CALL PRINT_MESSAGE

    MOV AX, 3D02H                       ; Read and write
    LEA DX, FILENAME
    INT 21H
    JC FINISHED
    MOV BX, AX

    MOV AX, 4200H                       ; From the start
    XOR CX, CX
    MOV DX, 1 * RECSIZE                 ; Record 1
    INT 21H

    LEA DX, REPLACE
    MOV CX, RECSIZE
    MOV AH, 40H
    INT 21H

    MOV AH, 3EH
    INT 21H

    LEA DX, M_AFTER
    CALL PRINT_MESSAGE

    XOR SI, SI
    MOV CX, RECORDS
SHOW_ALL:
    PUSH CX
    CALL READ_RECORD
    INC SI
    POP CX
    LOOP SHOW_ALL

    LEA DX, M_WHY
    CALL PRINT_MESSAGE

FINISHED:
    MOV AH, 4CH
    INT 21H

; -----------------------------------------------------------------------------
; READ_RECORD
;
; Reads record SI into BUFFER and prints it with the offset it came from.
;
; The offset is the record number times the record size, which is the whole
; idea. A shift would do for a power of two size; a multiply is general.
; -----------------------------------------------------------------------------
READ_RECORD PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH DI

    MOV AX, 3D00H
    LEA DX, FILENAME
    INT 21H
    JC RECORD_DONE
    MOV BX, AX

    MOV AX, SI
    MOV DI, RECSIZE
    MUL DI                              ; AX = record number times size
    MOV DI, AX                          ; Keep the offset for the report

    MOV AX, 4200H
    XOR CX, CX
    MOV DX, DI
    INT 21H

    LEA DX, BUFFER
    MOV CX, RECSIZE
    MOV AH, 3FH
    INT 21H

    MOV AH, 3EH
    INT 21H

    LEA DX, M_REC
    CALL PRINT_MESSAGE
    MOV AX, SI
    CALL PRINT_DECIMAL

    LEA DX, M_AT
    CALL PRINT_MESSAGE
    MOV AX, DI
    CALL PRINT_DECIMAL

    LEA DX, M_IS
    CALL PRINT_MESSAGE

    PUSH SI
    LEA SI, BUFFER
    MOV CX, RECSIZE
    CALL PRINT_TEXT
    POP SI
    CALL NEWLINE

RECORD_DONE:
    POP DI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
READ_RECORD ENDP

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
; 1. Fixed size is what buys random access:
;    - Record n begins at n times the record size, with no searching.
;    - Variable length records need an index, because there is no arithmetic for it.
;    - This is why so many early file formats padded every field to a fixed width.
; 2. Update in place:
;    - Opening for both, seeking, and writing replaces exactly one record.
;    - Nothing else in the file is read or rewritten.
;    - A short write here would corrupt the following record, so the count must be exact.
; 3. The multiply, not a shift:
;    - Eight bytes could be reached with three shifts left, and faster.
;    - MUL keeps the code correct if the record size ever changes to something odd.
;    - A named constant plus a multiply is the version that survives maintenance.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
