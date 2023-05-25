.data 0x0000				      		
buf: .word 0x0000
.text 0x0000

start: 
lui   $1,0xffff		
ori   $28,$1,0x0000

switled:								
	lw   $1,0x10($28)		# right 16 switch
	sw   $1,0x2C($28)		# right 16 LED
	lw   $1,0x0C($28)		# left 8 switch
	sw   $1,0x24($28)		# left 8 LED
	addi $1,$1, 0
	j switled