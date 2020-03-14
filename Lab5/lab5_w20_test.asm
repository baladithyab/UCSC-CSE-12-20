# Winter20 Lab5 Test File
#
#------------------------------------------------------------------------
# pop and push macros
.macro push(%reg)
	subi $sp $sp 4
	sw %reg 0($sp)
.end_macro 

.macro pop(%reg)
	lw %reg 0($sp)
	addi $sp $sp 4	
.end_macro

#------------------------------------------------------------------------
# print string

.macro print_str(%str)

    .data
    str_to_print: .asciiz %str

    .text
    push($a0)                        # push $a0 and $v0 to stack so
    push($v0)                         # values are not overwritten
    
    addiu $v0 $zero   4
    la    $a0 str_to_print
    syscall

    pop($v0)                        # pop $a0 and $v0 off stack
    pop($a0)
.end_macro

.macro printSRegContents(%str)
	print_str(%str)
	push($a0)                        # push $a0 and $v0 to stack so
        push($v0)                         # values are not overwritten
        
        li $v0 34
        move $a0 $s0
        syscall
        li $v0 11
        li $a0 ' '
        syscall
        
        li $v0 34
        move $a0 $s1
        syscall
        li $v0 11
        li $a0 ' '
        syscall
        
        li $v0 34
        move $a0 $s2
        syscall
        li $v0 11
        li $a0 ' '
        syscall
        
        li $v0 34
        move $a0 $s3
        syscall
        li $v0 11
        li $a0 ' '
        syscall
        
        li $v0 34
        move $a0 $s4
        syscall
        li $v0 11
        li $a0 ' '
        syscall
        
        li $v0 34
        move $a0 $s5
        syscall
        li $v0 11
        li $a0 ' '
        syscall
        
        li $v0 34
        move $a0 $s6
        syscall
        li $v0 11
        li $a0 ' '
        syscall
        
        li $v0 34
        move $a0 $s7
        syscall
        li $v0 11
        li $a0 ' '
        syscall
        
        pop($v0)                        # pop $a0 and $v0 off stack
        pop($a0)
.end_macro
#------------------------------------------------------------------------
# data segment
.data
red: .word 0x00FF0000
orange: .word 0x00FF0F00
yellow: .word 0x00FFFF00
green: .word 0x0000FF00
blue: .word 0x000000FF
purple: .word 0x00FF00FF
cyan: .word 0x0000FFFF
turquoise: .word 0x0000FF0F

.text
main: nop
#Fill up S registers to check for saved s registers
li $s0 0XFEEDBABE
li $s1 0XC0FFEEEE
li $s2 0XBABEDADE
li $s3 0XFEED0DAD
li $s4 0X00000000
li $s5 0XCAFECAFE
li $s6 0XBAD00DAD
li $s7 0XDAD00B0D


# 0. Clear_Bitmap test
    print_str("-----------------------\nClear_Bitmap Test:\n")
    print_str("Paints entire bitmap a dark green color\n\n")
    printSRegContents("S registers before: ")
    li $a0 0x00003F00 	#dark green
    jal clear_bitmap
    printSRegContents("\nS registers after: ")

# 1. Pixel tests
    print_str("\n\n-----------------------\nPixel Test:\n")
    print_str("draws single red pixel at (1,3) and green pixel at (122,127)\n\n")
    printSRegContents("S registers before: ")
    jal pixelTest
    printSRegContents("\nS registers after: ")
# 2. horizontal line
    print_str("\n\n-----------------------\nHorizontal Line Test:\n")
    print_str("draws orange horizontal line from (32, 10) to (122,10)\n\n")
    printSRegContents("S registers before: ")
    jal lineTest1
    printSRegContents("\nS registers after: ")
    
# 3. test vertical line
    print_str("\n\n-----------------------\nVertical Line Test:\n")
    print_str("draws purple verticle line from (16, 16) to (16,111)\n\n")
    jal lineTest2
    
# 4. test two diagonal line
    print_str("\n\n-----------------------\nDiagonal Line Test:\n")
    print_str("Draws two cyan blue diagonal lines from the corners in an X from corner to corner\n\n")
    jal lineTest3
    
# 5. square
    print_str("\n\n-----------------------\nSolid Square Test:\n")
    print_str("Draws a solid yellow square from (32, 32) to (96,96)\n\n")
    printSRegContents("S registers before: ")
    jal squareTest
    printSRegContents("\nS registers after: ")
    
# 6. Triangles
    print_str("\n\n-----------------------\nTriangle Test:\n")
    print_str("Draws a black Triangle between: A(33, 95), B(72,33), C(95,95)\n\n")
    printSRegContents("S registers before: ")
    jal triangleTest
    printSRegContents("\nS registers after: ")
    
#Exit when done
li $v0 10 
syscall

#------------------------------------------------------------------------
pixelTest: nop 
	push($ra)
	# red point at  (1,3)
	li $a0 0x00010003
    	lw $a1 red
    	jal draw_pixel
    	
    	li $a0 0x007A007F
    	lw $a1 green
    	jal draw_pixel
    	
    	print_str("\nGet_pixel($a0 = 0x00010001) should return 0x00ff0000\nYour get_pixel($a0 = 0x00010001) returns:")
    	li $a0 0x00010003
    	jal get_pixel
    	move $a0 $v0
    	li $v0 34
    	syscall
    	
    	print_str("\nGet_pixel($a0 = 0x007a007f) should return 0x0000ff00\nYour get_pixel($a0 = 0x007a007f) returns:")
    	li $a0 0x007A007F
    	jal get_pixel
    	move $a0 $v0
    	li $v0 34
    	syscall
    	
    	pop($ra)
    	jr $ra
    	
