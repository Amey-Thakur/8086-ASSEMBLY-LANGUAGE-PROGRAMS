; =============================================================================
; TITLE: System Services and the Warm Boot
; DESCRIPTION: Calls the miscellaneous system service and shows the interrupt
;              that restarts the machine, which is how a program of last resort ends.
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
    M_WAIT  DB 'Asking INT 15h to wait, which returns at once here.', 0DH, 0AH, '$'
    M_OK    DB 'The carry flag came back clear, so the call succeeded.', 0DH, 0AH, '$'
    M_NO    DB 'The carry flag came back set, so the service is absent.', 0DH, 0AH, '$'
    M_BOOT  DB 'INT 19h would restart the machine. It is shown but not', 0DH, 0AH
            DB 'reached, because the program exits first.', 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA DX, M_WAIT
    MOV AH, 09H
    INT 21H

    ; -------------------------------------------------------------------------
    ; SERVICE 86H OF INT 15H WAITS FOR THE NUMBER OF MICROSECONDS IN CX:DX.
    ; ON A REAL MACHINE IT BLOCKS; HERE IT RETURNS IMMEDIATELY, BECAUSE A
    ; BROWSER CANNOT BE STOPPED FOR A HUNDREDTH OF A SECOND WITHOUT FREEZING
    ; EVERYTHING ELSE ON THE PAGE.
    ; -------------------------------------------------------------------------
    MOV AH, 86H
    MOV CX, 0
    MOV DX, 10000                       ; Ten thousand microseconds
    INT 15H

    JC  NOT_SUPPORTED

    LEA DX, M_OK
    JMP SHOW

NOT_SUPPORTED:
    LEA DX, M_NO

SHOW:
    MOV AH, 09H
    INT 21H

    LEA DX, M_BOOT
    MOV AH, 09H
    INT 21H

    ; -------------------------------------------------------------------------
    ; INT 19H IS THE WARM BOOT. IT IS LEFT HERE AS A COMMENT RATHER THAN AN
    ; INSTRUCTION, BECAUSE A PROGRAM THAT REBOOTS THE MACHINE ON EVERY RUN IS
    ; NOT ONE ANYBODY WANTS TO STUDY.
    ;
    ;     INT 19H
    ; -------------------------------------------------------------------------
    MOV AX, 4C00H
    INT 21H

END START

; =============================================================================
; TECHNICAL NOTES
; =============================================================================
; 1. THE CARRY FLAG REPORTS AVAILABILITY:
;    - Not every BIOS provides every service. A set carry after INT 15h
;    - means this one does not, and a program should carry on rather than
;    - assume it worked.
; 2. INT 19H IS NOT AN EXIT:
;    - It restarts the machine from the boot sector. Ending a program
;    - means service 4Ch; INT 19h is for a loader that has finished its
;    - job and is handing over.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
