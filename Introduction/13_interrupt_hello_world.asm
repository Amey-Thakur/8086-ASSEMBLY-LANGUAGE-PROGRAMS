ORG 100H            ;instruct compiler to make a simple segment .com file

;The sub-function that we are using
;does not modify the AH register on
;return, so we may set it only once

MOV AH,0EH          ;select sub-function

;INT 10H/0EH sub-function
;recieves an ASCII code of the 
;character that will be printer
;in AL register

MOV AL,'H'          ;ASCII code: 72
INT 10H             ;print it!

MOV AL,'e'          ;ASCII code: 101
INT 10H             ;print it!

MOV AL,'l'          ;ASCII code: 108
INT 10H             ;print it!

MOV AL,'l'          ;ASCII code: 108
INT 10H             ;print it!

MOV AL,'o'          ;ASCII code: 33
INT 10H             ;print it!             

MOV AL,' '          ;ASCII code: 5E
INT 10H             ;print it!

MOV AL,'W'          ;ASCII code: 87
INT 10H             ;print it!

MOV AL,'o'          ;ASCII code: 111
INT 10H             ;print it!                                       

MOV AL,'r'          ;ASCII code: 114
INT 10H             ;print it!

MOV AL,'l'          ;ASCII code: 108
INT 10H             ;print it!

MOV AL,'d'          ;ASCII code: 100
INT 10H             ;print it!

MOV AL,'!'          ;ASCII code: 33
INT 10H             ;print it!

RET                 ;returns to the operating system