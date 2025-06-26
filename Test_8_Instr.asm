# # Test File for 8 Instruction, include:
# # ADD/SUB/OR/AND/LW/SW/ORI/BEQ
# ################################################################
# ### Make sure following Settings :
# # Settings -> Memory Configuration -> Compact, Data at address 0

# .text
# 	ori x29, x0, 12
# 	ori x8, x0, 0x1234
# 	ori x9, x0, 0x3456
# 	add x7, x8, x9
# 	sub x6, x7, x9
#                 or  x10, x8, x9
#                 and x11, x9, x10
# 	sw x8, 0(x0)
# 	sw x9, 4(x0)
# 	sw x7, 4(x29)
# 	lw x5, 0(x0)
# 	beq x8, x5, _lb2
# 	_lb1:
# 	lw x9, 4(x29)
# 	_lb2:
# 	lw x5, 4(x0)
# 	beq x9, x5, _lb1
	
# 	# Never return
	
0x00000000	0x00C06E93	addi x29, x0, 12	x29 = 12
0x00000004	0x12306413	addi x8, x0, 0x123	x8 = 0x123
0x00000008	0x45606493	addi x9, x0, 0x456	x9 = 0x456
0x0000000C	0x009403B3	add x7, x8, x9	x7 = x8 + x9
0x00000010	0x40938333	sub x6, x7, x9	x6 = x7 - x9
0x00000014	0x00946533	or x10, x8, x9	`x10 = x8	x9`
0x00000018	0x00A4F5B3	and x11, x9, x10	x11 = x9 & x10
0x0000001C	0x00802023	sw x8, 0(x0)	mem[0] = x8
0x00000020	0x00902223	sw x9, 4(x0)	mem[4] = x9
0x00000024	0x007EA223	sw x7, 4(x29)	mem[x29+4] = x7
0x00000028	0x00002283	lw x5, 0(x0)	x5 = mem[0]
0x0000002C	0x00540463	beq x8, x5, +8	if (x8 == x5) PC += 8
0x00000030	0x004EA483	lw x9, 4(x29)	x9 = mem[x29+4]
0x00000034	0x00402283	lw x5, 4(x0)	x5 = mem[4]
0x00000038	0xFE548CE3	beq x10, x5, -24	if (x10 == x5) PC -= 24