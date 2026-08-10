; =============================================================================
; TITLE: Opening A File That Already Exists
; DESCRIPTION: Service 3Dh with the three access modes, and the difference between opening and creating.
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
    FILENAME DB 'NOTES.TXT', 0
    MISSING  DB 'ABSENT.TXT', 0
    CONTENT  DB 'The quick brown fox'
    SPAN     EQU $ - CONTENT
    BUFFER   DB 40 DUP (0)

    M_TITLE DB 'Opening a file, and what happens when it is not there', 0DH, 0AH, '$'
    M_MADE  DB 'Created NOTES.TXT and wrote $'
    M_BYTES DB ' bytes.', 0DH, 0AH, '$'
    M_RDOK  DB 'Opened for reading, handle $'
    M_READ  DB 'Read back: $'
    M_WROK  DB 'Opened for writing, handle $'
    M_RWOK  DB 'Opened for both, handle $'
    M_FAIL  DB 'Opening ABSENT.TXT failed, error code $'
    M_MEAN  DB '  which is file not found.', 0DH, 0AH, '$'
    M_WHY   DB 0DH, 0AH
            DB '3Dh insists the file exists. 3Ch creates it, and destroys any '
            DB 'file of the same name.', 0DH, 0AH, '$'
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

    ; -------------------------------------------------------------------------
    ; SOMETHING HAS TO EXIST BEFORE IT CAN BE OPENED, SO THE FILE IS CREATED
    ; FIRST WITH 3CH. CX CARRIES THE ATTRIBUTE, AND ZERO MEANS AN ORDINARY FILE.
    ; -------------------------------------------------------------------------
    LEA DX, FILENAME
    MOV CX, 0
    MOV AH, 3CH
    INT 21H
    JC FINISHED                         ; Nothing else can work if this failed
    MOV BX, AX                          ; The handle

    LEA DX, CONTENT
    MOV CX, SPAN
    MOV AH, 40H
    INT 21H
    MOV SI, AX                          ; Bytes actually written

    MOV AH, 3EH
    INT 21H

    LEA DX, M_MADE
    CALL PRINT_MESSAGE
    MOV AX, SI
    CALL PRINT_DECIMAL
    LEA DX, M_BYTES
    CALL PRINT_MESSAGE

    ; -------------------------------------------------------------------------
    ; MODE 0 IS READ ONLY, 1 IS WRITE ONLY AND 2 IS BOTH. THE MODE GOES IN AL,
    ; WHICH IS WHY AH AND AL ARE SET TOGETHER WITH ONE MOV TO AX.
    ; -------------------------------------------------------------------------
    MOV AX, 3D00H                       ; 3Dh, mode 0
    LEA DX, FILENAME
    INT 21H
    JC FINISHED
    MOV BX, AX

    LEA DX, M_RDOK
    CALL PRINT_MESSAGE
    MOV AX, BX
    CALL PRINT_DECIMAL
    CALL NEWLINE

    LEA DX, BUFFER
    MOV CX, SPAN
    MOV AH, 3FH
    INT 21H
    MOV SI, AX

    LEA DX, M_READ
    CALL PRINT_MESSAGE
    LEA SI, BUFFER
    MOV CX, SPAN
    CALL PRINT_TEXT
    CALL NEWLINE

    MOV AH, 3EH
    INT 21H

    ; ---- mode 1, write only -------------------------------------------------
    MOV AX, 3D01H
    LEA DX, FILENAME
    INT 21H
    JC FINISHED
    MOV BX, AX

    LEA DX, M_WROK
    CALL PRINT_MESSAGE
    MOV AX, BX
    CALL PRINT_DECIMAL
    CALL NEWLINE

    MOV AH, 3EH
    INT 21H

    ; ---- mode 2, both -------------------------------------------------------
    MOV AX, 3D02H
    LEA DX, FILENAME
    INT 21H
    JC FINISHED
    MOV BX, AX

    LEA DX, M_RWOK
    CALL PRINT_MESSAGE
    MOV AX, BX
    CALL PRINT_DECIMAL
    CALL NEWLINE

    MOV AH, 3EH
    INT 21H

    ; -------------------------------------------------------------------------
    ; AND THE FAILING CASE. THE CARRY FLAG IS THE ONLY RELIABLE TEST: AX HOLDS
    ; A HANDLE WHEN IT SUCCEEDED AND AN ERROR CODE WHEN IT DID NOT, AND THE TWO
    ; RANGES OVERLAP.
    ; -------------------------------------------------------------------------
    MOV AX, 3D00H
    LEA DX, MISSING
    INT 21H
    JNC FINISHED                        ; It should not have opened

    MOV SI, AX                          ; The error code
    LEA DX, M_NL
    CALL PRINT_MESSAGE
    LEA DX, M_FAIL
    CALL PRINT_MESSAGE
    MOV AX, SI
    CALL PRINT_DECIMAL
    LEA DX, M_MEAN
    CALL PRINT_MESSAGE

    LEA DX, M_WHY
    CALL PRINT_MESSAGE

FINISHED:
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
; 1. The carry flag is the test:
;    - Carry clear means AX holds a handle; carry set means AX holds an error code.
;    - Handle 5 and error 5 are both possible, so AX alone cannot be tested.
;    - Every file service in this repository is checked with JC or JNC for that reason.
; 2. Three access modes:
;    - AL is 0 for read only, 1 for write only and 2 for both.
;    - MOV AX, 3D00H sets the service and the mode in one instruction.
;    - Writing to a handle opened read only fails with access denied, not silently.
; 3. 3Dh against 3Ch:
;    - 3Dh opens what exists and fails otherwise, which is what a reader wants.
;    - 3Ch creates, truncating any file of the same name to nothing.
;    - Using 3Ch where 3Dh was meant is how a program destroys the data it came to read.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
