;***************************************************
;
; Concatenation of strings in 8086 ALP

;macro for printing a string
print macro m
mov ah,09h
mov dx,offset m
int 21h
endm

.model small


;******  Data Segment ******
.data

empty db 10,13, "   $"
str1 db 25,?,25 dup('$')
str2 db 25,?,25 dup('$')

mstring db 10,13, "Enter the string: $"
mstring2 db 10,13, "Enter second string: $"
mconcat db 10,13, "Concatenated string: $"

;********** Code Segment ************

.code

start:
mov ax,@data
mov ds,ax

	   print mstring
	   call accept_string     
	   
	   ;storing string in str2
	   print mstring2
	   mov ah,0ah
	   lea dx,str2
	   int 21h
	   
 	   
	   mov cl,str1+1         ;length of string1 in cl
	   mov si,offset str1
next:  inc si
	   dec cl
	   jnz next
	   inc si
	   
	   inc si
	   mov di,offset str2
	   inc di
	   inc di
	   
	   mov cl,str2+1
move_next:
     	   
	       mov al,[di]
	       mov [si],al
		   inc si
		   inc di
		   dec cl
		   jnz move_next
		   
		   print mconcat
		   print str1+2

		   
exit:
mov ah,4ch       ;exit the program
int 21h


;accept procedure

accept proc near

mov ah,01
int 21h
ret
accept endp

display1 proc near

   mov al,bl
   mov bl,al
   and al,0f0h
   mov cl,04
   rol al,cl

   cmp al,09
   jbe number
   add al,07
number:  add al,30h
         mov dl,al
         mov ah,02
         int 21h

         mov al,bl
         and al,00fh
         cmp al,09
         jbe number2
         add al,07
number2:  add al,30h
          mov dl,al
          mov ah,02
          int 21h
ret
display1 endp



accept_string proc near

mov ah,0ah          ;accept string from user function
mov dx,offset str1  ; store the string in memory pointed by "DX"
int 21h
ret
accept_string endp

end start
end

