#Program that takes 2 hex nums as input. It keeps the first 2 M.S.bytes of s0 
#The L.S.Byte of t0 -> L.S.Byte of s0  
#The 2nd Byte of t0 is inversed -> 2nd Byte of s0
#
#Authors:ILIADIS ILIAS(AEM:2523) & KOEN LEONARDO(AEM:2534).

.text
.globl main

main:
	li $s0, 0x00112233
	andi $s0, $s0, 0xFFFF0000    #Store to s0 the 2 MSBytes
	
	li $t0, 0x1023B818
	andi $t1, $t0, 0xFF          #Store the to t1 LSB
	
	or $s0, $s0, $t1             #Store to s0 = s0 or t1 
	 
	andi $t1, $t0, 0x0000FF00    #Store to t1 the second byte of t0
	sll $t1, $t1, 16             #Move the byte to MSB position
	add $t0, $0, $0              #counter = 0
	add $t3, $0, $0              #inversed number set to 0
	li $t4, 7                    #load to t4 the num of the loops we want to execute
	
	loop:
		beq $t0, $t4, EndLoop  
		srl $t2, $t1, 31     #isolate M.S.Bit and store it as L.S.Bit
		sllv $t2, $t2, $t0   #shift the bit at the right position
		or $t3, $t2, $t3     #add the bit to $t3 to create the inversed num
		sll $t1, $t1, 1      #work with the next bit
		addi $t0, $t0, 1     #counter = counter + 1
		
		j loop
		
	EndLoop:
	
	sll $t3, $t3, 8              #Move the inversed byte to the right position
	add $s0, $s0, $t3            #Add it to the final number.
	
	move $a0, $s0                #print hex value of s0 
	li $v0, 34
	syscall
	
	li $v0, 10                   #return(0);
	syscall
