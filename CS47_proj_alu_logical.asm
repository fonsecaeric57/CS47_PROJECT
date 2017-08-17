.include "./cs47_proj_macro.asm"
.text
.globl au_logical
# TBD: Complete your project procedures
# Needed skeleton is given
#####################################################################
# Implement au_logical
# Argument:
# 	$a0: First number
#	$a1: Second number
#	$a2: operation code ('+':add, '-':sub, '*':mul, '/':div)
# Return:
#	$v0: ($a0+$a1) | ($a0-$a1) | ($a0*$a1):LO | ($a0 / $a1)
# 	$v1: ($a0 * $a1):HI | ($a0 % $a1)
# Notes:
#####################################################################
#au_logical:
# TBD: Complete it	
au_logical:
	#store RTE
	subi	$sp, $sp, 24
	sw	$fp, 24($sp)
	sw	$ra, 20($sp)
	sw	$a0, 16($sp)
	sw	$a1, 12($sp)
	sw	$a2, 8($sp)
	addi	$fp, $sp, 24
logic_conditions:
	li	$t0, '+'
	li	$t1, '-'
	li	$t2, '*'
	li	$t3, '/'
	
	beq	$a2, $t0, addition
	beq	$a2, $t1, subtraction
	beq	$a2, $t2, multiplication
	beq	$a2, $t3, division
	
	j	End_Logic

addition:
	jal	add_logical
	j	End_Logic

subtraction:
	jal	sub_logical
	j	End_Logic

multiplication:
	jal	mul_signed
	j	End_Logic

division:
	jal	div_signed
	j	End_Logic

End_Logic:
	lw	$fp, 24($sp)
	lw	$ra, 20($sp)
	lw	$a0, 16($sp)
	lw	$a1, 12($sp)
	lw	$a2, 8($sp)
	addi	$sp, $sp, 24
	jr	$ra

###########################################################################################################################
######################################### ADDING   ##########################################################

add_logical:
	subi	$sp, $sp, 24				# 	    Store stack frame 		#
	sw	$fp, 24($sp)				#					#
	sw	$ra, 20($sp)				#					#
	sw	$a0, 16($sp)				#					#
	sw	$a1, 12($sp)				#					#
	sw	$a2, 8($sp)				#					#
	addi	$fp, $sp, 24				#########################################
	
	or	$a2, $zero, $zero	        	# Set a2 as 0 or addition mode
	addi	$a2, $a2, 0				# Set a2 to a2 plus signed 16-bit 
	jal	add_sub_logical				# Jump and Link to add_sub_logical
	j	End_Logic	
#################################################################################################################
##########################################	SUBTRACTING	################################################

sub_logical:
	subi	$sp, $sp, 24				# 	    Store stack frame		#
	sw	$fp, 24($sp)				#					#
	sw	$ra, 20($sp)				#					#
	sw	$a0, 16($sp)				#					#
	sw	$a1, 12($sp)				#					#
	sw	$a2, 8($sp)				#					#
	addi	$fp, $sp, 24				#########################################
	
	or	$a2, $zero, $zero	
	addi	$a2, $a2, 1			# Set a2 as 1 or subtraction mode
	jal	add_sub_logical			# Jump and Link to add_sub_logical
	j	End_Logic			# Jump directly to End_Logic
###########################################################################################################################
##########################################		add_sub_logical		################################################

add_sub_logical:
	#Store frame 
	addi	$sp, $sp, -32
	sw	$fp, 32($sp)
	sw	$ra, 28($sp)
	sw	$a0, 24($sp)
	sw	$a1, 20($sp)
	sw	$a2, 16($sp)
	sw	$s0, 12($sp)
	sw	$s1, 8($sp)
	addi	$fp, $sp, 32
	beq $a2, 0, Logic_Add_Branch
	beq $a2, 1, Logic_Sub_Branch
Logic_Sub_Branch:
	not	$a1, $a1				# Invert $a1 (~$a1)
	li	$t0, 0					# $t0 = I (Index), set I t0 zero
	li	$v0, 0 					# $v0 = S (Solution), set S to zero
	and	$s0, $a2, 0x1 				# $s0 = C: C = $a2[0]
	beqz	$a2, Logic_Add_Loop
