;=============================================================================
; Program:     String Concatenation
; Description: Concatenate two strings entered by the user.
;              Demonstrates string manipulation and procedures.
; 
; Author:      Amey Thakur
; Repository:  https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
; License:     MIT License
;=============================================================================

;-----------------------------------------------------------------------------
; MACRO: Print String
;-----------------------------------------------------------------------------
PRINT MACRO M
    MOV AH, 09H
    MOV DX, OFFSET M
    INT 21H
ENDM

.MODEL SMALL

;-----------------------------------------------------------------------------
; DATA SEGMENT
;-----------------------------------------------------------------------------
.DATA
    EMPTY DB 10, 13, "   $"
    STR1 DB 25, ?, 25 DUP('$')          ; First string buffer
    STR2 DB 25, ?, 25 DUP('$')          ; Second string buffer
    MSTRING DB 10, 13, "Enter the first string: $"
    MSTRING2 DB 10, 13, "Enter second string: $"
    MCONCAT DB 10, 13, "Concatenated string: $"

;-----------------------------------------------------------------------------
; CODE SEGMENT
;-----------------------------------------------------------------------------
.CODE
START:
    ; Initialize Data Segment
    MOV AX, @DATA
    MOV DS, AX

    ;-------------------------------------------------------------------------
    ; Input First String
    ;-------------------------------------------------------------------------
    PRINT MSTRING
    MOV AH, 0AH                         ; Buffered input
    LEA DX, STR1
    INT 21H
    
    ;-------------------------------------------------------------------------
    ; Input Second String
    ;-------------------------------------------------------------------------
    PRINT MSTRING2
    MOV AH, 0AH
    LEA DX, STR2
    INT 21H
    
    ;-------------------------------------------------------------------------
    ; Find End of First String
    ;-------------------------------------------------------------------------
    MOV CL, STR1+1                      ; Length of string1
    MOV SI, OFFSET STR1
NEXT:
    INC SI
    DEC CL
    JNZ NEXT
    INC SI
    INC SI                              ; SI now points to end of STR1
    
    ;-------------------------------------------------------------------------
    ; Copy Second String to End of First String
    ;-------------------------------------------------------------------------
    MOV DI, OFFSET STR2
    INC DI
    INC DI                              ; DI points to start of STR2 content
    
    MOV CL, STR2+1                      ; Length of string2
MOVE_NEXT:
    MOV AL, [DI]                        ; Get char from string2
    MOV [SI], AL                        ; Append to string1
    INC SI
    INC DI
    DEC CL
    JNZ MOVE_NEXT
    
    ;-------------------------------------------------------------------------
    ; Display Concatenated String
    ;-------------------------------------------------------------------------
    PRINT MCONCAT
    PRINT STR1+2                        ; Print from actual string content
    
    ;-------------------------------------------------------------------------
    ; Program Termination
    ;-------------------------------------------------------------------------
EXIT:
    MOV AH, 4CH
    INT 21H

END START

;=============================================================================
; STRING CONCATENATION NOTES:
; - "Hello" + "World" = "HelloWorld"
; - Find end of first string
; - Append second string character by character
; - Buffered input format: [max_len][actual_len][string_data...]
;=============================================================================
