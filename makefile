proj4: proj4.lst
	gcc -m32 proj4.o -o proj4
	
proj4.lst: proj4.asm
	nasm -g -f elf -F dwarf proj4.asm
	
debug:
	gdb -tui --args proj4 input.txt
	
run:
	./proj4 input.txt