;Emulate a fire monitoring system on emu8086 for the following specifications:
;Define the threshold for the temperature of two rooms
;Generate the temperature value in 8b resolution
;Switch on the alarm and display an alarm message when the threshold of either of the room is reached
;Remove the alarm and bring the temperature below the threshold

DATA SEGMENT
    num1 db ?
    num2 db ?
    MSG1 DB 10,13,"Threshold for 1: $"
    MSG2 DB 10,13,"Threshold for 2: $"
    MSG3 DB 10,13,"Alarm on! $"
    MSG4 DB 10,13,"Threshold reached! $"
    MSG5 DB 10,13,"Press '1' to restart. $"
    MSG6 DB 10,13,"Temp: $"
DATA ENDS

CODE SEGMENT
    ASSUME DS:DATA,CS:CODE
    
START: mov AX,data  ;intialize data segment
       mov DS,AX
       
       lea dx,msg1  ;load and display message 1
       mov ah,9h
       int 21h
       
       mov ah,1h    ;read character from console
       int 21h
       sub al,30h   ;convert from ASCII to BCD
       mov num1,al  ;store number as num1

       lea dx,msg2  ;load and display message 2
       mov ah,9h
       int 21h
       
       mov ah,1h    ;read character from console
       int 21h
       sub al,30h   ;convert from ASCII to BCD
       mov num2,al  ;store number as num2

 l0:   mov cl,0h    ;initial temperature at 0

 l1:   lea dx,msg6  ;load and display message 6
       mov ah,9h
       int 21h
 
       add cl,30h   ;ASCII adjust before displaying
       mov dl,cl
       mov ah,2h    ;display it
       int 21h
       sub cl,30h   ;ASCII adjust after display
       
       inc cl       ;temperature of the room increases
       cmp cl,num1  ;check against first threshold
       jge re

       cmp cl,num2  ;check against second threshold
       jge re

       jmp l1       ;continue increasing

re:    lea dx,msg3  ;load and display alarm is on
       mov ah,9h
       int 21h

       lea dx,msg4  ;load and display threshold
       mov ah,9h
       int 21h
       
       lea dx,msg5  ;load and display restart
       mov ah,9h
       int 21h

       mov ah,1h
       int 21h
       sub al,30h

       cmp al,1h
       je l0

 exit: mov ah,4ch
       int 21h