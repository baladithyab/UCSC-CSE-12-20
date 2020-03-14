##########################################################################
# Created by:  Balamurugan, Baladithya
#              bbalamur
#              29 February 2020
#
# Assignment:  Lab 5: Functions and Graphics
#              CSE 12, Computer Systems and Assembly Language
#              UC Santa Cruz, Winter 2020
# 
# Description: This program uses the in-built bitmap display in MARS to 
#			   draw specific shapes
# 
# Notes:       This program is intended to be run from the MARS IDE.
##########################################################################
#
# Psuedocode:
#
# macro push:
# 	add 4 to $sp
# 	load word to char
#
# macro pop:
# 	sub 4 to $sp
# 	set word to char
#
# macro getCoordinates:
# 	and with 0xFF to get y
# 	shift right 16 bytes to get x
#
# macro formatCoordinates:
# 	shift left to format x
# 	add y to format y
#
# .data
# 	originAddress: .word 0xFFFF0000
# 	endAddress: .word 0xFFFFFFFC
#
# .text	
# 	syscall 10
#
# clear_bitmap:
# 	from originAddress to endAddress increment by 4
# 	store color at each address
#
# draw_pixel:
# 	getCoordinates => column row
# 	pos = [(row * row_size) + column] * 4 + originAddress
# 	store color at pos
#
# get_pixel:
# 	getCoordinates => column row
# 	pos = [(row * row_size) + column] * 4 + originAddress
# 	load color at pos
#
# draw_line:
# 	getCoordinates => x0 y0
# 	getCoordinates => x1 y1
# 	dx =  abs(x1-x0);
# 	sx = x0<x1 ? 1 : -1;
# 	dy = -abs(y1-y0);
# 	sy = y0<y1 ? 1 : -1;
# 	err = dx+dy;  /* error value e_xy */
# 	while (true)   /* loop */
# 		formatCoordinates => a0
# 		draw_pixel
# 		if (x0==x1 && y0==y1) break;
# 		e2 = 2*err;
# 		if (e2 >= dy) 
# 			err += dy; /* e_xy+e_x > 0 */
# 			x0 += sx;
# 		end if
# 		if (e2 <= dx) /* e_xy+e_y < 0 */
# 			err += dx;
# 			y0 += sy;
# 		end if
# 	end while
#
# draw_rectangle:
# 	getCoordinates => x0 y0
# 	getCoordinates => x1 y1
# 	formatCoordinates => a1 x1 y0
#
# 	while y0<y1
# 		draw_line => a0 a1
# 		a0 += 0x1
# 		a1 += 0x1
# 		y0 += 1
#
# draw_triangle:
# 	a = a0
# 	b = a1
# 	c = a2
# 	color = a3
#
# 	draw_line a b color
# 	draw_line a c color
# 	draw_line b c color
#
# Macro that stores the value in %reg on the stack 
#  and moves the stack pointer.
.macro push(%reg)
	subi $sp,$sp, 4
	sw %reg, ($sp)
.end_macro 

# Macro takes the value on the top of the stack and 
#  loads it into %reg then moves the stack pointer.
.macro pop(%reg)
	lw %reg, ($sp)
	addi $sp,$sp, 4
.end_macro

# Macro that takes as input coordinates in the format
# (0x00XX00YY) and returns 0x000000XX in %x and 
# returns 0x000000YY in %y
.macro getCoordinates(%input %x %y)
	and %y, %input, 0x000000ff
	srl %x, %input, 16
.end_macro

# Macro that takes Coordinates in (%x,%y) where
# %x = 0x000000XX and %y= 0x000000YY and
# returns %output = (0x00XX00YY)
.macro formatCoordinates(%output %x %y)
	sll %output,%x, 16
	add %output, %output, %y
.end_macro 

.data
originAddress: .word 0xFFFF0000
endAddress: .word 0xFFFFFFFC

.text
j done
    
    done: nop
    li $v0 10 
    syscall

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#  Subroutines defined below
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#*****************************************************
# clear_bitmap:
#  Given a clor in $a0, sets all pixels in the display to
#  that color.	
#-----------------------------------------------------
# $a0 =  color of pixel
#*****************************************************
clear_bitmap: nop
	lw $t0, originAddress
	lw $t1, endAddress
	cbloop:
		beq $t0,$t1,cbloopend
		sw $a0, ($t0)
		addi $t0,$t0,4
		j cbloop
	cbloopend:
		jr $ra
	
#*****************************************************
# draw_pixel:
#  Given a coordinate in $a0, sets corresponding value
#  in memory to the color given by $a1
#  [(row * row_size) + column] to locate the correct pixel to color
#-----------------------------------------------------
# $a0 = coordinates of pixel in format (0x00XX00YY)
# $a1 = color of pixel
#*****************************************************
draw_pixel: nop
	push($t0)
	push($t1)
	getCoordinates($a0,$t0,$t1)
	mul $t1,$t1,128
	add $t1,$t1,$t0
	mul $t1,$t1,4
	lw $t0, originAddress
	add $t0,$t1, $t0
	sw $a1, ($t0)
	pop($t1)
	pop($t0)
	jr $ra
#*****************************************************
# get_pixel:
#  Given a coordinate, returns the color of that pixel	
#-----------------------------------------------------
# $a0 = coordinates of pixel in format (0x00XX00YY)
# returns pixel color in $v0	
#*****************************************************
get_pixel: nop
	push($t0)
	push($t1)
	getCoordinates($a0,$t0,$t1)
	mul $t1,$t1,128
	add $t1,$t1,$t0
	mul $t1,$t1,4
	lw $t0, originAddress
	add $t0,$t1, $t0
	lw $v0, ($t0)
	pop($t1)
	pop($t0)
	jr $ra
	

