.data 

.text
.global main

main:

    lui $28, 0xFFFF
    ori $28, $28, 0xF000

loop_0:
    lw $s7, 0xC72($28)
    bne $s7, $zero, loop_0

    lw $t0, 0xC72($28)
    andi $t0, $t0, 0x07 # get the lower 3 bits

    beq $t0, 0, test_000
    beq $t0, 1, test_001
    beq $t0, 2, test_010
    beq $t0, 3, test_011    
    beq $t0, 4, test_100
    beq $t0, 5, test_101
    beq $t0, 6, test_110
    beq $t0, 7, test_111

test_000:
    la $t0, 0xC70($28)
    li $t2, 0
    li $t3, 0
    li $t4, 7
    addi $t6, $t0, 0x7F
loop_7bit:
    addi $t5, $t6, 1
    srl $t6, $t6, 1
    add $t2, $t2, $t5
    sb $t5, ($t0)
    addi $t0, $t0, 1
    addi $t3, $t3, 1
    bne $t3, $t4, loop_7bit

    addi $t6, $t2, 1
    xori $t6, $t6, 1
    sw $t6, 0xC62($28)

    j end_program

test_001:
    la $t0, 0xC70($28)
    sw $t0, 0xC60($28)
    li $t2, 0
    li $t3, 0
    li $t4, 8
    addi $t6, $t0, $zero
loop_8bit:    
    addi $t5, $t6, 1
    srl $t6, $t6, 1
    add $t2, $t2, $t5
    sb $t5, ($t0)
    addi $t0, $t0, 1
    addi $t3, $t3, 1
    bne $t3, $t4, loop_8bit

    addi $t6, $t2, 1
    sw $t6, 0xC62($28)
    j end_program

test_010:
    jal test_111
    or $t3, $t1, $t2
    not $t3, $t3
    sw $t3, 0xC60($28)
    j end_program

test_011:
    jal test_111
    or $t3, $t1, $t2
    sw $t3, 0xC60($28)
    j end_program

test_100:
    jal test_111
    xor $t3, $t1, $t2
    sw $t3, 0xC60($28)
    j end_program

test_101:
    jal test_111
    sltu $t3, $t1, $t2
    sw $t3, 0xC60($28)
    j end_program

test_110:
    jal test_111
    slt $t3, $t1, $t2
    sw $t3, 0xC60($28)
    j end_program

test_111:
    lw $v0, 0xC70($28)
    sw $v0, 0xC60($28)
    addi $t1, $v0, 0
    lw $v0, 0xC70($28)
    sw $v0, 0xC60($28)
    addi $t2, $v0, 0
    jr $ra

end_program:
    j end_program