.text 
main: 
	li $v0,4
	la $a0, prompt
	syscall 

	li $v0, 5
	syscall
	move $s0, $v0
    
	bgtz $s0, ASCIIrisks
	
	li $v0, 4
	la $a0, error
	syscall
	
	j main

ASCIIrisks:
	li $t0, 0
	li $t1, 1
    
	j bigloop    
    
bigloop:
	beq $t0, $s0, exit
        addiu $t2, $s0, -1
        move $t3, $t0
        move $t4, $t0
        addiu $t0, $t0, 1
        j tabloop

tabloop:
	beq $t3, $t2, fencepost
        li $v0, 4
        la $a0, tab
        syscall
        addiu $t3, $t3, 1
        j tabloop

fencepost:
	li $v0, 1
	la $a0, ($t1)
	syscall
	addiu $t1, $t1, 1
	li $t5, 1
	j pyramid

pyramid:
	bgt $t5, $t4, prntNL
        li $v0, 4
	la $a0, astrsk
	syscall 
        li $v0, 4
        la $a0, tab
        syscall
        li $v0, 1
        la $a0, ($t1)
        syscall
        addiu $t1, $t1, 1
        addiu $t5, $t5, 1
        j pyramid


prntNL:
	li $v0, 4
	la $a0, newline
	syscall
	j bigloop

exit:
	li $v0, 10
	syscall

.data 
prompt: .asciiz "Enter the height of the triangle (must be greater than 0): "
error: .asciiz "Invalid Entry!\n"
tab: .asciiz "\t"
newline: .asciiz "\n"
astrsk: .asciiz "\t*"
