; =============================================================================
; TITLE: Reverse the Bits of a Word
; DESCRIPTION: Reverses the bit order of a 16-bit value by shifting bits out of
;              one register and into another in the opposite direction.
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
    VALUE  DW 1234H                     ; 0001 0010 0011 0100
    MSG    DB 'Reversed: $'
    HEXOUT DB '0000H', 0DH, 0AH, '$'
    HEXTAB DB '0123456789ABCDEF'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    ; Context setup
    MOV AX, @DATA
    MOV DS, AX

    MOV SI, VALUE                       ; Source bits
    XOR DI, DI                          ; Destination, built up
    MOV CX, 16                          ; One pass per bit

    ; -------------------------------------------------------------------------
    ; REVERSAL
    ;
    ; Each pass takes the LOWEST bit of the source and puts it in at the
    ; BOTTOM of the destination, pushing what is already there upward. The
    ; first bit taken is therefore pushed up fifteen times and finishes at the
    ; top, which is what reverses the word.
    ; -------------------------------------------------------------------------
REVERSE_LOOP:
    SHR SI, 1                           ; Lowest source bit into CF
    RCL DI, 1                           ; CF into the bottom of the destination
    LOOP REVERSE_LOOP

    ; Convert the result to four hexadecimal digits
    MOV BX, DI
    LEA SI, HEXOUT
    MOV CX, 4

HEX_LOOP:
    MOV AX, BX
    MOV DX, 0
    ROL BX, 4                           ; Bring the next nibble down
    MOV AX, BX
    AND AX, 000FH
    LEA DI, HEXTAB
    ADD DI, AX
    MOV AL, [DI]
    MOV [SI], AL
    INC SI
    LOOP HEX_LOOP

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
; 1. WHY SHR PAIRS WITH RCL AND NOT RCR:
;    - SHR takes bits off the bottom of the source, so they arrive oldest
;      first. RCL puts each one in at the bottom of the destination and
;      pushes the earlier ones up, which lands the first bit at the top.
;    - Pairing SHR with RCR instead takes bits off the bottom and puts them
;      back at the top, moving each one down again on every later pass. That
;      copies the word rather than reversing it, and looks correct until the
;      result is compared against the input.
; 2. THE HEXADECIMAL CONVERSION:
;    - ROL by four brings each nibble into the low four bits in turn, most
;      significant first, which is the order the digits must be printed.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
