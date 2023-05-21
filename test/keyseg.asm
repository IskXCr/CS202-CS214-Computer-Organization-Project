.data 0x0000				      		
buf: .word 0x0000
.text 0x0000

start: 
lui   $1,0xFFFF			
ori   $28,$1,0xF000

switled:								
	lw   $1,0xC70($28)		# right 16 switch
	sw   $1,0xC60($28)		# right 16 LED
	lw   $1,0xC72($28)		# left 8 switch
	sw   $1,0xC62($28)		# left 8 LED
	lw   $1,0xC83($28)		# get from keyboard
	sw   $1,0xC93($28)		# store in segtube
	addi $1,$1, 0
	j switled