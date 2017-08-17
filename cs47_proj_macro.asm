# Add you macro definition here - do not touch cs47_common_macro.asm"
#<------------------ MACRO DEFINITIONS ---------------------->#
	.macro extract_nth_bit($regD, $regS, $regT)
	srlv	$regD, $regS, $regT
	andi	$regD, 0x1
	.end_macro
	
	.macro insert_to_nth_bit($regD, $regS, $regT, $maskReg)
	addi	$maskReg, $maskReg, 0x1
	sllv	$maskReg, $maskReg, $regS
	not	$maskReg, $maskReg
	and	$regD, $maskReg, $regD
	sllv	$regT, $regT, $regS
	or	$regD, $regD, $regT
	.end_macro
