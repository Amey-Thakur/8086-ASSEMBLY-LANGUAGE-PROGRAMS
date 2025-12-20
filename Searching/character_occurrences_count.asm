;=============================================================================
; Program:     Character Occurrences Count
; Description: Scan a user-provided string to count the number of times 
;              a specific character appears.
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
    MSG1 DB 10,13,'Enter string: $'
    MSG2 DB 10,13,'Enter character to find: $'
    MSG3 DB 10,13,'Occurrences: $'
    MSG4 DB 10,13,'Character not found.$'
    
    COUNT DB 0
    SEARCH_CHAR DB ?
    
    ; Buffered input structure for DOS AH=0Ah
    BUFFER DB 100                       ; Max length
           DB ?                          ; Actual length (filled by DOS)
           DB 100 DUP('$')               ; Real data

;-----------------------------------------------------------------------------
; CODE SEGMENT
;-----------------------------------------------------------------------------
.CODE
MAIN PROC
    ; State initialization
    MOV AX, @DATA
    MOV DS, AX
    MOV ES, AX

    ; 1. Request Input String
    LEA DX, MSG1
    MOV AH, 09H
    INT 21H
    
    LEA DX, BUFFER
    MOV AH, 0AH
    INT 21H
    
    ; 2. Request Search Character
    LEA DX, MSG2
    MOV AH, 09H
    INT 21H
    
    MOV AH, 01H                         ; Read with echo
    INT 21H
    MOV SEARCH_CHAR, AL

    ; 3. Perform Scan
    LEA SI, BUFFER + 2                  ; Points to actual string start
    XOR CX, CX
    MOV CL, [BUFFER + 1]                ; Get actual length from buffer
    JCXZ FINISH                         ; If empty, exit
    
SCAN_LOOP:
    MOV AL, [SI]
    CMP AL, SEARCH_CHAR
    JNE NEXT_ITER
    INC COUNT                           ; Found one!
    
NEXT_ITER:
    INC SI
    LOOP SCAN_LOOP

    ; 4. Display Result
    CMP COUNT, 0
    JE NOT_FOUND
    
    LEA DX, MSG3
    MOV AH, 09H
    INT 21H
    
    ; Convert count to ASCII for display (assumes < 10 for simplicity)
    MOV DL, COUNT
    ADD DL, '0'
    MOV AH, 02H
    INT 21H
    JMP FINISH

NOT_FOUND:
    LEA DX, MSG4
    MOV AH, 09H
    INT 21H

FINISH:
    ; Terminate
    MOV AH, 4CH
    INT 21H
MAIN ENDP
END MAIN

;=============================================================================
; STRING SEARCH NOTES:
; - This implementation uses the DOS buffered input (Function 0Ah).
; - Byte-by-byte comparison is performed to build the frequency count.
; - Limitation: Only displays counts from 0 to 9 correctly.
;=============================================================================
