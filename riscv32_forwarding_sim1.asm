# Test the RISC-V processor in simulation
# 已经能正确执行：addi, beq, jal
# 待验证：有条件与无条件分支指令后误读的指令是否能够正确清空，没有delay slot
# 不考虑分支指令与前面指令之间的数据依赖，所以添加了必要的nop指令

# main:	addi x5, x0, 1
# 		addi x6, x0, 1
# 		addi x7, x0, 0			#x7 = 0
# 		addi x8, x0, 0
# 		addi x0, x0, 0
# 		addi x0, x0, 0
# 		beq  x5, x6, br1
# 		addi x8, x8, 1			#should not run here
# 		addi x9, x9, 1
# 		jal  x0, end

# br1:	addi x7, x7, 1			#x7 = 1
# 		jal  x0, end
# 		addi x8, x8, 1			#should not run
# 		addi x9, x9, 1

# end:	addi x7, x7, 1

0x0	0x00100293	addi x5 x0 1	main: addi x5, x0, 1
0x4	0x00100313	addi x6 x0 1	addi x6, x0, 1
0x8	0x00000393	addi x7 x0 0	addi x7, x0, 0 #x7 = 0
0xc	0x00000413	addi x8 x0 0	addi x8, x0, 0
0x10	0x00000013	addi x0 x0 0	addi x0, x0, 0
0x14	0x00000013	addi x0 x0 0	addi x0, x0, 0
0x18	0x00628863	beq x5 x6 16	beq x5, x6, br1
0x1c	0x00140413	addi x8 x8 1	addi x8, x8, 1 #should not run here
0x20	0x00148493	addi x9 x9 1	addi x9, x9, 1
0x24	0x0140006F	jal x0 20	jal x0, end
0x28	0x00138393	addi x7 x7 1	br1: addi x7, x7, 1 #x7 = 1
0x2c	0x00C0006F	jal x0 12	jal x0, end
0x30	0x00140413	addi x8 x8 1	addi x8, x8, 1 #should not run
0x34	0x00148493	addi x9 x9 1	addi x9, x9, 1
0x38	0x00138393	addi x7 x7 1	end: addi x7, x7, 1
