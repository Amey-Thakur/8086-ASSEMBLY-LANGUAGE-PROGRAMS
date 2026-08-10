; =============================================================================
; TITLE: Copy a String with REP MOVSB
; DESCRIPTION: Copies a run of bytes in two instructions, the job MOVSB exists
;              for, and prints both the source and the copy.
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
    SOURCE  DB 'Amey Thakur$'
    LENGTH  EQU 11
    TARGET  DB 12 DUP('$')
    M_FROM  DB 'Source: $'
    M_TO    DB 'Copy:   $'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX
    MOV ES, AX                          ; MOVSB writes to ES:DI, always

    LEA DX, M_FROM
    MOV AH, 09H
    INT 21H
    LEA DX, SOURCE
    MOV AH, 09H
    INT 21H
    CALL NEWLINE

    ; -------------------------------------------------------------------------
    ; THREE THINGS HAVE TO BE SET BEFORE REP MOVSB: WHERE FROM IN SI, WHERE TO
    ; IN DI, AND HOW MANY IN CX. CLD SETS THE DIRECTION TO FORWARD, WHICH IS
    ; NOT RESET BETWEEN PROGRAMS AND SO CANNOT BE ASSUMED.
    ; -------------------------------------------------------------------------
    LEA SI, SOURCE
    LEA DI, TARGET
    MOV CX, LENGTH
    CLD
    REP MOVSB

    LEA DX, M_TO
    MOV AH, 09H
    INT 21H
    LEA DX, TARGET
    MOV AH, 09H
    INT 21H
    CALL NEWLINE

    MOV AH, 4CH
    INT 21H

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
; 1. THE COUNT IS IN ELEMENTS:
;    - MOVSB counts bytes and MOVSW counts words. Copying ten words means
;    - CX = 10, not 20. Using the byte count with the word form copies
;    - twice as much as intended.
; 2. ES IS NOT OPTIONAL:
;    - The destination is ES:DI and no override changes it. A program
;    - that sets only DS copies into whatever segment ES happened to
;    - hold.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
