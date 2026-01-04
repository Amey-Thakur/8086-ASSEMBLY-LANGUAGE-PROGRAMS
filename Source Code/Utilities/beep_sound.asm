; =============================================================================
; TITLE: Beep Sound Generation
; DESCRIPTION: A utility program to generate a beep sound using two methods: 
;              DOS Bell character and direct speaker control concepts.
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
    MSG DB 'Generating system beep sound...', 0DH, 0AH, '$'

; -----------------------------------------------------------------------------
; CODE SEGMENT
; -----------------------------------------------------------------------------
.CODE
MAIN PROC
    ; Initialize the Data Segment
    MOV AX, @DATA
    MOV DS, AX
    
    ; Display status message
    LEA DX, MSG
    MOV AH, 09H
    INT 21H
    
    ; --- Method 1: Using DOS Interrupt 21H ---
    ; Writing the ASCII Bell character (07H) to standard output triggers a beep.
    MOV DL, 07H      ; ASCII Bell character code
    MOV AH, 02H      ; DOS function: Display character in DL
    INT 21H          ; Execute interrupt
    
    ; --- Method 2: Conceptual Direct Speaker Control ---
    ; In professional hardware-level programming, we interact with the PIT 
    ; (Programmable Interval Timer) and Port 61H (System Control Port B).
    ; Below is the logic used to toggle the speaker manually (commented out).
    
    ; Step 1: Enable Speaker and Timer 2 Gate
    ; IN AL, 61H         ; Read current state of System Control Port B
    ; OR AL, 03H         ; Set bits 0 (Timer 2 Gate) and 1 (Speaker Data)
    ; OUT 61H, AL        ; Update Port 61H to turn on the speaker
    
    ; ... Insert delay loop here to produce a specific duration ...
    
    ; Step 2: Disable Speaker
    ; IN AL, 61H         ; Read current state again
    ; AND AL, 0FCH       ; Clear bits 0 and 1 (0FCH = 11111100B)
    ; OUT 61H, AL        ; Update Port 61H to turn off the speaker
    
    ; Clean termination
    MOV AH, 4CH
    INT 21H
MAIN ENDP
END MAIN

; =============================================================================
; TECHNICAL NOTES
; =============================================================================
; 1. BELL CHARACTER:
;    - ASCII 07H (known as BEL) is a standard control character.
;    - Sent to terminal/DOS console -> Default system beep.
; 2. SPEAKER INTERFACE:
;    - PC speaker is controlled by Intel 8253/8254 Timer and Port 61H.
;    - Bit 0 of Port 61H connects Timer 2 output to speaker.
;    - Bit 1 controls data signal.
; 3. REGISTER USAGE:
;    - DL: Holds the character to be printed.
;    - AH: DOS function selector.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
