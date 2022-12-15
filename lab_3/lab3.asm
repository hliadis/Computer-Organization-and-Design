#ILIADIS ILIAS : 02523
#KOEN LEONARNTO : 02534

.data
string: .asciiz "Enter the string: "
.align 0 
array : .space 20
.text
.globl main

main:
	li $v0, 4
	la $a0, string
	syscall                # printf("%s", string);		
	
	li $v0, 8
	la $a0, string         # a0 = string
	li $a1, 19
	syscall	 	       # scanning the string 
	
	li $t2, 0
	la $t0, string
strlen:	                       # Counting how many letters the string has
	
	lb $t1, ($t0)          # t1 = *t0
	beqz $t1 ,EndStrlen    # if(t1 == '\0'){break}
	addi $t0, $t0, 1       # t0 =  t0 + 1(Next letter)
	addi $t2, $t2, 1       # t2 =  t2 + 1(Counter of the letters)
	j strlen      

EndStrlen:	
	addi $t2, $t2, -2    
	la $a0, string         # char * str
	li $a1, 0              # int i
	add $a2, $0, $t2       # int n 
		
	jal transposition
	
	li $v0 , 10
	syscall
	
transposition:
	addi $sp, $sp, -12            #Create space to stack
	sw $ra, 8($sp)                #Store ra and a1 to stack for later use
	sw $a1, 4($sp)
	
Print:
	bne $a1, $a2, ElsePrint       #if (a1 != a2){goto EndLoop}
	
	li $v0, 4                     #print string
	syscall
	
	j EndLoop
	
ElsePrint:

	add $t0, $a1, $0              #t0 = a0 
	sw $t0, 0($sp)                #store t0 to stack for later use.
	loop:
		bgt $t0, $a2, EndLoop #if (t0> a2){break;}
		
		add $t1, $t0, $a0
		lbu $t2, 0($t1)
		add $t3, $a1, $a0
		lbu $t4, 0($t3)
		sb $t4, 0($t1)
		sb $t2, 0($t3)        #swap 2 characters of the string
		
		addi $a1, $a1, 1
		jal transposition
		
		lw $t0, 0($sp)      
		lw $a1, 4($sp)        #load t0 and a1 from stack
		
		addu $t1, $t0, $a0
		lbu $t2, 0($t1)
		addu $t3, $a1, $a0
		lbu $t4, 0($t3)
		sb $t4, 0($t1)
		sb $t2, 0($t3)        #swap 2 characters of the string 
		
		
		addi $t0, $t0, 1
		sw $t0, 0($sp)        #save counter to stack 
		
		j loop
	EndLoop:
	
		lw $ra, 8($sp)
		addi $sp, $sp, 12
		jr $ra                #return 
	
#C Code:
		
##include <stdio.h>
##include <string.h>

#void swap(int x, int y, char* str) 
#{ 
#    char temp;
 
#    temp = str[x]; 
#    str[x] = str[y]; 
#    str[y] = temp; 
#} 

#void transposition(char *str, int i, int n) 
#{ 
#   int j;
 
#   if (i == n) 
#     printf("%s\n", str); 
#   else
#   { 
#       for (j = i; j <= n; j++) 
#       { 
#          swap(i, j, str); 
#          transposition(str, i+1, n); 
#          swap(i, j, str); 
#       } 
#   } 
#} 

#int main(int argc, char * argv[]) 
#{ 
#    	char str[15];
#	int n;

#	printf("Type the characters you want to transport: ");
#	scanf("%14s", str);

#    	n = strlen(str); 
#    	transposition(str, 0, n-1); 

#    	return 0; 
#} 