#***********************************************
# draw_line:
#  Given two coordinates, draws a line between them 
#  using Bresenham's incremental error line algorithm	
#-----------------------------------------------------
# 	Bresenham's line algorithm (incremental error)
# plotLine(int x0, int y0, int x1, int y1)
#    dx =  abs(x1-x0);
#    sx = x0<x1 ? 1 : -1;
#    dy = -abs(y1-y0);
#    sy = y0<y1 ? 1 : -1;
#    err = dx+dy;  /* error value e_xy */
#    while (true)   /* loop */
#        plot(x0, y0);
#        if (x0==x1 && y0==y1) break;
#        e2 = 2*err;
#        if (e2 >= dy) 
#           err += dy; /* e_xy+e_x > 0 */
#           x0 += sx;
#        end if
#        if (e2 <= dx) /* e_xy+e_y < 0 */
#           err += dx;
#           y0 += sy;
#        end if
#   end while
#-----------------------------------------------------
# $a0 = first coordinate (x0,y0) format: (0x00XX00YY)
# $a1 = second coordinate (x1,y1) format: (0x00XX00YY)
# $a2 = color of line format: (0x00RRGGBB)
#***************************************************
draw_line: nop
	getCoordinates($a0,$t0,$t1)
	getCoordinates($a1,$t2,$t3)
	
	sub $t4 , $t0, $t2
	abs $t4, $t4
	
	blt $t0, $t2, L1
		li $t5, -1
		j E1
	L1:
		li $t5, 1
		j E1
	E1:
	
	sub $t6 , $t1, $t3
	abs $t6, $t6
	neg $t6, $t6
	
	blt $t1, $t3, L2
		li $t7, -1
		j E2
	L2:
		li $t7, 1
		j E2
	E2:
	add $t8, $t6, $t4
	dlloop:
		push($ra)

		formatCoordinates($a0, $t0, $t1)
		la $a1, ($a2)
		jal draw_pixel

		pop($ra)

		beq $t0, $t2, dlloopEQ
		bne $t0, $t2, dlloopEQcont
		dlloopEQ:
			beq $t1, $t3, dlloopend
		dlloopEQcont:
		mul $t9, $t8, 2
		
		blt $t9, $t6 dlloop2
			add $t8, $t8, $t6
			add $t0, $t0, $t5
		
		dlloop2:
			bgt $t9, $t4 dlloop
				add $t8, $t8, $t4
				add $t1, $t1, $t7
			j dlloop

    dlloopend:
		jr $ra
	
#*****************************************************
# draw_rectangle:
#  Given two coordinates for the upper left and lower 
#  right coordinate, draws a solid rectangle	
#-----------------------------------------------------
# $a0 = first coordinate (x0,y0) format: (0x00XX00YY)
# $a1 = second coordinate (x1,y1) format: (0x00XX00YY)
# $a2 = color of line format: (0x00RRGGBB)
#***************************************************
draw_rectangle: nop
	getCoordinates($a0,$t0,$t1)
	getCoordinates($a1,$t2,$t3)
	la $t4, ($a1)
	formatCoordinates($a1, $t2, $t1)
	formatCoordinates($t5, $t0, $t3)
	#la $a1, ($t4)
	drloop:
	push ($ra)
	 	push($a0)
	 	push($a1)
 		push($t1)
 		push($t3)
		
		jal draw_line
		
		pop($t3)
 		pop($t1)
 		pop($a1)
 		pop($a0)
 		pop ($ra)
		addi $a0, $a0, 0x00000001
		addi $a1, $a1, 0x00000001
		addi $t1, $t1, 1
		bgt $t1, $t3, drloopend
		j drloop
	drloopend:
	jr $ra
	
#*****************************************************
#Given three coordinates, draws a triangle
#-----------------------------------------------------
# $a0 = coordinate of point A (x0,y0) format: (0x00XX00YY)
# $a1 = coordinate of point B (x1,y1) format: (0x00XX00YY)
# $a2 = coordinate of traingle point C (x2, y2) format: (0x00XX00YY)
# $a3 = color of line format: (0x00RRGGBB)
#-----------------------------------------------------
# Traingle should look like:
#               B
#             /   \
#            A --  C
#***************************************************	
draw_triangle: nop
 	move $t0,$a0
 	move $t1, $a1
 	move $t2, $a2
 	move $a2, $a3

 	push($t0)
 	push($t1)
 	push($t2)
 	move $a0, $t0
 	move $a1, $t1
 	push($ra)
 	jal draw_line
 	pop($ra)
 	pop($t2)
 	pop($t1)
 	pop($t0)
	
	push($t0)
 	push($t1)
 	push($t2)
 	move $a0, $t0
 	move $a1, $t2
 	push($ra)
 	jal draw_line
 	pop($ra)
 	pop($t2)
 	pop($t1)
 	pop($t0)
	
	push($t0)
 	push($t1)
 	push($t2)
 	move $a0, $t1
 	move $a1, $t2
 	push($ra)
 	jal draw_line
 	pop($ra)
 	pop($t2)
 	pop($t1)
 	pop($t0)
 	
 	jr $ra	
	
	
	
# 	li $a0 0x0021005F
# 	li $a1 0x00400021
#  	li $a2 0x005F005F
	