#------------------------------------------------------------------------  
lineTest1: nop 	
	push($ra)  
	# horizontal line (x20,A) (x7A, A)    
	li $a0 0x0020000A
	li $a1 0x007A000A
	lw $a2 orange
	jal draw_line
    
    	print_str("\nGet_pixel($a0 = 0x0020000a) should return 0x00ff0f00\nYour get_pixel($a0 = 0x0020000a) returns:")
    	li $a0 0x0020000A
    	jal get_pixel
    	move $a0 $v0
    	li $v0 34
    	syscall
    	
    	print_str("\nGet_pixel($a0 = 0x007a000a) should return 0x00ff0f00\nYour get_pixel($a0 = 0x007a000a) returns:")
    	li $a0 0x007A000A
    	jal get_pixel
    	move $a0 $v0
    	li $v0 34
    	syscall
    	
    	pop($ra)
    	jr $ra
    	
    	
#------------------------------------------------------------------------  
lineTest2: nop 	
	push($ra)
	# vertical line test
	li $a0 0x00100010
	li $a1 0x0010006F
	lw $a2 purple
	jal draw_line
    
    	print_str("\nGet_pixel($a0 = 0x00100010) should return 0x00ff00ff\nYour get_pixel($a0 = 0x00100010) returns:")
    	li $a0 0x00100010
    	jal get_pixel
    	move $a0 $v0
    	li $v0 34
    	syscall
    	
    	print_str("\nGet_pixel($a0 = 0x0010006f) should return 0x00ff00ff\nYour get_pixel($a0 = 0x0010006f) returns:")
    	li $a0 0x0010006F
    	jal get_pixel
    	move $a0 $v0
    	li $v0 34
    	syscall
    	
    	pop($ra)
    	jr $ra
    	
#------------------------------------------------------------------------  
lineTest3: nop 	
	push($ra)
	
	li $a0 0
	li $a1 0x007F007F
	lw $a2 cyan
	jal draw_line
	
	li $a0 0x0000007f
	li $a1 0x007f0000
	lw $a2 cyan
	jal draw_line
    
    	print_str("\nGet_pixel($a0 = 0x007f007f) should return 0x0000ffff\nYour get_pixel($a0 = 0x007f007f) returns:")
    	li $a0 0x007F007F
    	jal get_pixel
    	move $a0 $v0
    	li $v0 34
    	syscall
    	
    	print_str("\nGet_pixel($a0 = 0x007f0000) should return 0x0000ffff\nYour get_pixel($a0 = 0x007f0000) returns:")
    	li $a0 0x007f0000
    	jal get_pixel
    	move $a0 $v0
    	li $v0 34
    	syscall
    	
    	print_str("\nGet_pixel($a0 = 0x002f002f) should return 0x0000ffff\nYour get_pixel($a0 = 0x002f002f) returns:")
    	li $a0 0x00002F002F
    	jal get_pixel
    	move $a0 $v0
    	li $v0 34
    	syscall
    	
    	pop($ra)
    	jr $ra 


#------------------------------------------------------------------------  
squareTest: nop
	push($ra)
	
    	li $a0 0x00200020
    	li $a1 0x00600060
    	lw $a2 yellow
    	jal draw_rectangle
    	
    	print_str("\nGet_pixel($a0 = 0x00400040) should return 0x00ffff00\nYour get_pixel($a0 = 0x00400040) returns:")
    	li $a0 0x0000400040
    	jal get_pixel
    	move $a0 $v0
    	li $v0 34
    	syscall	
    
    	
    	print_str("\nGet_pixel($a0 = 0x00200060) should return 0x00ffff00\nYour get_pixel($a0 = 0x00200060) returns:")
    	li $a0 0x0000200060
    	jal get_pixel
    	move $a0 $v0
    	li $v0 34
    	syscall	
    
    	pop($ra)
    	jr $ra
    
#------------------------------------------------------------------------  
triangleTest: nop    
	push($ra)
	
	li $a0 0x0021005F
	li $a1 0x00400021
 	li $a2 0x005F005F
	li $a3 0
	jal draw_triangle
    	
    	print_str("\nGet_pixel($a0 = 0x00400021) should return 0x00000000\nYour get_pixel($a0 = 0x00400021) returns:")
    	li $a0 0x00400021
    	jal get_pixel
    	move $a0 $v0
    	li $v0 34
    	syscall	
    
    	
    	print_str("\nGet_pixel($a0 = 0x0000400040) should return 0x00ffff00\nYour get_pixel($a0 = 0x0000400040) returns:")
    	li $a0 0x0000400040
    	jal get_pixel
    	move $a0 $v0
    	li $v0 34
    	syscall	

	pop($ra)
	jr $ra

#------------------------------------------------------------------------  
# Be sure to use the lab5_w20_template.asm and rename it to Lab5.asm so it
# is included here!
# 
.include "Lab5.asm"
