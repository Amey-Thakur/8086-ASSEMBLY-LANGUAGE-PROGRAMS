; =============================================================================
; TITLE: Remove Duplicate Characters
; DESCRIPTION: Keeps the first occurrence of each character and discards the
;              rest, using a seen table rather than comparing every pair.
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
    SOURCE  DB 'programming assembly'
    SRCLEN  EQU $ - SOURCE
    RESULT  DB SRCLEN DUP(0)
    OUTLEN  DW 0
    SEEN    DB 256 DUP(0)
    M_IN    DB 'Input:  $'
    M_OUT   DB 'Output: $'

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
    LEA SI, SOURCE
    MOV CX, SRCLEN
    CALL PRINT_TEXT
    CALL NEWLINE

    ; -------------------------------------------------------------------------
    ; ONE TABLE ENTRY PER POSSIBLE CHARACTER, USED AS A SET. COMPARING EVERY
    ; CHARACTER AGAINST EVERY EARLIER ONE WOULD COST THE SQUARE OF THE LENGTH;
    ; THIS COSTS ONE PASS AND 256 BYTES.
    ; -------------------------------------------------------------------------
    LEA SI, SOURCE
    LEA DI, RESULT
    MOV CX, SRCLEN

FILTER:
    MOV AL, [SI]
    XOR BH, BH
    MOV BL, AL

    CMP BYTE PTR SEEN[BX], 0
    JNE SKIP_IT                         ; Already had one of these

    MOV BYTE PTR SEEN[BX], 1
    MOV [DI], AL
    INC DI
    INC WORD PTR OUTLEN

SKIP_IT:
    INC SI
    LOOP FILTER

    LEA DX, M_OUT
    MOV AH, 09H
    INT 21H
    LEA SI, RESULT
    MOV CX, OUTLEN
    CALL PRINT_TEXT
    CALL NEWLINE

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
; 1. THE TABLE IS A SET:
;    - Using the character itself as the index means membership is one
;    - read and one write, with no searching at all. It is the same idea
;    - as counting sort.
; 2. ORDER IS PRESERVED:
;    - The first occurrence of each character stays where it was, which
;    - sorting the string and removing neighbours would not achieve.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
