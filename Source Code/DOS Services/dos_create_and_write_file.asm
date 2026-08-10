; =============================================================================
; TITLE: Creating a File and Writing to It
; DESCRIPTION: Creates a file, writes a line into it and closes it, checking
;              the carry flag after every step.
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
    ; A file name for DOS is a zero terminated string, not a dollar
    ; terminated one. The two conventions sit side by side in the same
    ; program and mixing them is a common fault.
    FILENAME DB 'NOTES.TXT', 0

    CONTENT  DB '8086 Assembly Language Programs', 0DH, 0AH
             DB 'Written by Amey Thakur', 0DH, 0AH
    CONTLEN  EQU $ - CONTENT

    HANDLE   DW 0

    M_MADE   DB 'Created NOTES.TXT with handle $'
    M_WROTE  DB 'Wrote $'
    M_BYTES  DB ' bytes', 0DH, 0AH, '$'
    M_CLOSED DB 'Closed the file.', 0DH, 0AH, '$'
    M_FAILED DB 'The operation failed, error code $'
    CRLF     DB 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    ; -------------------------------------------------------------------------
    ; SERVICE 3CH CREATES A FILE, REPLACING ONE OF THE SAME NAME. CX HOLDS THE
    ; ATTRIBUTES, AND ZERO MEANS AN ORDINARY FILE. THE HANDLE COMES BACK IN
    ; AX AND IS NEEDED BY EVERY LATER OPERATION.
    ; -------------------------------------------------------------------------
    MOV AH, 3CH
    MOV CX, 0
    LEA DX, FILENAME
    INT 21H
    JC  FAILED

    MOV HANDLE, AX

    PUSH AX
    LEA DX, M_MADE
    MOV AH, 09H
    INT 21H
    POP AX
    CALL PRINT_DECIMAL
    LEA DX, CRLF
    MOV AH, 09H
    INT 21H

    ; -------------------------------------------------------------------------
    ; SERVICE 40H WRITES. BX IS THE HANDLE, CX HOW MANY BYTES, AND DS:DX WHERE
    ; THEY ARE. AX COMES BACK WITH HOW MANY WERE ACTUALLY WRITTEN, WHICH ON A
    ; FULL DISK IS FEWER THAN ASKED FOR AND IS WORTH CHECKING.
    ; -------------------------------------------------------------------------
    MOV AH, 40H
    MOV BX, HANDLE
    MOV CX, CONTLEN
    LEA DX, CONTENT
    INT 21H
    JC  FAILED

    PUSH AX
    LEA DX, M_WROTE
    MOV AH, 09H
    INT 21H
    POP AX
    CALL PRINT_DECIMAL
    LEA DX, M_BYTES
    MOV AH, 09H
    INT 21H

    ; -------------------------------------------------------------------------
    ; SERVICE 3EH CLOSES. UNTIL IT IS CALLED THE DIRECTORY ENTRY MAY NOT HAVE
    ; BEEN UPDATED, SO A PROGRAM THAT EXITS WITHOUT CLOSING CAN LEAVE A FILE
    ; OF LENGTH ZERO ON DISK.
    ; -------------------------------------------------------------------------
    MOV AH, 3EH
    MOV BX, HANDLE
    INT 21H
    JC  FAILED

    LEA DX, M_CLOSED
    MOV AH, 09H
    INT 21H
    JMP FINISH

FAILED:
    PUSH AX
    LEA DX, M_FAILED
    MOV AH, 09H
    INT 21H
    POP AX
    CALL PRINT_DECIMAL
    LEA DX, CRLF
    MOV AH, 09H
    INT 21H

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
; 1. THE CARRY FLAG IS THE VERDICT:
;    - Every file service clears it on success and sets it on failure,
;    - with the reason in AX. Checking it after each call is the whole of
;    - error handling in DOS.
; 2. ZERO TERMINATED, NOT DOLLAR TERMINATED:
;    - File names use a zero, printed strings use a dollar sign. Both
;    - appear in this program, and using the wrong one gives a file
;    - called NOTES.TXT$ or a name that never ends.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
