.section .text
.global load
.type load, @function

load:
	add	a4, a0, zero // Initilize sum register a4 with 0x0
	add	a2, a0, a1
	add 	a3, a0, a1
loop: 	add 	a4, a3, a4
	addi 	a3, a3, 1
	blt 	a3, a2, loop // if a3 is less tha a2 , branch to label named <loop>
	add	a0, a4, zero
