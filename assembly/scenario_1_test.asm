# Test Subject: The scenario_1

.data 

.text
.global main

main:

# get the lower 7 bit and check the number of 1
test_000: 
    li $t0, 215
    # t0 should be 215 = 1101 0111
    li $t2, 0
    li $t3, 0
    li $t4, 7
    andi $t6, $t0, 0x7F
    # t6 should be 87
loop_7bit:
    andi $t5, $t6, 1
    srl $t6, $t6, 1
    # t6 should be 43 21 10 5 2 1 
    add $t2, $t2, $t5
    addi $t3, $t3, 1
    bne $t3, $t4, loop_7bit

    # t2 should be 5
    andi $t2, $t2, 1
    # t2 should be 1
    xori $t2, $t2, 1
    # t2 should be 0


test_001:
    li $t0, 215
    li $t2, 0
    li $t3, 0
    li $t4, 8
    add $t6, $t0, $zero
loop_8bit:    
    andi $t5, $t6, 1
    srl $t6, $t6, 1
    add $t2, $t2, $t5
    addi $t3, $t3, 1
    bne $t3, $t4, loop_8bit
    # t2 should be 6
    andi $t6, $t2, 1
    # t6 should be 0

test_010:
    jal test_111
    or $t3, $t1, $t2
    # t3 should be 1111 1111
    not $t3, $t3
    # t3 should be 0000 0000
    # sw $t3, 0xC60($28)
    # j end_program

test_011:
    jal test_111
    or $t3, $t1, $t2
    # t3 should be 1111 1111
    # sw $t3, 0xC60($28)
    # j end_program

test_100:
    jal test_111
    xor $t3, $t1, $t2
    # t3 should be 1101 1111
    # sw $t3, 0xC60($28)
    # j end_program

test_101:
    jal test_111
    sltu $t3, $t1, $t2
    # t3 should be 0
    sw $t3, 0xC60($28)
    # j end_program

test_110:
    jal test_111
    slt $t3, $t1, $t2
    # t3 should be 1
    # sw $t3, 0xC60($28)
    # j end_program

test_111:
    li $t1, 187
    # t1 should be 187 = 1011 1011
    li $t2, 100
    # t2 should be 100 = 0110 0100
    jr $ra

end_program:
    j end_program
