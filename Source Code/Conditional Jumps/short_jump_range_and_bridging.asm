; =============================================================================
; TITLE: The Range of a Conditional Jump
; DESCRIPTION: Explains the 128 byte reach of a conditional jump and shows the
;              standard way to branch further: invert the test and bridge.
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
    VALUE  DW 5
    M_NEAR DB 'The near branch was taken.', 0DH, 0AH, '$'
    M_FAR  DB 'The distant branch was reached by bridging.', 0DH, 0AH, '$'
    FILLER DB 300 DUP(0)                ; Enough to push the target out of reach

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    ; -------------------------------------------------------------------------
    ; A CONDITIONAL JUMP CARRIES ONE SIGNED BYTE OF DISPLACEMENT, SO IT CAN
    ; REACH 128 BYTES BACK OR 127 FORWARD. THIS ONE IS WELL INSIDE THAT.
    ; -------------------------------------------------------------------------
    MOV AX, VALUE
    CMP AX, 5
    JNE SKIP_NEAR

    LEA DX, M_NEAR
    MOV AH, 09H
    INT 21H

SKIP_NEAR:
    ; -------------------------------------------------------------------------
    ; WHEN THE TARGET IS TOO FAR, THE TEST IS INVERTED AND USED TO JUMP OVER
    ; AN UNCONDITIONAL JUMP, WHICH HAS A SIXTEEN BIT DISPLACEMENT AND CAN
    ; REACH ANYWHERE IN THE SEGMENT. EVERY ASSEMBLER DOES THIS BY HAND, AND
    ; MOST WILL DO IT FOR YOU IF ASKED.
    ; -------------------------------------------------------------------------
    MOV AX, VALUE
    CMP AX, 5
    JNE PAST_BRIDGE                     ; The inverted test, a short hop
    JMP DISTANT_TARGET                  ; The long jump it guards

PAST_BRIDGE:
    JMP FINISH

DISTANT_TARGET:
    LEA DX, M_FAR
    MOV AH, 09H
    INT 21H

FINISH:
    MOV AH, 4CH
    INT 21H

END START

; =============================================================================
; TECHNICAL NOTES
; =============================================================================
; 1. WHY ONLY ONE BYTE:
;    - A conditional jump is two bytes: the opcode and a signed
;    - displacement. Keeping it short mattered when memory was measured
;    - in kilobytes, and almost every branch is to somewhere close.
; 2. THE ERROR TO EXPECT:
;    - An assembler that cannot reach reports a relative jump out of
;    - range. The fix is always the same: invert and bridge.
; 3. LATER PROCESSORS:
;    - The 80386 added conditional jumps with a full displacement, so the
;    - bridge is only needed when the target really is the 8086.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
