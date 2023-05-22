.data 

.text
.global main

main:

    lui $28, 0xffff # base physical address
    ori $28, $28, 0x0000

loop_0:
    lw $s7, 0x08($28)
    bne $s7, $zero, loop_0

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
    lw $t0, 0x0C($28)
    sw $t0, 0x24($28)
    li $t2, 0
    li $t3, 0
    li $t4, 7
    andi $t6, $t0, 0x7F
    sw $t6, 0x2C($28)
loop_7bit:
    andi $t5, $t6, 1
    srl $t6, $t6, 1
    add $t2, $t2, $t5
    addi $t3, $t3, 1
    bne $t3, $t4, loop_7bit

    andi $t2, $t2, 1
    xori $t2, $t2, 1
    sw $t2, 0x20($28)

    j end_program

test1_001:
    lw $t0, 0x0C($28)
    sw $t0, 0x24($28)
    li $t2, 0
    li $t3, 0
    li $t4, 8
    add $t6, $t0, $zero
    sw $t6, 0x2C($28)
loop_8bit:    
    andi $t5, $t6, 1
    srl $t6, $t6, 1
    add $t2, $t2, $t5
    addi $t3, $t3, 1
    bne $t3, $t4, loop_8bit

    andi $t6, $t2, 1
    sw $t2, 0x20($28)
    j end_program

test1_010:
    jal test_111
    or $t3, $t1, $t2
    not $t3, $t3
    sw $t3, 0x24($28)
    sw $t3, 0x2C($28)
    j end_program

test1_011:
    jal test_111
    or $t3, $t1, $t2
    sw $t3, 0x24($28)
    sw $t3, 0x2C($28)
    j end_program

test1_100:
    jal test_111
    xor $t3, $t1, $t2
    sw $t3, 0x24($28)
    sw $t3, 0x2C($28)
    j end_program

test1_101:
    jal test_111
    sltu $t3, $t1, $t2
    sw $t3, 0x20($28)
    j end_program

test1_110:
    jal test_111
    slt $t3, $t1, $t2
    sw $t3, 0x20($28)
    j end_program

test1_111:
    lw $v0, 0x0C($28)
    sw $v0, 0x24($28)
    addi $t1, $v0, 0
    lw $v0, 0x0C($28)
    sw $v0, 0x28($28)
    addi $t2, $v0, 0
    jr $ra

end_program:
    j end_program
