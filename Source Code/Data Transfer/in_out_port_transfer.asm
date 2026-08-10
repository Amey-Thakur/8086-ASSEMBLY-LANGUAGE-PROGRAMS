; =============================================================================
; TITLE: Moving Data Through a Port
; DESCRIPTION: Writes to a device port with OUT and reads it back with IN, the
;              only instructions that reach outside the memory address space.
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
    PATTERN  DB 0A5H
    PORT_NUM EQU 7                      ; The stepper motor port
    MSG_OUT  DB 'Sent to port 7:      $'
    MSG_IN   DB 'Read back from it:   $'
    MSG_FAR  DB 'Sent to port 03F8H:  $'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    ; -------------------------------------------------------------------------
    ; A PORT NUMBER BELOW 256 CAN BE WRITTEN AS AN IMMEDIATE.
    ; -------------------------------------------------------------------------
    MOV AL, PATTERN
    OUT PORT_NUM, AL

    LEA DX, MSG_OUT
    MOV AH, 09H
    INT 21H
    MOV AL, PATTERN
    XOR AH, AH
    CALL PRINT_HEX
    CALL NEWLINE

    MOV AL, 0
    IN  AL, PORT_NUM                    ; Read the same port back

    MOV BL, AL
    LEA DX, MSG_IN
    MOV AH, 09H
    INT 21H
    MOV AL, BL
    XOR AH, AH
    CALL PRINT_HEX
    CALL NEWLINE

    ; -------------------------------------------------------------------------
    ; ANYTHING ABOVE 255 HAS TO TRAVEL IN DX. 03F8H IS THE FIRST SERIAL PORT
    ; ON A PC, WHICH IS WHY THE FORM IS SO COMMON.
    ; -------------------------------------------------------------------------
    MOV DX, 03F8H
    MOV AL, 4DH
    OUT DX, AL

    LEA DX, MSG_FAR
    MOV AH, 09H
    INT 21H
    MOV AL, 4DH
    XOR AH, AH
    CALL PRINT_HEX
    CALL NEWLINE

    MOV AH, 4CH
    INT 21H

; -----------------------------------------------------------------------------
; PRINT_HEX
;
; Prints the value in AX as four hexadecimal digits followed by H.
; -----------------------------------------------------------------------------
PRINT_HEX PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX

    MOV BX, AX                          ; Keep the value; AX is needed for DOS
    MOV CX, 4                           ; Four nibbles, most significant first

PH_NEXT:
    ROL BX, 4                           ; Bring the next nibble to the bottom
    MOV DL, BL
    AND DL, 0FH

    ADD DL, '0'                         ; 0 to 9 sit just after '0'
    CMP DL, '9'
    JBE PH_EMIT
    ADD DL, 7                           ; A to F sit seven further on

PH_EMIT:
    MOV AH, 02H
    INT 21H
    LOOP PH_NEXT

    MOV DL, 'H'
    MOV AH, 02H
    INT 21H

    POP DX
    POP CX
    POP BX
    POP AX
    RET
PRINT_HEX ENDP

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
; 1. A SEPARATE ADDRESS SPACE:
;    - Ports are not memory. Port 7 and memory address 7 are unrelated,
;    - and only IN and OUT reach the port space.
; 2. THE IMMEDIATE LIMIT:
;    - The immediate form of the instruction has eight bits for the port
;    - number, so ports 0 to 255 can be named directly. For anything
;    - higher the number goes in DX, and only DX.
; 3. BYTES AND WORDS:
;    - IN AL and OUT AL move one byte; IN AX and OUT AX move two, which
;    - the hardware sees as two consecutive port numbers.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
