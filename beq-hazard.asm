# li x5, 5
# jal x5, L1
# L1: addi x6, x5, 1

# 0x0	0x00500293	addi x5 x0 5	li x5, 5
# 0x4	0x004002EF	jal x5 4	jal x5, L1
# 0x8	0x00128313	addi x6 x5 1	L1: addi x6, x5, 1