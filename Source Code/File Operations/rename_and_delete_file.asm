; =============================================================================
; TITLE: Renaming And Deleting A File
; DESCRIPTION: Service 56h takes two names, one in DS:DX and one in ES:DI, and 41h removes a file outright.
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
    OLD_NAME DB 'DRAFT.TXT', 0
    NEW_NAME DB 'FINAL.TXT', 0
    OTHER    DB 'SPARE.TXT', 0
    ABSENT   DB 'GHOST.TXT', 0

    CONTENT  DB 'Something worth keeping'
    SPAN     EQU $ - CONTENT
    BUFFER   DB 40 DUP (0)

    M_TITLE DB 'Renaming and deleting, and the errors both can give', 0DH, 0AH, '$'
    M_MADE  DB 'Created DRAFT.TXT.', 0DH, 0AH, '$'
    M_REN   DB 'Renamed to FINAL.TXT.', 0DH, 0AH, '$'
    M_RENF  DB 'The rename failed, error $'
    M_GONE  DB 'DRAFT.TXT can no longer be opened, error $'
    M_STILL DB 'DRAFT.TXT still opens, which is wrong.', 0DH, 0AH, '$'
    M_KEPT  DB 'FINAL.TXT still holds: $'
    M_CLASH DB 0DH, 0AH, 'Renaming onto an existing name failed, error $'
    M_DEL   DB 0DH, 0AH, 'Deleted FINAL.TXT.', 0DH, 0AH, '$'
    M_DELF  DB 'Deleting GHOST.TXT failed, error $'
    M_NL    DB 0DH, 0AH, '$'
    M_WHY   DB 0DH, 0AH
            DB '56h is the only file service taking two names, so it is the '
            DB 'only one that needs ES as well as DS.', 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX
    MOV ES, AX                          ; 56h reads its second name through ES

    LEA DX, M_TITLE
    CALL PRINT_MESSAGE

    ; ---- a file to work on --------------------------------------------------
    LEA DX, OLD_NAME
    MOV CX, 0
    MOV AH, 3CH
    INT 21H
    JC FINISHED
    MOV BX, AX

    LEA DX, CONTENT
    MOV CX, SPAN
    MOV AH, 40H
    INT 21H

    MOV AH, 3EH
    INT 21H

    LEA DX, M_MADE
    CALL PRINT_MESSAGE

    ; ---- and a second one, to collide with later ----------------------------
    LEA DX, OTHER
    MOV CX, 0
    MOV AH, 3CH
    INT 21H
    MOV BX, AX
    MOV AH, 3EH
    INT 21H

    ; -------------------------------------------------------------------------
    ; THE RENAME. THE EXISTING NAME IS AT DS:DX AND THE NEW ONE AT ES:DI.
    ; -------------------------------------------------------------------------
    LEA DX, OLD_NAME
    LEA DI, NEW_NAME
    MOV AH, 56H
    INT 21H
    JC RENAME_FAILED

    LEA DX, M_REN
    CALL PRINT_MESSAGE
    JMP CHECK_OLD_GONE

RENAME_FAILED:
    MOV SI, AX
    LEA DX, M_RENF
    CALL PRINT_MESSAGE
    MOV AX, SI
    CALL PRINT_DECIMAL
    CALL NEWLINE

CHECK_OLD_GONE:
    ; -------------------------------------------------------------------------
    ; THE OLD NAME SHOULD NOW FAIL TO OPEN AND THE NEW ONE SHOULD HOLD WHAT WAS
    ; WRITTEN. BOTH ARE CHECKED, BECAUSE A RENAME THAT COPIED INSTEAD OF MOVING
    ; WOULD PASS THE SECOND TEST ON ITS OWN.
    ; -------------------------------------------------------------------------
    MOV AX, 3D00H
    LEA DX, OLD_NAME
    INT 21H
    JNC OLD_STILL_THERE

    MOV SI, AX
    LEA DX, M_GONE
    CALL PRINT_MESSAGE
    MOV AX, SI
    CALL PRINT_DECIMAL
    CALL NEWLINE
    JMP READ_NEW

OLD_STILL_THERE:
    MOV BX, AX
    MOV AH, 3EH
    INT 21H
    LEA DX, M_STILL
    CALL PRINT_MESSAGE

READ_NEW:
    MOV AX, 3D00H
    LEA DX, NEW_NAME
    INT 21H
    JC FINISHED
    MOV BX, AX

    LEA DX, BUFFER
    MOV CX, SPAN
    MOV AH, 3FH
    INT 21H
    MOV BP, AX

    MOV AH, 3EH
    INT 21H

    LEA DX, M_KEPT
    CALL PRINT_MESSAGE
    LEA SI, BUFFER
    MOV CX, BP
    CALL PRINT_TEXT
    CALL NEWLINE

    ; -------------------------------------------------------------------------
    ; RENAMING ONTO A NAME THAT EXISTS IS REFUSED RATHER THAN ALLOWED TO
    ; DESTROY THE OTHER FILE.
    ; -------------------------------------------------------------------------
    LEA DX, NEW_NAME
    LEA DI, OTHER
    MOV AH, 56H
    INT 21H
    JNC NO_CLASH

    MOV SI, AX
    LEA DX, M_CLASH
    CALL PRINT_MESSAGE
    MOV AX, SI
    CALL PRINT_DECIMAL
    CALL NEWLINE

NO_CLASH:
    ; ---- delete, and delete something that is not there ---------------------
    LEA DX, NEW_NAME
    MOV AH, 41H
    INT 21H
    JC FINISHED

    LEA DX, M_DEL
    CALL PRINT_MESSAGE

    LEA DX, ABSENT
    MOV AH, 41H
    INT 21H
    JNC EXPLAIN

    MOV SI, AX
    LEA DX, M_DELF
    CALL PRINT_MESSAGE
    MOV AX, SI
    CALL PRINT_DECIMAL
    CALL NEWLINE

EXPLAIN:
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
; 1. Two names, two segments:
;    - The old name is at DS:DX and the new one at ES:DI.
;    - A small model program must still set ES, even though it equals DS.
;    - Forgetting it makes the second name whatever happens to be at that offset elsewhere.
; 2. A rename moves, it does not copy:
;    - The old name must stop working and the contents must survive under the new one.
;    - Checking only the second of those would pass for a copy that left the original.
;    - Renaming across directories on the same drive is allowed and is still a move.
; 3. Both calls can fail:
;    - Renaming onto an existing name gives access denied rather than overwriting.
;    - Deleting something absent gives file not found.
;    - Neither is unusual enough to skip the carry check.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
