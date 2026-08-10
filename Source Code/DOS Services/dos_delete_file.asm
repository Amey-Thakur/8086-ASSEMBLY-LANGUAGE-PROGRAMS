; =============================================================================
; TITLE: Deleting a File
; DESCRIPTION: Removes a file and demonstrates that opening it afterwards
;              fails, which is how the deletion is confirmed.
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
    FILENAME DB 'TEMP.TXT', 0
    CONTENT  DB 'temporary'
    CONTLEN  EQU $ - CONTENT
    HANDLE   DW 0

    M_MADE   DB 'Created TEMP.TXT', 0DH, 0AH, '$'
    M_GONE   DB 'Deleted it.', 0DH, 0AH, '$'
    M_CONF   DB 'Opening it now fails, as it should.', 0DH, 0AH, '$'
    M_STILL  DB 'It is somehow still there.', 0DH, 0AH, '$'
    M_NODEL  DB 'The deletion failed.', 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    ; Make something to delete
    MOV AH, 3CH
    MOV CX, 0
    LEA DX, FILENAME
    INT 21H
    MOV HANDLE, AX

    MOV AH, 40H
    MOV BX, HANDLE
    MOV CX, CONTLEN
    LEA DX, CONTENT
    INT 21H

    MOV AH, 3EH
    MOV BX, HANDLE
    INT 21H

    LEA DX, M_MADE
    MOV AH, 09H
    INT 21H

    ; -------------------------------------------------------------------------
    ; SERVICE 41H DELETES BY NAME, NOT BY HANDLE, SO THE FILE MUST BE CLOSED
    ; FIRST. DELETING AN OPEN FILE IS REFUSED BY DOS AND BY EVERY OPERATING
    ; SYSTEM SINCE.
    ; -------------------------------------------------------------------------
    MOV AH, 41H
    LEA DX, FILENAME
    INT 21H
    JC  DELETE_FAILED

    LEA DX, M_GONE
    MOV AH, 09H
    INT 21H

    ; -------------------------------------------------------------------------
    ; THE PROOF: OPENING IT NOW SHOULD FAIL WITH THE CARRY FLAG SET AND ERROR
    ; TWO, FILE NOT FOUND, IN AX.
    ; -------------------------------------------------------------------------
    MOV AH, 3DH
    MOV AL, 0
    LEA DX, FILENAME
    INT 21H
    JNC STILL_THERE

    LEA DX, M_CONF
    MOV AH, 09H
    INT 21H
    JMP FINISH

STILL_THERE:
    MOV BX, AX
    MOV AH, 3EH
    INT 21H
    LEA DX, M_STILL
    MOV AH, 09H
    INT 21H
    JMP FINISH

DELETE_FAILED:
    LEA DX, M_NODEL
    MOV AH, 09H
    INT 21H

FINISH:
    MOV AH, 4CH
    INT 21H

END START

; =============================================================================
; TECHNICAL NOTES
; =============================================================================
; 1. BY NAME, NOT BY HANDLE:
;    - A handle refers to an open file, and an open file cannot be
;    - deleted. Closing first is not optional.
; 2. CONFIRMING RATHER THAN ASSUMING:
;    - The deletion reported success, and the program then checks that
;    - the file has genuinely gone. Trusting the first answer alone is
;    - how a program comes to believe something it never verified.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
