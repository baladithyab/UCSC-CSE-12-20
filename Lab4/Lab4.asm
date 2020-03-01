##########################################################################
# Created by:  Balamurugan, Baladithya
#              bbalamur
#              29 February 2020
#
# Assignment:  Lab4: Syntax Checker
#              CSE 12, Computer Systems and Assembly Language
#              UC Santa Cruz, Winter 2020
# 
# Description: This program prints messages that are akin to errors of
#			   compilers stating brace mismatch.
# 
# Notes:       This program is intended to be run from the MARS IDE.
##########################################################################
#
# Psuedocode
#
# main:
# 	print out "You entered the file:"
# 	take input from program args ==> filename
# 	print filename 
# 	jump to fstNUM
# 	jump to isValidloop
# 	jump to strlen
# 	if filename.len > 20 branch to InvArg
# 	jump to openFile
# 	jump to readFile
3
# fstNUM:
# 	check if the first char of the filename is 65<=char<=90 || 97<=char<=122
# 	if neither branch to InvArg
# 	else return
#
# strlen:
# 	loop till null char and increment counter
# 	if null char return else continue
#
# isValidloop:
# 	loop till null char
# 	check if the char of the filename is 65<=char<=90 || 97<=char<=122 || 48<=char<=57
# 	if false branch to InvArg
#
# openFile:
# 	open file using syscall 13
# 	store address of open file to register
#
# readFile:
# 	syscall 14
# 	store the first 128 bytes to buffer
# 	store number of chars inputted to register
# 	if number of chars == 0 then jump to mismatch0
# 	if number of chars < 0 then jump to FRError
# 	jump to stackloop
#
# stackloop:
# 	if all chars scanned then return to readFile
# 	load bytes
# 	check if one of these: (,[,{
# 	if none then jump to popcheck
# 	jump to push
#
# popcheck:
# 	check if one of these: ),],}
# 	if none then jump to incrmt
# 	jump to poputil
#
# poputil:
# 	if sizeofstack == 0 branch to mismatch1
# 	jump to pop
# 	if (XOR popped == ( , char == )) != 0 branch to mismatch2
# 	if (XOR popped == [, char == ]) != 0 branch to mismatch2
# 	if (XOR popped == { , char == }) != 0 branch to mismatch2
# 	increment pair count
# 	jump to incrmt
#
# incrmt:
# 	add 1 to offset and add 1 to index counter
# 	jump to stackloop
#
# pop:
# 	sub 4 to $sp
# 	set word to char
# 	sub 4 to $sp
# 	set word to index counter
# 	increment sizeofstack
# push:
# 	add 4 to $sp
# 	load word to char
# 	add 4 to $sp
# 	load word to index counter
# 	deccrement sizeofstack
#
# mismatch0:
# 	if sizeofstack == 0 jump to success
# 	loop till sizeofstack == 0 and print out stack
#
# mismatch1:
# 	print msg informing of dangling brace at index
#
# mismatch2:
# 	print msg informing of mismatched braces at indecies
#
# success:
# 	print msg informing number of match brace pairs
#
# FRError:
# 	print "ERROR: Unable to read file."
#
# InvArg:
# 	print "ERROR: Invalid program argument."
#
# .data:
# 	contains asciiz entries, sizeofstack, count, index, buffer

.text
main:
	li  $v0, 4
	la  $a0, entry
	syscall
	
	li $s1, 20

	lw $s0, ($a1)
	
	la $a0, ($s0)
	li  $v0, 4
	syscall
	
	move $t0, $s0
	jal fstNum	
	move $t0, $s0
	jal isValidloop	
	move $t0, $s0	
	jal strlen
	
	li  $v0, 4
	la  $a0, newline
	syscall
	
	#li $v0, 1
	#la $a0, ($t1)
	#syscall
	
	ble $t0, $s1, InvArg
	
	#li  $v0, 4
	#la  $a0, newline
	#syscall
	
	li  $v0, 4
	la  $a0, newline
	syscall
	
	jal openFile
	j readFile
	
	j exit