Logic_Add_Branch:
	li	$t0, 0					# $t0 = I (Index), set I t0 zero
	li	$v0, 0 					# $v0 = S (Solution), set S to zero
	and	$s0, $a2, 0x1 				# $s0 = C: C = $a2[0]
	beqz	$a2, Logic_Add_Loop				# in the case $a2 != zero, go to Logic_Add_Loop
Logic_Add_Loop:
	extract_nth_bit($t2, $a0, $t0) 			# $t2 = A, A = a0[i]
	extract_nth_bit($t3, $a1, $t0) 			# # $t4 = B, B = a1[i]
	xor 	$t4, $t2, $t3 				# $t4 = xor of $t2 and $t3
	xor 	$t6, $s0, $t4 				# $t6 = xor of $s0 and $t4 ( carry bit )
	and 	$t7, $s0, $t4 				# $t7 = AND of $S0 & $t4
	and 	$t8, $t2, $t3 				# $t8 = AND of $t2 & $t3
	or 	$s0, $t7, $t8 					 # Or the and operations.
	insert_to_nth_bit($v0, $t0, $t6, $t9) 		# Insert full bit addition into v0[i]
	addi	$t0, $t0, 0x1 				# I = I + 1 ( Increment index )
	bne	$t0, 32, Logic_Add_Loop			# in the case $t0 (I) != 32, go to Logic_Add_Loop
	beq	$t0, 32, end_add_sub_logical 		# in the case $t0 (I) == 32, go to addlogical_end
end_add_sub_logical:
	move $v1, $s0					# Final carryout: $s0 (CO) is returned in $v1
	# Restore
	lw	$fp, 32($sp)
	lw	$ra, 28($sp)
	lw	$a0, 24($sp)
	lw	$a1, 20($sp)
	lw	$a2, 16($sp)
	lw	$s0, 12($sp)
	lw	$s1, 8($sp)
	addi	$sp, $sp, 32
	jr	$ra	



###########################################################################################################################
##########################################		twos_complement		################################################
	
twos_complement:
	subi	$sp, $sp, 28
	sw   	$fp, 28($sp)
	sw   	$ra, 24($sp)
	sw   	$a0, 20($sp)
	sw	$a1, 16($sp)
	sw	$s0, 12($sp)
	sw	$s1, 8($sp)
	addi 	$fp, $sp, 28

   	not 	$a0, $a0		# Invert $a0 (~$a0)
	li 	$a1, 1				# Set a1 as 0
	jal	add_logical			# add_logical will add $a0 + 1, which will get the twos compliment of $a0
	# Restore stack frame 
	lw   	$fp, 28($sp)
	lw   	$ra, 24($sp)
	lw   	$a0, 20($sp)
	lw	$a1, 16($sp)
	lw	$s0, 12($sp)
	lw	$s1, 8($sp)
	addi	$sp, $sp, 28
	jr 	$ra	

twos_complement_if_neg:
	# Store frame
	subi	$sp, $sp, 16
	sw	$fp, 16($sp)
	sw	$ra, 12($sp)
	sw	$a0,  8($sp)
	addi	$fp, $sp, 16

	move	$v0, $a0				# Assume $a0 is positive Copy $a0 into $v0

	bgt	$a0, $zero, twos_complement_if_neg_end	# If $a0 > 0, Exit, otherwise keep going below.
	jal	twos_complement	

Execute_twos_complement:
	jal	twos_complement
	move	$a0, $v0			# $a0 = $v0 (Set contents of $v0 to $a0)

twos_complement_if_neg_end:
	# Restore frame
	lw	$fp, 16($sp)
	lw	$ra, 12($sp)
	lw	$a0,  8($sp)
	addi	$sp, $sp, 16
	jr	$ra

###########################################################################################################################
##########################################		twos_complement_64bit		################################################
	
