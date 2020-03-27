%include "common_code.asm"

extern printf
extern fopen

; system call codes
%define SYS_OPEN  5
%define SYS_CLOSE 6
%define SYS_CREAT 8
%define SYS_READ  3
%define SYS_WRITE 4
%define SYS_EXIT  1
%define STDIN     0
%define STDOUT    1

; Access modes while opening a file
%define O_RDONLY  0
%define O_WRONLY  1
%define O_RDWR    2

%define buff_size 1						; buffer length to read one character at a time (a character is one byte)
;-----------------------------------------------------------------------------------------------------------------------------

section .data
	filename dd 'input.txt', 0			; store filename from command line argument - TEMPORARY until program is done
	; had trouble getting GetCommandLine to work, will fix after more important things are working
	
	current_read times 100 dd 0			; array to store the value of the current entry from the input file
	newline_char dd 0Ah					; stores the ASCII code for the newline character
	file_length dd 0					; stores the number of entries in the input file       
	file_data times 1000 dd 0			; array to store each line in the input file
	format		db "%d",10,0
	
	testMsg db "The value of buffer is: ", 0
;-----------------------------------------------------------------------------------------------------------------------------

section .bss
	file_pointer resd 1					; holds a pointer to the open input file
	buffer resb buff_size				; stores the current character for saving into the current_read array
;-----------------------------------------------------------------------------------------------------------------------------

section .text
	global main
	
main:
	; Get filename from command argument and open
	call open_file
	
	; read the first line of the file which contains the number of entries in the file
	; need to clear the registers needed first
	xor ecx, ecx
	call read_line
	
	; getting the value out of current_read and printing it before working on other crap
	jmp exit


; open the file - store file descriptor in file_pointer
open_file:
	mov  eax, SYS_OPEN
	mov  ebx, filename
	mov  ecx, O_RDONLY
	mov  edx, 0700o
	int  80h                    
	
	mov  [file_pointer], eax
	ret
	
	
; Read a single character from the file
read_char:
	mov  eax, SYS_READ
	mov  ebx, [file_pointer]
	mov  ecx, buffer
	mov  edx, buff_size
	int  80h
	
	ret
	
	
; Read a single line by reading until the newline character is found
; stores all data read on the current line in current_read (array of 100 dwords)
read_line:
	; saving ecx for the counter - needed in order to index current_read
	Push_Regs ecx
	call read_char
	Pop_Regs ecx
	
	;0xA is newline character - read until it is found in buffer
	mov eax, [buffer]
	cmp eax, 0xA
	je line_finished
	
	; Character is one byte, so no multiplication is needed in indexing current_read
	mov [current_read+ecx], eax
	inc ecx
	jmp read_line
	
; When a newline character is found, it is followed by a carriage return, so one extra read should collect it
; out of the stream for the next line
line_finished:
	call read_char
	ret
	
; Subroutine to exit the program normally
exit:
	mov     EAX, SYS_EXIT       
    mov     EBX, 0                
    int     080h                    
	ret	
	