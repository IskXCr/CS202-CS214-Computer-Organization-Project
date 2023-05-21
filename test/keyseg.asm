.data 0x0000				      		
buf: .word 0x0000
.text 0x0000

start: 
lui   $1,0x1000		
ori   $28,$1,0x0000

switled:								
	lw   $1,0xC70($28)		# right 16 switch
	sw   $1,0xC60($28)		# right 16 LED
	lw   $1,0xC78($28)		# left 8 switch
	sw   $1,0xC68($28)		# left 8 LED
	lw   $1,0xC8C($28)		# get from keyboard
	sw   $1,0xC9C($28)		# store in segtube
	addi $1,$1, 0
	j switled