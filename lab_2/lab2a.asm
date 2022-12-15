
#ILIADIS ILIAS: 02523
#KOEN LEONARNTO: 02534

.data
array: .byte 0x70, 0x8c, 0xF3, 0x82, 0x1B, 0x9D, 0x52, 0x3C, 0x46
offset: .asciiz "Enter offset: "
pointer: .asciiz "Enter the position of the array: "
nbits: .asciiz "Enter nbits: "
.text
.globl main		
.macro scan_int (%x)
	li $v0, 5
	syscall
	move %x, $v0
.end_macro
.macro print_str(%x)
	li $v0, 4
	la $a0, ($t1)
	syscall
.end_macro
main: 
	la $t1, pointer
	print_str($t1)
	scan_int($t0)      #scan array position
	
	la $t1, offset
	print_str($t1)  
	scan_int($a1)      #offset
	
	la $t1, nbits
	print_str($t1)     
	scan_int($a2)      #nbits
	
	la $a0, array	   
	add $a0, $a0, $t0  #p
	jal bits_read
	
	li $v0, 35
	move $a0, $s0
	syscall
		
	li $v0, 10
	syscall

bits_read:
		bnez $a2, EndIf1
		add $s0, $0, $0
		jr $ra
		EndIf1:
		
		lbu $t0, 0($a0)      #load the byte to $t0
		addi $t1, $a1, 24    #t1 = a1 + 24 (a1 offset)
		sllv $t0, $t0, $t1   #the bits we want to shift to lose extra info
		li $t1, 32   	     #t1 = 32
		sub $t1, $t1, $a2    #(t1 = t1-a2(nbits))find the right position for the nums 
		srlv $t0, $t0, $t1   #Shift at the right position
		or $s0, $t0, $s0     #creating num, S0 will be the final num
		
		li $t0, 8            #t0 = 8
		sub $t0, $t0, $a1    #t0 = 8 - a1(offset)
		sub $a2, $a2, $t0    #a2(nbits) = a2(nbits) - t0
		li $t0, 8            #t0 = 8
		loop:
			addi $a0, $a0 , 1     #a0(pointer) =  a0(pointer) + 1
			lbu $t1 , 0($a0)      #t1 = *a0
			blt $a2, $t0, EndIf   #if(a2(nbits) < 8){break}
			sub $a2,  $a2, $t0    #a2(nbits) = a2(nbits) - 8 
			sllv $t1, $t1, $a2    #move left at the rigth position
			or $s0, $s0, $t1      #s0 = s0 | t1 creating final number
			
			j loop
		
		EndIf:
		sub $t0, $t0, $a2     #t0 = t0 - a2(nbits)
		srlv $t1, $t1, $t0    #shift at the rigth position         
		or $s0, $s0, $t1      #creating final number
		jr $ra
