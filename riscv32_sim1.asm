# Test the RISC-V processor in simulation
# 待验证：lui, auipc, addi
# 待验证： sb, sh, sw, lb, lh, lw, lbu, lhu
# 本测试只验证单条指令的功能，不考察转发和冒险检测的功能，所以在相关指令之间添加了足够多的nop指令

#		Assembly				Description
# main:	lui 	x5, 0xF1F2F		#x5寄存器的高20位设置为0xF1F2F
# 		auipc	x6, 0x6 		#x6寄存器的结果设置为0x6004
# 		addi	x0, x0, 0		#nop指令
# 		addi	x0, x0, 0
# 		addi	x0, x0, 0
# 		addi	x5, x5, 0x3F4	#将x5寄存器的值设置为0xF1F2F3F4
#         addi	x0, x0, 0
# 		addi	x0, x0, 0
# 		addi	x0, x0, 0
#         addi	x0, x0, 0
# 		sb		x5, 0(x0)		#数据内存地址0处的字节设置为0xF4
# 		sb		x5, 1(x0)		#数据内存地址1处的字节设置为0xF4
# 		sh		x5, 2(x0)		#数据内存地址2处的双字节设置为0xF3F4
# 		sw		x5, 4(x0)		#数据内存地址4处的四字节设置为0xF1F2F3F4
#         addi	x0, x0, 0
# 		addi	x0, x0, 0
# 		addi	x0, x0, 0
#         addi	x0, x0, 0
# 		lb		x7, 4(x0)		#x7寄存器的值设置为0xFFFFFFF4
# 		lb		x8, 5(x0)		#x8寄存器的值设置为0xFFFFFFF3
# 		lb		x9, 6(x0)		#x9寄存器的值设置为0xFFFFFFF2
# 		lb		x10, 7(x0)		#x10寄存器的值设置为0xFFFFFFF1
# 		lh		x11, 0(x0)		#x11寄存器的值设置为0xFFFFF4F4
# 		lh		x12, 2(x0)		#x12寄存器的值设置为0xFFFFF3F4
# 		lw		x13, 4(x0)		#x13寄存器的值设置为0xF1F2F3F4
# 		lbu		x14, 0(x0)		#x14寄存器的值设置为0xF4
# 		lbu		x15, 1(x0)		#x15寄存器的值设置为0xF4
# 		lbu		x16, 2(x0)		#x16寄存器的值设置为0xF4
# 		lbu		x17, 3(x0)		#x17寄存器的值设置为0xF3
# 		lhu		x18, 4(x0)		#x18寄存器的值设置为0xF3F4
# 		lhu		x19, 6(x0)		#x19寄存器的值设置为0xF1F2

0x0	0xF1F2F2B7	lui x5 991023	main: lui x5, 0xF1F2F #x5寄存器的高20位设置为0xF1F2F
0x4	0x00006317	auipc x6 6	auipc x6, 0x6 #x6寄存器的结果设置为0x6004
0x8	0x00000013	addi x0 x0 0	addi x0, x0, 0 #nop指令
0xc	0x00000013	addi x0 x0 0	addi x0, x0, 0
0x10	0x00000013	addi x0 x0 0	addi x0, x0, 0
0x14	0x3F428293	addi x5 x5 1012	addi x5, x5, 0x3F4 #将x5寄存器的值设置为0xF1F2F3F4
0x18	0x00000013	addi x0 x0 0	addi x0, x0, 0
0x1c	0x00000013	addi x0 x0 0	addi x0, x0, 0
0x20	0x00000013	addi x0 x0 0	addi x0, x0, 0
0x24	0x00000013	addi x0 x0 0	addi x0, x0, 0
F4 F4 F4 F3 F4 F3 F2 F1
0x28	0x00500023	sb x5 0(x0)	sb x5, 0(x0) #数据内存地址0处的字节设置为0xF4
0x2c	0x005000A3	sb x5 1(x0)	sb x5, 1(x0) #数据内存地址1处的字节设置为0xF4
0x30	0x00501123	sh x5 2(x0)	sh x5, 2(x0) #数据内存地址2处的双字节设置为0xF3F4
0x34	0x00502223	sw x5 4(x0)	sw x5, 4(x0) #数据内存地址4处的四字节设置为0xF1F2F3F4
0x38	0x00000013	addi x0 x0 0	addi x0, x0, 0
0x3c	0x00000013	addi x0 x0 0	addi x0, x0, 0
0x40	0x00000013	addi x0 x0 0	addi x0, x0, 0
0x44	0x00000013	addi x0 x0 0	addi x0, x0, 0
0x48	0x00400383	lb x7 4(x0)	lb x7, 4(x0) #x7寄存器的值设置为0xFFFFFFF4
0x4c	0x00500403	lb x8 5(x0)	lb x8, 5(x0) #x8寄存器的值设置为0xFFFFFFF3
0x50	0x00600483	lb x9 6(x0)	lb x9, 6(x0) #x9寄存器的值设置为0xFFFFFFF2
0x54	0x00700503	lb x10 7(x0)	lb x10, 7(x0) #x10寄存器的值设置为0xFFFFFFF1
0x58	0x00001583	lh x11 0(x0)	lh x11, 0(x0) #x11寄存器的值设置为0xFFFFF4F4
0x5c	0x00201603	lh x12 2(x0)	lh x12, 2(x0) #x12寄存器的值设置为0xFFFFF3F4
0x60	0x00402683	lw x13 4(x0)	lw x13, 4(x0) #x13寄存器的值设置为0xF1F2F3F4
0x64	0x00004703	lbu x14 0(x0)	lbu x14, 0(x0) #x14寄存器的值设置为0xF4
0x68	0x00104783	lbu x15 1(x0)	lbu x15, 1(x0) #x15寄存器的值设置为0xF4
0x6c	0x00204803	lbu x16 2(x0)	lbu x16, 2(x0) #x16寄存器的值设置为0xF4
0x70	0x00304883	lbu x17 3(x0)	lbu x17, 3(x0) #x17寄存器的值设置为0xF3
0x74	0x00405903	lhu x18 4(x0)	lhu x18, 4(x0) #x18寄存器的值设置为0xF3F4
0x78	0x00605983	lhu x19 6(x0)	lhu x19, 6(x0) #x19寄存器的值设置为0xF1F2