twos_complement_64bit:
	subi	$sp, $sp, 32
	sw	$fp, 32($sp)
	sw	$ra, 28($sp)
	sw	$a0, 24($sp)
	sw	$a1, 20($sp)
	sw	$s1, 16($sp)
	sw	$s2, 12($sp)
	sw	$s3,  8($sp)
	addi	$fp, $sp, 32

	not	$a0, $a0			# Invert $a0, or Lo
	not	$a1, $a1			# Invert $a1, or hi
	move  	$s1, $a1			# $s1 = copy of $a1
	or	$a1, $zero, 0x1

	jal	add_logical				# $v0 now contains the twos compliment of $a0 ( Lo )
	move	$s2, $v0			# $s2 = $v0 ( twos compliment of Lo )
	jal	add_logical				# $v0 = $a0 + $s6 ( carry bit of twos compliment of lo)
	move	$s3, $v0			# $s3 = $v0 (Set contents of $v0 to $s3)
	

	move	$s3, $s1			# $s3 = $s1 (Set contents of $s1 to $s3)
	move	$v0, $s2			# Return $s2 (LO) in $v0
	move	$v1, $s3			# Return $s3 (HI) in $v1
	lw	$fp, 32($sp)
	lw	$ra, 28($sp)
	lw	$a0, 24($sp)
	lw	$a1, 20($sp)
	lw	$s1, 16($sp)
	lw	$s2, 12($sp)
	lw	$s3,  8($sp)
	addi	$sp, $sp, 32
	jr	$ra

###########################################################################################################################
##########################################		bit_replicator		################################################
	
bit_replicator:
	# Store frame
	subi	$sp, $sp, 16
	sw	$fp, 16($sp)
	sw	$ra, 12($sp)
	sw	$a0, 8($sp)
	addi 	$fp, $sp, 16

	beq	$a0, 0, POSITIVE			# If $a0 = 0, then branch to POSITIVE
	beq	$a0, 1, NEGATIVE			# If $a0 = 1,then branch to NEGATIVE 

POSITIVE:
	li	$v0, 0x00000000			# Set $v0 to positive
	j	bit_replicator_end

NEGATIVE:
	li	$v0, 0xFFFFFFFF			# Set $v0 to negative
	j	bit_replicator_end

bit_replicator_end:
	lw	$fp, 16($sp)
	lw	$ra, 12($sp)
	lw	$a0,  8($sp)
	addi	$sp, $sp, 16
	jr	$ra

############################################################################################################################################
##########################################		mul_unsigned		################################################

mul_unsigned:
	subi	$sp, $sp, 52
	sw	$fp, 52($sp)
	sw	$ra, 48($sp)
	sw	$a0, 44($sp)
	sw	$a1, 40($sp)
	sw	$a2, 36($sp)
	sw	$s0, 32($sp)
	sw	$s1, 28($sp)
	sw	$s2, 24($sp)
	sw	$s3, 20($sp)
	sw	$s4, 16($sp)
	sw	$s6, 12($sp)
	sw	$s7,  8($sp)
	addi	$fp, $sp, 52
	li	$s7, 0 				# $s7 = I, I = Index = 0
	li	$s4, 0 				# $s4 = H, H = Hi = 0
	move 	$s1, $a1 			# $s1 is $a1
	move 	$s0, $a0 			# $s0 = $a0
mul_unsigned_loop:
	beq	$t5, 0x20, mul_unsigned_end
	extract_nth_bit($s2, $s1, $zero) 	# L[0] ( Extract 0th bit of L and put into replicator )
	move	$a0, $s2							
	jal	bit_replicator					# v0 is the 32 replication of the 0th bit of L
	move	$s2, $v0 			# R = $s2 (R = 32{L[0]}})
	and	$s3, $s0, $s2 			# X = $s3
	move	$a0, $s4			# Pass $s4 ( H ) into $a0 for adding 
	move	$a1, $s3			# Pass $s3 ( X ) into $a1 for adding 
	jal	add_logical				# v0 is the result of H + X
	move	$s4, $v0 			# $s4 = result of H + X (Set the contents of $v0 to $s4)
	srl	$s1, $s1, 1				# I = I >> 1 (Shift I to the right)
	extract_nth_bit($t0, $s4, $zero) 	# Use $t0 to hold H[0]
	li	$s6, 0x1f 			# Set 31 to $s6
	insert_to_nth_bit($s1, $s6, $t0, $t9) 	# L[31] = H[0]
	srl	$s4, $s4, 1			# H = H >> 1 (Shift H to the right)
	addi	$s7, $s7, 1			# Increment Counter
	bne	$s7, 32, mul_unsigned_loop		# in the case $s7 (I) is 32, go to mul_step_loop
