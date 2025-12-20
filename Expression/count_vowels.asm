;=============================================================================
; Program:     Count Vowels in String
; Description: Count the number of vowels (A, E, I, O, U) in a sentence.
;              Checks both uppercase and lowercase vowels.
; 
; Author:      Amey Thakur
; Repository:  https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
; License:     MIT License
;=============================================================================

.MODEL SMALL
.STACK 100H 
          
;-----------------------------------------------------------------------------
; DATA SEGMENT
;-----------------------------------------------------------------------------
.DATA
    STRING DB 10, 13, "The quick brown fox jumped over lazy sleeping dog$"
    VOWEL_COUNT DB ?                    ; Vowel count result
    MSG1 DB 10, 13, "Number of vowels are: $"
 
;-----------------------------------------------------------------------------
; CODE SEGMENT
;-----------------------------------------------------------------------------
.CODE
MAIN PROC
    ; Initialize Data Segment
    MOV AX, @DATA
    MOV DS, AX
    
    ;-------------------------------------------------------------------------
    ; Initialize Counter and Pointer
    ;-------------------------------------------------------------------------
    MOV SI, OFFSET STRING               ; Point to string
    MOV BL, 00                          ; Vowel counter
 
    ;-------------------------------------------------------------------------
    ; Main Loop: Check Each Character
    ;-------------------------------------------------------------------------
BACK: 
    MOV AL, [SI]                        ; Get character
    CMP AL, '$'                         ; End of string?
    JZ FINAL
    
    ; Check uppercase vowels
    CMP AL, 'A'
    JZ COUNT   
    CMP AL, 'E'
    JZ COUNT   
    CMP AL, 'I'
    JZ COUNT   
    CMP AL, 'O'
    JZ COUNT   
    CMP AL, 'U'
    JZ COUNT
    
    ; Check lowercase vowels
    CMP AL, 'a'
    JZ COUNT   
    CMP AL, 'e'
    JZ COUNT   
    CMP AL, 'i'
    JZ COUNT   
    CMP AL, 'o'
    JZ COUNT   
    CMP AL, 'u'
    JZ COUNT   
    
    INC SI                              ; Not a vowel, next character
    JMP BACK

    ;-------------------------------------------------------------------------
    ; Found Vowel: Increment Counter
    ;-------------------------------------------------------------------------
COUNT: 
    INC BL                              ; Increment vowel count
    INC SI                              ; Next character
    JMP BACK

    ;-------------------------------------------------------------------------
    ; Display Result
    ;-------------------------------------------------------------------------
FINAL: 
    LEA DX, MSG1
    MOV AH, 09H
    INT 21H
    
    ; Display count (2-digit)
    MOV AL, BL
    MOV AH, 0
    MOV DL, 10
    DIV DL                              ; AL = tens, AH = units
    
    ADD AL, 30H
    MOV DL, AL
    MOV CH, AH                          ; Save units
    MOV AH, 2H
    INT 21H
    
    MOV DL, CH
    ADD DL, 30H
    MOV AH, 2H
    INT 21H

    ;-------------------------------------------------------------------------
    ; Program Termination
    ;-------------------------------------------------------------------------
    MOV AH, 4CH
    INT 21H
MAIN ENDP
END MAIN

;=============================================================================
; VOWEL COUNTING NOTES:
; - English vowels: A, E, I, O, U (uppercase and lowercase)
; - Must check both cases
; - The sentence has: e(4) + u(1) + i(2) + o(4) + a(1) = 12+ vowels
;=============================================================================
