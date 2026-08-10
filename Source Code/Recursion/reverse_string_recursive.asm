; =============================================================================
; TITLE: Reversing a String by Recursion
; DESCRIPTION: Prints a string backward without a buffer, by using the call
;              stack itself to hold the characters until the unwinding.
; AUTHOR: Amey Thakur (https://github.com/Amey-Thakur)
; REPOSITORY: https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
; LICENSE: MIT License
; =============================================================================

.MODEL SMALL
.STACK 200H

; -----------------------------------------------------------------------------
; DATA SEGMENT
; -----------------------------------------------------------------------------
.DATA
    TEXT    DB 'RECURSION', 0
    M_IN    DB 'Forward:  RECURSION', 0DH, 0AH, '$'
    M_OUT   DB 'Backward: $'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA DX, M_IN
    MOV AH, 09H
    INT 21H

    LEA DX, M_OUT
    MOV AH, 09H
    INT 21H

    LEA AX, TEXT
    PUSH AX
    CALL REVERSE_PRINT
    ADD SP, 2

    CALL NEWLINE

    MOV AH, 4CH
    INT 21H

; -----------------------------------------------------------------------------
; REVERSE_PRINT
;
; [BP+4] points at a zero terminated string. Nothing is printed on the way
; down; every character is printed as the calls return, which reverses them.
; -----------------------------------------------------------------------------
REVERSE_PRINT PROC
    PUSH BP
    MOV BP, SP
    PUSH AX
    PUSH DX
    PUSH SI

    MOV SI, [BP+4]
    MOV AL, [SI]
    OR  AL, AL
    JZ  RP_RETURN                       ; The terminator ends the descent

    ; -------------------------------------------------------------------------
    ; GO ALL THE WAY TO THE END FIRST. EACH LEVEL STILL HOLDS ITS OWN
    ; CHARACTER IN ITS OWN FRAME, AND PRINTS IT ONLY AFTER THE DEEPER CALL
    ; HAS FINISHED. THE STACK IS DOING THE REVERSING.
    ; -------------------------------------------------------------------------
    INC SI
    PUSH SI
    CALL REVERSE_PRINT
    ADD SP, 2

    MOV SI, [BP+4]
    MOV DL, [SI]
    MOV AH, 02H
    INT 21H

RP_RETURN:
    POP SI
    POP DX
    POP AX
    POP BP
    RET
REVERSE_PRINT ENDP

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
; 1. NO BUFFER IS NEEDED:
;    - The characters are held in the frames of the calls that have not
;    - returned yet. The stack is the temporary storage, and it is freed
;    - automatically as the printing happens.
; 2. THE COST:
;    - One frame per character. For a long string that is real memory,
;    - which is why the two pointer method is preferred in practice.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
