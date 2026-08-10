; =============================================================================
; TITLE: Direct Console Input and Output with 06h
; DESCRIPTION: One service that both reads and writes depending on what is in
;              DL, and returns immediately rather than waiting.
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
    M_OUT   DB 'Writing three characters with 06h: $'
    M_IN    DB 0DH, 0AH, 'Checking for a waiting key: $'
    M_NONE  DB 'nothing was waiting', 0DH, 0AH, '$'
    M_SOME  DB 'found $'
    CRLF    DB 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA DX, M_OUT
    MOV AH, 09H
    INT 21H

    ; -------------------------------------------------------------------------
    ; ANY VALUE IN DL EXCEPT FFH IS WRITTEN. THE SERVICE DOES NO PROCESSING AT
    ; ALL, WHICH IS WHY IT IS CALLED DIRECT: A CTRL-C TYPED DURING IT IS JUST
    ; A CHARACTER, AND A CONTROL CODE IS SENT AS ITSELF.
    ; -------------------------------------------------------------------------
    MOV DL, 'A'
    MOV AH, 06H
    INT 21H

    MOV DL, 'B'
    MOV AH, 06H
    INT 21H

    MOV DL, 'C'
    MOV AH, 06H
    INT 21H

    LEA DX, M_IN
    MOV AH, 09H
    INT 21H

    ; -------------------------------------------------------------------------
    ; FFH IN DL ASKS TO READ. THE SERVICE DOES NOT WAIT: IT RETURNS AT ONCE
    ; WITH THE ZERO FLAG SET WHEN NOTHING WAS TYPED, WHICH IS WHAT MAKES IT
    ; USABLE INSIDE A LOOP THAT HAS OTHER WORK TO DO.
    ; -------------------------------------------------------------------------
    MOV DL, 0FFH
    MOV AH, 06H
    INT 21H
    JZ  NOTHING_WAITING

    MOV BL, AL
    LEA DX, M_SOME
    MOV AH, 09H
    INT 21H
    MOV DL, BL
    MOV AH, 02H
    INT 21H
    LEA DX, CRLF
    MOV AH, 09H
    INT 21H
    JMP FINISH

NOTHING_WAITING:
    LEA DX, M_NONE
    MOV AH, 09H
    INT 21H

FINISH:
    MOV AH, 4CH
    INT 21H

END START

; =============================================================================
; TECHNICAL NOTES
; =============================================================================
; 1. FFH IS THE ONE VALUE THAT CANNOT BE PRINTED:
;    - Because it is reserved to mean read instead. Anything else is
;    - written, including nought.
; 2. NOT WAITING IS THE POINT:
;    - A game loop or a control program cannot stop and wait for a key.
;    - This service lets it ask whether one has arrived and carry on
;    - either way.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
