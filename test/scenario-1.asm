.data

.text
.global main

main:

    lui $28, 0xffff # base physical address
    ori $28, $28, 0x0000

loop_0:
    # get the testcase sw[22:20]
    lw $t0, 0x08($28)
    andi $t0, $t0, 0x07 # get the lower 3 bits

    beq $t0, 0, test1_000
    beq $t0, 1, test1_001
    beq $t0, 2, test1_010
    beq $t0, 3, test1_011    
    beq $t0, 4, test1_100
    beq $t0, 5, test1_101
    beq $t0, 6, test1_110
    beq $t0, 7, test1_111

test1_000:
    # get the value of a sw[15:8]
    lw $t0, 0x0C($28)
    # save the value to LED[15:0] 
    sw $t0, 0x38($28)
    li $t2, 0
    li $t3, 0
    li $t4, 7
    andi $t6, $t0, 0x7F
    # only show 7 bit
    sw $t6, 0x38($28)
loop_7bit:
    andi $t5, $t6, 1
    srl $t6, $t6, 1
    add $t2, $t2, $t5
    addi $t3, $t3, 1
    bne $t3, $t4, loop_7bit

    andi $t2, $t2, 1
    xori $t2, $t2, 1
    # save the answer to LED[16]
    sw $t2, 0x2C($28)

    j end_program

test1_001:
    lw $t0, 0x0C($28)
    sw $t0, 0x38($28)
    li $t2, 0
    li $t3, 0
    li $t4, 8
    add $t6, $t0, $zero
    sw $t6, 0x38($28)
loop_8bit:    
    andi $t5, $t6, 1
    srl $t6, $t6, 1
    add $t2, $t2, $t5
    addi $t3, $t3, 1
    bne $t3, $t4, loop_8bit

    andi $t6, $t2, 1
    sw $t6, 0x2C($28)
    j end_program

# t1 the value of a
# t2 the value of b

test1_010:
    jal test1_111
    # not(a|b)
    or $t3, $t1, $t2
    not $t3, $t3
    # show the result in LED[15:0]
    sw $t3, 0x38($28)
    # sw $t3, 0x2C($28)
    j end_program

test1_011:
    jal test1_111
    # (a|b)
    or $t3, $t1, $t2
    sw $t3, 0x38($28)
    # sw $t3, 0x2C($28)
    j end_program

test1_100:
    jal test1_111
    # (a^b)
    xor $t3, $t1, $t2
    sw $t3, 0x38($28)
    # sw $t3, 0x2C($28)
    j end_program

test1_101:
    jal test1_111
    sltu $t3, $t1, $t2
    # show the result in LED[16]
    sw $t3, 0x2c($28)
    j end_program

test1_110:
    jal test1_111
    slt $t3, $t1, $t2
    # show the result in LED[16]
    sw $t3, 0x2c($28)
    j end_program

test1_111:
    # sw[15:8] the value of a
    lw $v0, 0x0C($28)
    # show a in LED Tube LEFT
    sw $v0, 0x30($28)
    addi $t1, $v0, 0
    # sw[7:0] the value of b
    lw $v0, 0x10($28)
    # show b in LED Tube RIGHT
    sw $v0, 0x34($28)
    addi $t2, $v0, 0
    jr $ra

end_program:
    j end_program
