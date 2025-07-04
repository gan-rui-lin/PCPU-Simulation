# # Test the RISC-V processor in simulation
# # 已经能正确执行：addi, lw, sw, beq，jal, jalr
# # 待验证：能否正确处理需要停顿的数据依赖: load-use, arith-beq, load-beq, arith-jal, load-jalr

main:	addi x5, x0, 5
		sw	 x5, 0(x0)		#mem[0] = 5
		lw	 x6, 0(x0)
		addi x7, x6, 2		#load-use data hazard, stall one cycle, x7 = 7
		addi x8, x0, 7
		beq  x7, x8, br1 	#arith-beq data hazard, stall one cycle
		addi x10, x0, 10	#should not run
br1ret: lw   x7, 0(x0)		#x7 = 5
		beq  x5, x7, br2 	#lw-beq data hazard, stall two cycles
		addi x10, x0, 10	#should not run
br2ret: addi x14, x0, 1
		jal  x0, end

br1:	addi x11, x0, 0x1c
        jalr x0, x11, 0

br2:	addi x12, x0, 40
        sw   x12, 8(x0)
        lw   x13, 8(x0)
        jalr x0, x13, 0		#jalr x0, br2ret

end:	addi x5, x5, 0x100



# 0x0	    0x00500293	addi x5 x0 5	main: addi x5, x0, 5
# 0x4	    0x00502023	sw x5 0(x0)	sw x5, 0(x0) #mem[0] = 5
# 0x8	    0x00002303	lw x6 0(x0)	lw x6, 0(x0)
# 0xc	    0x00230393	addi x7 x6 2	addi x7, x6, 2 #load-use data hazard, stall one cycle, x7 = 7
# 0x10	0x00700413	addi x8 x0 7	addi x8, x0, 7
# 0x14	0x00838E63	beq x7 x8 28	beq x7, x8, br1 #arith-beq data hazard, stall one cycle
# 0x18	0x00A00513	addi x10 x0 10	addi x10, x0, 10 #should not run
# 0x1c	0x00002383	lw x7 0(x0)	br1ret: lw x7, 0(x0) #x7 = 5
# 0x20	0x00728C63	beq x5 x7 24	beq x5, x7, br2 #lw-beq data hazard, stall two cycles
# 0x24	0x00A00513	addi x10 x0 10	addi x10, x0, 10 #should not run
# 0x28	0x00100713	addi x14 x0 1	br2ret: addi x14, x0, 1
# 0x2c	0x01C0006F	jal x0 28	jal x0, end
# 0x30	0x01C00593	addi x11 x0 28	br1: addi x11, x0, 0x1c
# 0x34	0x00058067	jalr x0 x11 0	jalr x0, x11, 0
# 0x38	0x02800613	addi x12 x0 40	br2: addi x12, x0, 40
# 0x3c	0x00C02423	sw x12 8(x0)	sw x12, 8(x0)
# 0x40	0x00802683	lw x13 8(x0)	lw x13, 8(x0)
# 0x44	0x00068067	jalr x0 x13 0	jalr x0, x13, 0 #jalr x0, br2ret
# 0x48	0x10028293	addi x5 x5 256	end: addi x5, x5, 0x100


# 0x00500293	addi x5 x0 5	main: addi x5, x0, 5
# 0x00502023	sw x5 0(x0)	sw x5, 0(x0) #mem[0] = 5
# 0x00002303	lw x6 0(x0)	lw x6, 0(x0)
# 0x00230393	addi x7 x6 2	addi x7, x6, 2 #load-use data hazard, stall one cycle, x7 = 7
# 0x00700413	addi x8 x0 7	addi x8, x0, 7
# 0x00838E63	beq x7 x8 28	beq x7, x8, br1 #arith-beq data hazard, stall one cycle
# 0x00A00513	addi x10 x0 10	addi x10, x0, 10 #should not run
# 0x00002383	lw x7 0(x0)	br1ret: lw x7, 0(x0) #x7 = 5
# 0x00728C63	beq x5 x7 24	beq x5, x7, br2 #lw-beq data hazard, stall two cycles
# 0x00A00513	addi x10 x0 10	addi x10, x0, 10 #should not run
# 0x00100713	addi x14 x0 1	br2ret: addi x14, x0, 1
# 0x01C0006F	jal x0 28	jal x0, end
# 0x01C00593	addi x11 x0 28	br1: addi x11, x0, 0x1c
# 0x00058067	jalr x0 x11 0	jalr x0, x11, 0
# 0x02800613	addi x12 x0 40	br2: addi x12, x0, 40
# 0x00C02423	sw x12 8(x0)	sw x12, 8(x0)
# 0x00802683	lw x13 8(x0)	lw x13, 8(x0)
# 0x00068067	jalr x0 x13 0	jalr x0, x13, 0 #jalr x0, br2ret
# 0x10028293	addi x5 x5 256	end: addi x5, x5, 0x100