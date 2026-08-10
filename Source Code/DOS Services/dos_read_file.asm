; =============================================================================
; TITLE: Opening a File and Reading It Back
; DESCRIPTION: Writes a file, then opens it again and reads its contents into
;              memory, which is where the handle really earns its keep.
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
    FILENAME DB 'DATA.TXT', 0

    CONTENT  DB 'The quick brown fox jumps over the lazy dog.'
    CONTLEN  EQU $ - CONTENT

    BUFFER   DB 80 DUP(0)
    HANDLE   DW 0

    M_WROTE  DB 'Wrote the file.', 0DH, 0AH, '$'
    M_READ   DB 'Read back $'
    M_BYTES  DB ' bytes:', 0DH, 0AH, '$'
    M_FAILED DB 'Something went wrong.', 0DH, 0AH, '$'
    CRLF     DB 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    ; ---- write it -----------------------------------------------------------
    MOV AH, 3CH
    MOV CX, 0
    LEA DX, FILENAME
    INT 21H
    JC  FAILED
    MOV HANDLE, AX

    MOV AH, 40H
    MOV BX, HANDLE
    MOV CX, CONTLEN
    LEA DX, CONTENT
    INT 21H
    JC  FAILED

    MOV AH, 3EH
    MOV BX, HANDLE
    INT 21H

    LEA DX, M_WROTE
    MOV AH, 09H
    INT 21H

    ; -------------------------------------------------------------------------
    ; SERVICE 3DH OPENS AN EXISTING FILE. AL SAYS WHAT ACCESS IS WANTED:
    ; NOUGHT FOR READING, ONE FOR WRITING, TWO FOR BOTH. IT FAILS RATHER THAN
    ; CREATING ANYTHING, WHICH IS THE DIFFERENCE FROM 3CH.
    ; -------------------------------------------------------------------------
    MOV AH, 3DH
    MOV AL, 0
    LEA DX, FILENAME
    INT 21H
    JC  FAILED
    MOV HANDLE, AX

    ; -------------------------------------------------------------------------
    ; SERVICE 3FH READS UP TO CX BYTES. AX COMES BACK WITH HOW MANY WERE
    ; ACTUALLY READ, WHICH IS FEWER AT THE END OF THE FILE AND NOUGHT ONCE
    ; THERE IS NOTHING LEFT. THAT IS HOW THE END OF A FILE IS DETECTED.
    ; -------------------------------------------------------------------------
    MOV AH, 3FH
    MOV BX, HANDLE
    MOV CX, 80
    LEA DX, BUFFER
    INT 21H
    JC  FAILED

    MOV BP, AX                          ; How many bytes arrived

    PUSH AX
    LEA DX, M_READ
    MOV AH, 09H
    INT 21H
    POP AX
    CALL PRINT_DECIMAL
    LEA DX, M_BYTES
    MOV AH, 09H
    INT 21H

    LEA SI, BUFFER
    MOV CX, BP
    CALL PRINT_TEXT
    LEA DX, CRLF
    MOV AH, 09H
    INT 21H

    MOV AH, 3EH
    MOV BX, HANDLE
    INT 21H
    JMP FINISH

FAILED:
    LEA DX, M_FAILED
    MOV AH, 09H
    INT 21H

FINISH:
    MOV AH, 4CH
    INT 21H

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
; 1. THE COUNT RETURNED IS THE ONE TO USE:
;    - Asking for eighty bytes and receiving forty three means the file
;    - held forty three. Printing the whole buffer would show whatever
;    - was in the rest of it.
; 2. A READ OF ZERO MEANS THE END:
;    - Not an error, and the carry flag stays clear. A loop that reads
;    - until AX comes back nought is how a whole file is consumed.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