push:
	subi $sp,$sp, 4
	sw $t2, ($sp)
	subi $sp,$sp, 4
	lw $t8, idx
	sw $t8, ($sp)
	lw $t9, size
	addi $t9, $t9, 1
	sw $t9, size
	j incrmt


pop:
	lw $t9, ($sp)
	addi $sp,$sp, 4
	lw $t8, ($sp)
	addi $sp,$sp, 4
	
	lw $t7, size
	subi $t7, $t7, 1
	sw $t7, size
	jr $ra
	
fstNum:
	lb $t1, 0($t0)
	sltiu $t2,$t1,65
	sgtu $t3,$t1,90
	or $t4, $t2, $t3
	
	sltiu $t2,$t1,97
	sgtu $t3,$t1,122
	or $t5, $t2, $t3
	
	and	$t2, $t4, $t5
	bnez $t2, InvArg
	jr $ra

strlen:
	li $t1, 0

lenloop:
	lb $t2, 0($t0)
	beqz $t2, return
	addi $t0, $t0, 1
	addi $t1, $t1, 1
	j lenloop

isValidloop:
	lb $t1, 0($t0)
	beqz $t1, return
	sltiu $t2,$t1,65
	sgtu $t3,$t1,90
	or $t4, $t2, $t3
	
	sltiu $t2,$t1,97
	sgtu $t3,$t1,122
	or $t5, $t2, $t3
	
	sltiu $t2,$t1,48
	sgtu $t3,$t1,57
	or $t6, $t2, $t3
	
	sne $t7, $t1, 46
	
	sne $t8, $t1, 95
	
	and	$t2, $t4, $t5
	and	$t3, $t2, $t6
	and	$t4, $t3, $t7
	and $t5, $t4, $t8
	bnez $t5, InvArg
	addi $t0, $t0, 1
	j isValidloop

openFile:
	li $v0, 13
	la $a0, ($s0)
	add $a1, $0, $0
	add $a2, $0, $0
	syscall
	add $s2, $v0, $0
	jr $ra

readFile:
	#li $t0, 0
	#li $t1, 128
	#jal emptybuffer
	
	li $v0, 14
	move $a0, $s2
	la $a1, bfr
	li $a2, 128
	syscall
	li $t0, 0
	la $s6, ($v0)
	#li  $v0, 1
	#la  $a0, ($s6)
	#syscall
	#li  $v0, 4
	#la  $a0, newline
	#syscall
	beq $s6, $0, mismatch0
	blt $s6, $0, FRError
	j stackloop

print:
	beq $t0, $t1, readFile
	lb $t3, bfr($t0)
	li  $v0, 11
	la  $a0, ($t3)
	syscall
	addi $t0, $t0, 1
	j print

stackloop:
	beq $t0, $s6, readFile
	lb $t2, bfr($t0)
	seq $t4, $t2, 40
	seq $t5, $t2, 91
	or $t6, $t4, $t5
	seq $t4, $t2, 123
	or $t5, $t6, $t4
	
	beqz $t5,popcheck
	j push
	
popcheck:
	seq $t4, $t2, 41
	seq $t5, $t2, 93
	or $t6, $t4, $t5
	seq $t4, $t2, 125
	or $t5, $t6, $t4
	
	beqz $t5,incrmt
	j poputil

incrmt:
	addi $t0, $t0, 1
	lw $t9, idx
	addi $t9, $t9, 1
	sw $t9, idx
	j stackloop