mul_unsigned_end:
	move	$v0, $s1			# Return L (LO) in $v0
	move	$v1, $s4			# Return H (HI) in $vi
	# Restore Frame
	lw	$fp, 52($sp)
	lw	$ra, 48($sp)
	lw	$a0, 44($sp)
	lw	$a1, 40($sp)
	lw	$a2, 36($sp)
	lw	$s0, 32($sp)
	lw	$s1, 28($sp)
	lw	$s2, 24($sp)
	lw	$s3, 20($sp)
	lw	$s4, 16($sp)
	lw	$s6, 12($sp)
	lw	$s7,  8($sp)
	addi	$sp, $sp, 52
	jr	$ra

###########################################################################################################################
##########################################		mul_signed		################################################

mul_signed:

	subi	$sp, $sp, 44
	sw	$fp, 44($sp)
	sw	$ra, 40($sp)
	sw	$a0, 36($sp)
	sw	$a1, 32($sp)
	sw	$a2, 28($sp)
	sw	$a3, 24($sp)
	sw	$s4, 20($sp)
	sw	$s5, 16($sp)
	sw	$s6, 12($sp)
	sw	$s7, 8($sp)
	addi	$fp, $sp, 44
	
	move	$s4, $a0					# s4 = copy of a0, or N1
	move	$a2, $a0					# Extra copy of a0
	move	$s5, $a1					# s5 = copy of a1, or N2
	move	$a3, $a1					# Extra copy of a1
	
	jal	twos_complement_if_neg
	move	$s4, $v0					# Store twos_complement_if_neg of a0
	move	$a0, $s5					# Now do the same for a1, or N2
	jal	twos_complement_if_neg
	move	$s5, $v0					# Store twos_complement_if_neg of a1
	
	move	$a0, $s4					# Move s4 into a0 for mul_unsigned
	move	$a1, $s5					# Move s5 into a1 for mul_unsigned
	jal	mul_unsigned
	
	move	$s4, $v0					# s4 = lo of result
	move	$s5, $v1					# s5 = hi of result
	
	li	$t8, 0x1F
	extract_nth_bit($s6, $a2, $t8)	 
	extract_nth_bit($s7, $a3, $t8)
	
	xor	$t9, $s6, $s7					# Sign = XOR of $a0[31] and $a1[31]
	beq	$t9, $zero, mul_signed_end			# If signed bit is 0, go to end, if not, continue below.
	
	move	$a0, $s4
	move	$a1, $s5
	jal	twos_complement_64bit
	
	
mul_signed_end:
	lw	$fp, 44($sp)
	lw	$ra, 40($sp)
	lw	$a0, 36($sp)
	lw	$a1, 32($sp)
	lw	$a2, 28($sp)
	lw	$a3, 24($sp)
	lw	$s4, 20($sp)
	lw	$s5, 16($sp)
	lw	$s6, 12($sp)
	lw	$s7, 8($sp)
	addi	$sp, $sp, 44
	jr	$ra
###########################################################################################################################
##########################################		div_unsigned		################################################

div_unsigned:
	# Store frame
	addi	$sp, $sp, -36
	sw	$fp, 36($sp)
	sw	$ra, 32($sp)
	sw	$a0, 28($sp)
	sw	$a1, 24($sp)
	sw	$s0, 20($sp)
	sw	$s1, 16($sp)
	sw	$s2, 12($sp)
	sw	$s3,  8($sp)
	addi	$fp, $sp, 36
	
	or	$s0, $zero, $zero				# $t5 =  I ( index )
	or	$s3, $zero, $zero				#  $t6 = R ( Remainder )
	move	$s1, $a0 					# $s1 = Q (Quotient)
	move	$s2, $a1 					# $s2 = D (Divisor)

div_unsigned_loop:
	beq	$t5, 32, div_unsigned_loop_end			# If Index ( I ) is equal to 32, then exit 

	sll	$s3, $s3, 1                    			 # R = R << 1 ( Shift R left by 1 spot )
	li	$t0, 31									# Set $t0 to 31
	extract_nth_bit($t3, $s1, $t0)				# Extract 31th bit of Q and save in $t3
								# then, save it in R[0]
	insert_to_nth_bit($s3, $zero, $t3, $t9)			# R[0] = Q[31]
	sll	$s1, $s1, 1                     		# $s1 = Q: Q = Q << 1 
	move	$a0, $s3					# Move $s3 ( R ) into $a0 to execute subtraction
	move	$a1, $s2					# Move $s2 ( D ) into $a1 to execute subtraction
	jal	sub_logical					# $v0 contains the result  of the above operation ( R - D = $v0 )
								# place the result into $s6 ( S )
	move	$t6, $v0                        		# $t6 ( S ) = $v0 ( R - D )

	bltz	$t6, Equals_Zero				# If $t6 (S) = 0, go to Equals_Zero
	move	$s3, $t6                        		# $s3 ( R ) = $t6 ( S ( * results) )
	li	$t5, 1
	insert_to_nth_bit($s1, $zero, $t5, $t9) 		# Q[0] = 1

