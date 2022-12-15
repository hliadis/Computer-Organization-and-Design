#Program that finds the union of given ranges. 
#When N1 < 0 program stops running.
#
#Authors:ILIADIS ILIAS(AEM:2523) & KOEN LEONARDO(AEM:2534).


.data
Name1: .asciiz "Please give N1:"
Name2: .asciiz "Please gine N2:"
Name3: .asciiz "\nThe final union of ranges is:["
Name4: .asciiz ","
Name5: .asciiz "]\n"

.text
.globl main

main:

	li $s0, 0 #min
	li $s1, 0 #max
	loop : 
		li $v0, 4
		la $a0, Name1      #printf("%s", Name1);
		syscall
		
		li $v0, 5
		syscall
		move $t0, $v0      #scanf("%d", $t0);
		
		bltz $t0, EndLoop  #if (t0 < 0){break;}
		
		li $v0, 4
		la $a0, Name2      #printf("%s", Name2);
		syscall
		
		li $v0, 5
		syscall
		move $t1, $v0      #scanf("%d", $t1);
		
		if1:
			bge $t0, $s0, EndIf1 #if(t0< s0(min) && t1 <= s1(max) && t1 >= s0(min) )
			bgt $t1, $s1, EndIf1
			blt $t1, $s0, EndIf1 
			move $s0, $t0	     #change min
			
			j loop
		EndIf1:
		
		if2:
			ble $t1, $s1, EndIf2 #if(t1>s1(max) && t0 >= s0(min) && t0 <= s1(max))
			blt $t0, $s0, EndIf2
			bgt $t0, $s1, EndIf2
			move $s1, $t1        #change max
			
			j loop
		EndIf2:
				
		sub $t2, $t1, $t0
		sub $t3, $s1, $s0             #find differences
		if3:
			bgt $t3, $t2,EndIf3   #if(t2(t1-t0) > t3(s1-s0))
			move $s1, $t1         #change max
			move $s0, $t0         #change min
		EndIf3:
		j loop	
		
	EndLoop:
	
	li $v0, 4
	la $a0, Name3
	syscall         #printf("The final union of ranges is:[");
	
	li $v0, 1
	move $a0, $s0
	syscall         #printf("%d", s0(min));
	
	li $v0, 4
	la $a0, Name4
	syscall         #printf(",");
	
	li $v0, 1
	move $a0, $s1
	syscall         #printf("%d", s1(max));
	
	li $v0, 4
	la $a0, Name5
	syscall         #printf("]\n");
	
	li $v0, 10
	syscall         #return(0)
