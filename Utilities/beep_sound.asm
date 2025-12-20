; Program: Beep Sound
; Description: Generate beep sound using speaker
; Author: Amey Thakur
; Keywords: 8086 beep, sound assembly, speaker

.MODEL SMALL
.STACK 100H

.DATA
    MSG DB 'Beeping...$'

.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX
    
    LEA DX, MSG
    MOV AH, 09H
    INT 21H
    
    ; Method 1: Using INT 21H (Beep character)
    MOV DL, 07H      ; ASCII Bell character
    MOV AH, 02H
    INT 21H
    
    ; Method 2: Direct speaker control (for custom tones)
    ; Enable speaker
    ; IN AL, 61H
    ; OR AL, 03H
    ; OUT 61H, AL
    ; ... delay ...
    ; Disable speaker
    ; IN AL, 61H
    ; AND AL, 0FCH
    ; OUT 61H, AL
    
    MOV AH, 4CH
    INT 21H
MAIN ENDP
END MAIN
