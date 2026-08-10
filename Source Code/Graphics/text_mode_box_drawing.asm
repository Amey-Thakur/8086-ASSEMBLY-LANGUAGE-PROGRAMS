; =============================================================================
; TITLE: Drawing A Box In Text Mode
; DESCRIPTION: Builds a bordered box out of characters, emitted in reading order, with a caption centred inside it.
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
    INDENT  EQU 4                       ; Columns of margin on the left
    WIDE    EQU 20                      ; Interior width
    HIGH    EQU 5                       ; Interior height
    CAPTION DB '8086'
    CAP_LEN EQU $ - CAPTION

    M_TITLE DB 'A box built out of characters', 0DH, 0AH, 0DH, 0AH, '$'
    M_AFTER DB 0DH, 0AH, 'Interior 20 by 5, indented 4, caption centred on the '
            DB 'middle row.', 0DH, 0AH, '$'
    M_CORNER DB '+', '$'
    M_DASH   DB '-', '$'
    M_BAR    DB '|', '$'
    M_SPACE  DB ' ', '$'

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
    ; A TERMINAL CAN ONLY BE WRITTEN FORWARDS, SO THE PICTURE IS EMITTED ROW BY
    ; ROW: MARGIN, LEFT EDGE, INTERIOR, RIGHT EDGE, NEWLINE.
    ; -------------------------------------------------------------------------
    CALL EDGE_ROW

    ; -------------------------------------------------------------------------
    ; THE INTERIOR. THE MIDDLE ROW CARRIES THE CAPTION, SO ITS PADDING IS SPLIT
    ; EITHER SIDE OF IT. HIGH IS ODD, WHICH IS WHY THE MIDDLE IS EXACTLY
    ; (HIGH+1)/2 AND NEEDS NO ROUNDING DECISION.
    ; -------------------------------------------------------------------------
    MOV BP, 1                           ; Row number within the interior
    MOV CX, HIGH

EACH_INTERIOR_ROW:
    PUSH CX

    MOV CX, INDENT
    CALL SPACES
    LEA DX, M_BAR
    CALL PRINT_MESSAGE

    MOV AX, (HIGH + 1) / 2
    CMP BP, AX
    JE CAPTION_ROW

    MOV CX, WIDE
    CALL SPACES
    JMP CLOSE_ROW

CAPTION_ROW:
    ; Left padding is half of whatever the caption does not fill.
    MOV CX, WIDE - CAP_LEN
    SHR CX, 1
    CALL SPACES

    LEA SI, CAPTION
    MOV CX, CAP_LEN
    CALL PRINT_TEXT

    ; The right padding is what is left, worked out rather than assumed, so an
    ; odd difference cannot make the row a character short.
    MOV CX, WIDE - CAP_LEN
    MOV AX, CX
    SHR AX, 1
    SUB CX, AX
    CALL SPACES

CLOSE_ROW:
    LEA DX, M_BAR
    CALL PRINT_MESSAGE
    CALL NEWLINE

    INC BP
    POP CX
    LOOP EACH_INTERIOR_ROW

    CALL EDGE_ROW

    LEA DX, M_AFTER
    CALL PRINT_MESSAGE

    MOV AH, 4CH
    INT 21H

; -----------------------------------------------------------------------------
; EDGE_ROW
;
; Prints the margin, a corner, the horizontal run and the other corner.
; -----------------------------------------------------------------------------
EDGE_ROW PROC
    PUSH AX
    PUSH CX
    PUSH DX

    MOV CX, INDENT
    CALL SPACES

    LEA DX, M_CORNER
    CALL PRINT_MESSAGE

    MOV CX, WIDE
DASH_ONE:
    LEA DX, M_DASH
    CALL PRINT_MESSAGE
    LOOP DASH_ONE

    LEA DX, M_CORNER
    CALL PRINT_MESSAGE
    CALL NEWLINE

    POP DX
    POP CX
    POP AX
    RET
EDGE_ROW ENDP

; -----------------------------------------------------------------------------
; SPACES
;
; Prints CX spaces, and nothing at all when CX is zero. The guard matters:
; LOOP with CX at zero would run 65536 times.
; -----------------------------------------------------------------------------
SPACES PROC
    PUSH CX
    PUSH DX

    JCXZ SPACES_DONE

SPACE_ONE:
    LEA DX, M_SPACE
    CALL PRINT_MESSAGE
    LOOP SPACE_ONE

SPACES_DONE:
    POP DX
    POP CX
    RET
SPACES ENDP

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
; 1. Reading order, not drawing order:
;    - A transcript can only be written forwards, so every row is finished before the next begins.
;    - On a real screen the cursor could be jumped about instead, with service 02h of interrupt 10h.
;    - The sequential form has the advantage of working on a printer as well as a screen.
; 2. Centring without rounding trouble:
;    - The left padding is half the slack and the right padding is the remainder.
;    - Computing the second as slack minus the first cannot lose a character to rounding.
;    - Halving both would leave the box a column short whenever the slack was odd.
; 3. Guard every count that could be zero:
;    - SPACES is called with WIDE minus the caption length, which could be nothing.
;    - LOOP does not check first, so a count of zero runs 65536 times.
;    - JCXZ before the loop is the standard guard, and costs two bytes.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