Equals_Zero:
	add	$s0, $s0, 1                     		# I = I + 1
	beq	$s0, 32, div_unsigned_loop_end    		# I == 32
	j       div_unsigned_loop

div_unsigned_loop_end:
	move 	$v0, $s1					# $v0 = $s4 ( Q ) , ( Return Quotient )
	move	$v1, $s3					# $v1 = $t6 ( R ) , ( Return Remainder )

	# Restore frame
	lw	$fp, 36($sp)
	lw	$ra, 32($sp)
	lw	$a0, 28($sp)
	lw	$a1, 24($sp)
	lw	$s0, 20($sp)
	lw	$s1, 16($sp)
	lw	$s2, 12($sp)
	lw	$s3, 8($sp)
	addi	$sp, $sp, 36
	jr	$ra

###########################################################################################################################
##########################################		div_signed		################################################

div_signed:
	# Store frame
	subi	$sp, $sp, 36
	sw	$fp, 36($sp)
	sw	$ra, 32($sp)
	sw	$a0, 28($sp)
	sw	$a1, 24($sp)
	sw	$s1, 20($sp)
	sw	$s2, 16($sp)
	sw	$s4, 12($sp)
	sw	$s5,  8($sp)
	addi	$fp, $sp, 36
	# Instantiate variables to be used 

	move	$s1, $a0	        			# $s1 = $a0 ( N1 ) (Referenced Lecture 19 slides  slides)
	move	$s2, $a1	        			# $s2 = $a1 ( N2 ) (Referenced Lecture 19 slides  slides)


	li	$t7, 31						# $t7 = 31
	extract_nth_bit($s4, $s1, $t7)				# Extract 31th bit and save in $s4
	extract_nth_bit($s5, $s2, $t7)				# Extract $a2(s2) by 32-bit and store it in $s5
	xor	$s5, $s4, $s5 					# xor $a0 (s4) and $a1 (s5), store it in $s5(S)

	# Make $s1 twos_complement_if_neg
	jal	twos_complement_if_neg
	move	$a0, $s1					# $s4 = $v0 ( results of twos_complement_if_neg of $a0 )
	jal	twos_complement_if_neg
	move    $s1, $v0					# $s1 = $v0

	# Make $s2 twos_complement_if_neg
	jal	twos_complement_if_neg
	move	$a0, $s2					# $a0 = $s2 
	jal	twos_complement_if_neg
	move	$s2, $v0					# $s2 = $v0 

	move	$a0, $s1					# $a0 = $s1 
	move	$a1, $s2					# $a1 = $s2 
	jal	div_unsigned

	move 	$s1, $v0					# $s1 = $v0 
	move 	$s2, $v1					# $s2 = $v1 

	# $s5 is S of Q
	beqz	$s5, IfZero					# If $S5 = 0, branch to skip $s5
	move	$a0, $s1					# $a0 = $s1 
	jal	twos_complement
	move	$s1, $v0 					# $s1(Q) = $v0 (The contents of $v0 are set to $s1(Q))

IfZero:	# $s4 is S of R
	beqz 	$s4, elseIF					# if $s4 equals zero, go to elseIF
	move 	$a0, $s2					# $a0 = $s2 (Set contents of $s2 to $a0)
	jal	twos_complement
	move	$s2, $v0					# $s2 = $v0 (Set contents of $v0 to $s2)

elseIF:
	move 	$v0, $s1	       			 	# $v0 = $s1 (Set the contents of $s1 to $v0)
	move 	$v1, $s2					# $v1 = $s2 (Set the contents of $s2 to $v1)

	# Restore frame
	lw	$fp, 36($sp)
	lw	$ra, 32($sp)
	lw	$a0, 28($sp)
	lw	$a1, 24($sp)
	lw	$s1, 20($sp)
	lw	$s2, 16($sp)
	lw	$s4, 12($sp)
	lw	$s5,  8($sp)
	addi	$sp, $sp, 36
	jr	$ra
#Eric Fonseca
