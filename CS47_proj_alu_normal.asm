.include "./cs47_proj_macro.asm"
.text
.globl au_normal
# TBD: Complete your project procedures
# Needed skeleton is given
#####################################################################
# Implement au_normal
# Argument:
# 	$a0: First number
#	$a1: Second number
#	$a2: operation code ('+':add, '-':sub, '*':mul, '/':div)
# Return:
#	$v0: ($a0+$a1) | ($a0-$a1) | ($a0*$a1):LO | ($a0 / $a1)
# 	$v1: ($a0 * $a1):HI | ($a0 % $a1)
# Notes:
#####################################################################
au_normal:

	
	li	$t0, '+'
	li	$t1, '-'
	li	$t2, '*'
	li	$t3, '/'
	
	beq	$a2, $t0, addition
	beq	$a2, $t1, subtraction
	beq	$a2, $t2, multiplication
	beq	$a2, $t3, division


addition:
	add	$v0, $a0, $a1
	jr	$ra
	
subtraction:
	sub	$v0, $a0, $a1
	jr	$ra
	
multiplication:
	mult	$a0, $a1
	mflo	$v0
	mfhi	$v1
	jr	$ra
	
division:
	div	$a0, $a1
	mflo	$v0
	mfhi	$v1
	jr	$ra


