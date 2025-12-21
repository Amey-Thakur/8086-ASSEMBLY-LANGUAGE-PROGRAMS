; TITLE: Addition of 10 Bytes from Memory
; DESCRIPTION: Program to calculate the sum of 10 bytes stored in consecutive memory locations starting at 2000:0000.
; AUTHOR: Amey Thakur (https://github.com/Amey-Thakur)
; REPOSITORY: https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
; LICENSE: MIT License

CODE SEGMENT
    ASSUME CS:CODE
    
    ; --- Set up Memory Segment ---
    ; We set DS to 2000H to access physical memory at 20000H.
    MOV AX, 2000H
    MOV DS, AX
    
    ; --- Initialization ---
    MOV SI, 0000H                       ; Initialize pointer (offset) to 0000H
    MOV CX, 000AH                       ; Set loop counter to 10 (0AH)
    MOV AX, 0000H                       ; Clear AX (AL will store sum, AH will store carry)
    
    ; --- Addition Loop ---
ADD_LOOP:   
    ADD AL, [SI]                        ; Add byte at [DS:SI] to the accumulator AL
    JNC SKIP_CARRY                      ; jump if Carry Flag is not set (CF=0)
    INC AH                              ; If carry occurred (AL > 255), increment AH
    
SKIP_CARRY:   
    INC SI                              ; Move SI to the next memory address
    LOOP ADD_LOOP                       ; Decrement CX and repeat if CX != 0
    
    ; --- Store Final 16-bit Result ---
    ; The result is stored in [2000:000A] (Little-Endian: AL at 000A, AH at 000B)
    MOV [SI], AX                        
    
    ; --- Termination ---
    HLT                                 ; Halt the processor
    
CODE ENDS

; =============================================================================
; NOTES:
; 1. SEGMENTATION: 8086 uses 20-bit physical addresses. 
;    Address = (Segment << 4) + Offset. 2000:0000 = 20000H.
; 2. CARRY HANDLING: Since we are adding multiple 8-bit numbers, the sum can 
;    easily exceed 255 (the capacity of AL). AH tracks these overflows.
; 3. ACCUMULATOR: AX acts as the 16-bit accumulator. AL = Sum % 256, AH = Carry.
; 4. POINTERS: SI (Source Index) is used as a pointer to iterate through the 
;    memory array.
; 5. ENDIANNESS: When MOV [SI], AX executes, the 8086 stores the Low Byte (AL) 
;    at address SI and the High Byte (AH) at address SI+1.
; =============================================================================

END
