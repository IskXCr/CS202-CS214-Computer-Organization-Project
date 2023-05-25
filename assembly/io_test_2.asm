# Test Subject: 7-seg tube MMIO and MMIO address
# if the first instruction is ignored, then t1 would be 0x3377
.data 
	reg1: .word 0x3377
	
.text
	bgezal $zero test
	j skip
test:
	li $t2, 23
skip:
	lw $t1, reg1
	add $t1, $t1, $t2
	li $s0, 0xffff0000
	sw $t1, 0x30($s0)
	subi $ra, $ra, 4
	sw $ra, 0x34($s0)
end:
	j end
