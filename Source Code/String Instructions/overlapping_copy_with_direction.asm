; =============================================================================
; TITLE: Copying Overlapping Regions
; DESCRIPTION: Shifts a block of memory up by one position, which corrupts the
;              data if copied forward and works if copied backward.
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
    BUFFER  DB 'ABCDE', ' '                ; The space is where the shift will land
    LENGTH  EQU 5
    M_START DB 'Before:  $'
    M_AFTER DB 'Shifted: $'
    OUT_BUF DB 8 DUP('$')

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX
    MOV ES, AX

    LEA DX, M_START
    MOV AH, 09H
    INT 21H
    CALL SHOW_BUFFER

    ; -------------------------------------------------------------------------
    ; MOVING 'ABCDE' UP ONE PLACE MEANS THE DESTINATION OVERLAPS THE SOURCE.
    ; COPYING FORWARD WOULD WRITE A OVER B BEFORE B HAD BEEN READ, AND THE
    ; RESULT WOULD BE 'AAAAA'. STARTING AT THE END AND WORKING BACKWARD READS
    ; EVERY BYTE BEFORE ANYTHING OVERWRITES IT.
    ; -------------------------------------------------------------------------
    LEA SI, BUFFER
    ADD SI, LENGTH - 1                  ; The last byte of the source
    LEA DI, BUFFER
    ADD DI, LENGTH                      ; One place further on
    MOV CX, LENGTH

    STD                                 ; Count downward
    REP MOVSB
    CLD                                 ; Leave it as it was found

    MOV BYTE PTR BUFFER, '*'            ; Fill the hole left at the front

    LEA DX, M_AFTER
    MOV AH, 09H
    INT 21H
    CALL SHOW_BUFFER

    MOV AH, 4CH
    INT 21H

; -----------------------------------------------------------------------------
; SHOW_BUFFER
;
; Prints the six bytes of the buffer, terminated for the print service.
; -----------------------------------------------------------------------------
SHOW_BUFFER PROC
    PUSH AX
    PUSH CX
    PUSH DX
    PUSH SI
    PUSH DI

    LEA SI, BUFFER
    LEA DI, OUT_BUF
    MOV CX, 6
    CLD
    REP MOVSB
    MOV BYTE PTR [DI], '$'

    LEA DX, OUT_BUF
    MOV AH, 09H
    INT 21H
    CALL NEWLINE

    POP DI
    POP SI
    POP DX
    POP CX
    POP AX
    RET
SHOW_BUFFER ENDP

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
; 1. THE RULE FOR OVERLAP:
;    - Copy forward when the destination is below the source, backward
;    - when it is above. Getting it wrong produces a buffer filled with
;    - the first byte repeated.
; 2. PUT THE FLAG BACK:
;    - The direction flag is not local to a routine. Leaving it set
;    - breaks the next string operation anywhere in the program.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
