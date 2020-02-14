##########################################################################
# Created by:  Balamurugan, Baladithya
#              bbalamur
#              13 February 2020
#
# Assignment:  Lab3: ASCII-risks (Asterisks)
#              CSE 12, Computer Systems and Assembly Language
#              UC Santa Cruz, Winter 2020
# 
# Description: This program prints a symmetrical triangle to the console
#              after user input is taken
# 
# Notes:       This program is intended to be run from the MARS IDE.
##########################################################################
#
# Psuedocode
#
# main:
#     print out "Enter the height of the triangle (must be greater than 0): "
#     Take in input and store to a register
#     check if input is greater than 0
#         True: 
#             jump to block ASCIIrisks
#         False: 
#             print "Invalid Entry!\n"
#             jump to main
#
# ASCIrisks:
#     set two variables $t0 and $t1 to 0 and 1 (they are counters)
#     jump to bigloop
#
# bigloop:
#     check if $t0 is equal to stored variable $s0
#         True: 
#             jump to exit
#         False: 
#             add -1 to $s0 and set to $t2
#             copy $t0 to $t3
#             copy $t0 to $t4
#             add 1 to $t0
#             jump to tabloop
#
# tabloop:
#     check if $t3 is equal to $t2
#         True:
#             jump to fencepost
#         False:
#             print out "\t"
#             add 1 to $t3
#             jump to tabloop
#
# fencepost:
#     print $t1
#     add 1 to $t1
#     set $t5 to 1
#     jump to pyramid
#
# pyramid:
#     check if $t5 is grater than $t4
#         True:
#             jump to prntNL
#         False:
#             print astrsk
#             print tab
#             print $t1
#             add 1 to $t1
#             add 1 to $t5
#             jump to pyramid
#
# prntNL:
#     print newline
#     jump to bigloop
#
# exit:
#     syscall exit
#
# .data
#     contains all asciiz entries

.text 
main: 
    # print out prompt
	li $v0,4
	la $a0, prompt
	syscall 

    # get input and set to $s0
	li $v0, 5
	syscall
	move $s0, $v0
    
    # check if $s0 is greater than 0
	bgtz $s0, ASCIIrisks
	
    # print error
	li $v0, 4
	la $a0, error
	syscall
	
    # jump to main
	j main

ASCIIrisks:
    # set $t0 and $t1 to 0 and 1 respectively
	li $t0, 0
	li $t1, 1
    
    # jump to bigloop
	j bigloop    
    
bigloop:
    # check if $t0 == $s0
	beq $t0, $s0, exit
    # add -1 to $s0 and set to $t2
    # copy $t0 to $t3 and $t4
    # add 1 to $t0
    # jump to tabloop
    addiu $t2, $s0, -1
    move $t3, $t0
    move $t4, $t0
    addiu $t0, $t0, 1
    j tabloop

tabloop:
    # check if $t3 == $t2
	beq $t3, $t2, fencepost
    # print tab
    li $v0, 4
    la $a0, tab
    syscall
    # add 1 to $t3
    addiu $t3, $t3, 1
    j tabloop

fencepost:
    # print $t1
    # add 1 to $t1
    # set $t5 to 1
    # jump to pyramid
	li $v0, 1
	la $a0, ($t1)
	syscall
	addiu $t1, $t1, 1
	li $t5, 1
	j pyramid

pyramid:
    # check if $t5 > $t4
	bgt $t5, $t4, prntNL
    # print astrsk
    # print tab
    # print $t1
    # add 1 to $t1
    # add 1 to $t5
    # jump to pyramid
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
    # print newline
    # jump to bigloop
	li $v0, 4
	la $a0, newline
	syscall
	j bigloop

exit:
    # EXIT
	li $v0, 10
	syscall

.data 
prompt: .asciiz "Enter the height of the triangle (must be greater than 0): "
error: .asciiz "Invalid Entry!\n"
tab: .asciiz "\t"
newline: .asciiz "\n"
astrsk: .asciiz "\t*"
