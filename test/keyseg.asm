.data 0x0000				      		
buf: .word 0x0000
.text 0x0000

start: 
lui   $28,0xffff		
ori   $28,$28,0x0000

switled:								
	lw $1, 0x04($28)  # sw[23] check the case of scenario
	sw $1, 0x20($28)  # LED[19]
	lw $1, 0x08($28)  # sw[22:20] testcase
	sw $1, 0x30($28)  # LED Tube LEFT
	lw $1, 0x0c($28)  # sw[15:8]
	sw $1, 0x30($28)  # LED Tube LEFT
	lw $1, 0x10($28)  # sw[7:0]
	sw $1, 0x34($28)  # LED Tube RIGHT
	lw $1, 0x14($28)  # keypad
	sw $1, 0x38($28)  # LED[15:0]
	j switled