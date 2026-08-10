; =============================================================================
; TITLE: Swap the Nibbles of a Byte
; DESCRIPTION: Exchanges the high and low four bits of a byte using a single
;              four place rotate, and prints the result in hexadecimal.
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
    VALUE  DB 4AH                       ; 0100 1010
    MSG    DB 'Swapped: $'
    HEXOUT DB '00H', 0DH, 0AH, '$'
    HEXTAB DB '0123456789ABCDEF'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    ; Context setup
    MOV AX, @DATA
    MOV DS, AX

    MOV AL, VALUE
    ROL AL, 4                           ; A four place rotate swaps the nibbles
    MOV BL, AL                          ; Keep the result

    ; High nibble to ASCII
    MOV AL, BL
    SHR AL, 4
    LEA SI, HEXTAB
    XOR AH, AH
    ADD SI, AX
    MOV AL, [SI]
    MOV HEXOUT[0], AL

    ; Low nibble to ASCII
    MOV AL, BL
    AND AL, 0FH
    LEA SI, HEXTAB
    XOR AH, AH
    ADD SI, AX
    MOV AL, [SI]
    MOV HEXOUT[1], AL

    ; Report
    LEA DX, MSG
    MOV AH, 09H
    INT 21H
    LEA DX, HEXOUT
    MOV AH, 09H
    INT 21H

    ; End process
    MOV AH, 4CH
    INT 21H

END START

; =============================================================================
; TECHNICAL NOTES
; =============================================================================
; 1. WHY ROTATE RATHER THAN TWO SHIFTS:
;    - A rotate is a single instruction and loses nothing. Shifting left and
;      right into two registers and recombining them takes four instructions
;      and achieves exactly the same byte.
; 2. THE COUNT:
;    - The 8086 allows an immediate count of one, or a count in CL for
;      anything larger. Assemblers accept ROL AL, 4 and generate the CL form.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
