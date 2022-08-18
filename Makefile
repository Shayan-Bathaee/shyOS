all:
	nasm -f bin ./boot.asm -o boot.bin
	dd if=./message.txt >> boot.bin					# put our message into the binary file
	dd if=/dev/zero bs=512 count=1 >> boot.bin 		# write a whole sector just afer our message