poputil:
	lw $t5, size
	beqz $t5, mismatch1
	jal pop
	#li  $v0, 11
	#la  $a0, ($t2)
	#syscall
	#li  $v0, 1
	#lw  $a0, idx
	#syscall
	#li  $v0, 11
	#la  $a0, ($t8)
	#syscall
	#li  $v0, 1
	#la  $a0, ($t9)
	#syscall
	#li  $v0, 4
	#la  $a0, newline
	#syscall
	seq $t3, $t8, 40
	seq $t4, $t2, 41
	#and $t5, $t3, $t4
	
	xor $t5, $t3, $t4
	bnez $t5, mismatch2
	
	seq $t3, $t8, 91
	seq $t4, $t2, 93
	#and $t6, $t3, $t4
	#or $t7, $5, $t6
	
	xor $t5, $t3, $t4
	bnez $t5, mismatch2
	
	seq $t3, $t8, 123
	seq $t4, $t2, 125
	#and $t6, $t3, $t4
	#or $t5,$t7,$t6
	
	xor $t5, $t3, $t4
	bnez $t5, mismatch2
	
	#seq $t5, $t8, $t3
	#beqz $t5, mismatch2
	
	lw $t9, count
	addi $t9, $t9, 1
	sw $t9, count
	
	j incrmt
	
emptybuffer:
	beq $t0, $t1, return
	sb $0, bfr($t0)
	addi $t0, $t0, 1
	j emptybuffer

mismatch0:
	lw $t4, size
	beqz $t4, success
	li  $v0, 4
	la  $a0, msmtch0
	syscall
	j msmtchloop

msmtchloop:
	lw $t6, size
	beqz $t6, exit
	jal pop
	li  $v0, 11
	la  $a0, ($t8)
	syscall
	j msmtchloop

mismatch1:
	li  $v0, 4
	la  $a0, msmtch1
	syscall
	li  $v0, 11
	la  $a0, ($t2)
	syscall
	li  $v0, 4
	la  $a0, msmtch1_2
	syscall
	li  $v0, 1
	lw  $a0, idx
	syscall
	li  $v0, 4
	la  $a0, newline
	syscall
	j exit

mismatch2:
	li  $v0, 4
	la  $a0, msmtch2
	syscall
	li  $v0, 11
	la  $a0, ($t8)
	syscall
	li  $v0, 4
	la  $a0, msmtch2_2
	syscall
	li  $v0, 1
	la  $a0, ($t9)
	syscall
	li  $v0, 4
	la  $a0, msmtch2_3
	syscall
	li  $v0, 11
	la  $a0, ($t2)
	syscall
	li  $v0, 4
	la  $a0, msmtch2_4
	syscall
	li  $v0, 1
	lw  $a0, idx
	syscall
	li  $v0, 4
	la  $a0, newline
	syscall
	j exit

success:
	li  $v0, 4
	la  $a0, scss
	syscall
	li  $v0, 1
	lw  $a0, count
	syscall
	li  $v0, 4
	la  $a0, scss_2
	syscall
	j exit

FRError:
	li  $v0, 4
	la  $a0, newline
	syscall
	
	li  $v0, 4
	la  $a0, newline
	syscall

	li  $v0, 4
	la  $a0, frerr
	syscall
	
	j exit

InvArg:
	li  $v0, 4
	la  $a0, newline
	syscall
	
	li  $v0, 4
	la  $a0, newline
	syscall

	li  $v0, 4
	la  $a0, invArg
	syscall
	
	j exit

return:
	jr $ra

exit:
	li $v0, 10
	syscall

.data
	bfr: .space 128
	idx: .word 0
	size: .word 0
	count: .word 0
	entry: .asciiz "You entered the file: \n"
	newline: .asciiz "\n"
	invArg: .asciiz "ERROR: Invalid program argument. \n"
	frerr: .asciiz "ERROR: Unable to read file. \n"
	msmtch0: .asciiz "ERROR - Brace(s) still on stack: "
	msmtch1: .asciiz "ERROR - There is a brace mismatch: "
	msmtch1_2: .asciiz " at index "
	msmtch2: .asciiz "ERROR - There is a brace mismatch: "
	msmtch2_2: .asciiz" at index "
	msmtch2_3: .asciiz" "
	msmtch2_4: .asciiz" at index "
	scss: .asciiz "SUCCESS: There are "
	scss_2: .asciiz " pairs of braces.\n"
