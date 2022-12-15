
#ILIADIS ILIAS : 02523
#KOEN LEONARNTO : 02534

.data
string1: .asciiz "The substring is: " 
string2: .asciiz "The substring doesn't exist\n"
string3: .asciiz "\n"

.align 0
string: .space 60

.text
.globl main


main:
	li $v0, 8
	la $a0, string
	li $a1, 59
	syscall                # scanf("%59s")
	jal symmString
	
	move $a0 ,$v0
	li $v0, 1
	syscall                # printf("%d", $v0);
	
	li $v0, 10
	syscall	               # return(0);

symmString:
	move $t0, $a0
	li $t3, 0x0a	
loop1:	                       # Counting how many letters the string has
	
	lb $t1, ($t0)          # t1 = *t0
	beq $t1,$t3,EndLoop1   # if(t1 == '\0'){break}
	addi $t0, $t0, 1       # t0 =  t0 + 1(Next letter)
	addi $t2, $t2, 1       # t2 =  t2 + 1(Counter of the letters)
	j loop1             
	
EndLoop1:
        li $t1, 0              # string[] = \0(replace \n with \0)  
	sll $t0, $t2, 31       # We want to see the last bit of the counter
	li $t1, 0x80000000     # t1 = 0x80000000	
if1:
	bne $t0, $t1,EndIf1    # if(t0 == t1){return 0}(Because the string has odd num of letters)
	la $a0, string2
	li $v0, 4
	syscall                # printf("%s", string2)
	li $v0, 0              # v0 = 0(return 0)
	jr $ra
EndIf1:	
	
	srl $t2, $t2, 1        # t2 = t2 / 2
	move $t0, $a0          # t0 = a0(address of the char)
	li $t4, 1              # t4 = 1(counter)
loop2:
	lb $t1, ($t0)          # t1 = *t0
	add $t0, $t0, $t2      # t0 = t0 + t2
	lb $t3, ($t0)          # t3 = *t0(address of the symmetric char)
	sub $t0, $t0, $t2      # t0 = t0 - t2
	bne $t1, $t3, End1     # if(t1 != t3){return 0}
	addi $t0, $t0, 1       # t0 = t0 + 1(next char)
	beq $t4, $t2, End2     # if(t4 == t2){return 1}
	addi $t4, $t4, 1       # t4 = t4 + 1(counter++)
	j loop2 
EndLoop2:

End1:
	la $a0, string2
	li $v0, 4
	syscall                # printf("%s", string2);
	
	li $v0, 0
	jr $ra                 # return(0);
End2:
	la $t1, string         # t1 = string
	add $t1, $t1, $t2      # t1 = t1 + t2(the length of the substring)
	sb $0, ($t1)           # *t1 = '\0'
	la $a0, string1
	li $v0, 4
	syscall                # printf("%s", string1); 
	
	la $a0, string
	syscall                # printf("%s", string);
	
	la $a0, string3
	syscall                # printf("%s", string3);
	
	li $v0, 1
	jr $ra                 # return(1);
