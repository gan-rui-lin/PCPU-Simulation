# # Test the RISC-V processor in simulation
# # 已经能正确执行：addi
# # 待验证：jal, jalr
# # 本测试只验证单条指令的功能，不考察转发和冒险检测的功能，所以在相关指令之间添加了足够多的nop指令

# #		Assembly                Description
# main:   addi    x5, x0, 0               #x5 <== 0x0,            00000293
#         addi    x0, x0, 0               #                       00000013
#         addi    x0, x0, 0 
#         addi    x0, x0, 0
#         addi    x0, x0, 0
# ->0x14  jal     x1, proc1               #call proc1,            028000EF        0x14
#         addi    x0, x0, 0               #jalr back here                         0x18
#         addi    x0, x0, 0 
#         addi    x0, x0, 0               #not touched
#         addi    x0, x0, 0
#         addi    x5, x5, 1               #x5 <== 0x2             00128293
#         addi    x0, x0, 0
#         addi    x0, x0, 0 
#         addi    x0, x0, 0
#         addi    x0, x0, 0
#         jal     x0, end

# proc1:
#         addi    x0, x0, 0               #                                       0x3c
#         addi    x0, x0, 0               #                                       0x40
#         addi    x0, x0, 0               #                                       0x44
#         addi    x0, x0, 0               #                                       0x48
#         addi    x5, x5, 1               #x5 <== 0x1             00128293        0x4c
#         jalr    x0, x1, 0               #ret                    00008067        0x50 cc13
#         addi    x0, x0, 0
#         addi    x0, x0, 0 
#         addi    x0, x0, 0
#         addi    x0, x0, 0

# end:    addi    x5, x5, 1               #x5 <== 0x3

0x0	addi x5 x0 0	main: addi x5, x0, 0 #x5 <== 0x0, 00000293
0x4	addi x0 x0 0	addi x0, x0, 0 # 00000013
0x8	addi x0 x0 0	addi x0, x0, 0
0xc	addi x0 x0 0	addi x0, x0, 0
0x10	addi x0 x0 0	addi x0, x0, 0
0x14	jal x1 44	jal x1, proc1 #call proc1, 028000EF 0x14
0x18	addi x0 x0 0	addi x0, x0, 0 #jalr back here 0x18
0x1c	addi x0 x0 0	addi x0, x0, 0
0x20	addi x0 x0 0	addi x0, x0, 0 # not touched
0x24	addi x0 x0 0	addi x0, x0, 0
0x28	addi x5 x5 1	addi x5, x5, 1 #x5 <== 0x2 00128293
0x2c	addi x0 x0 0	addi x0, x0, 0 
0x30	addi x0 x0 0	addi x0, x0, 0
0x34	addi x0 x0 0	addi x0, x0, 0
0x38	addi x0 x0 0	addi x0, x0, 0
0x3c	jal x0 44	jal x0, end
0x40	addi x0 x0 0	addi x0, x0, 0 # 函数开始位置
0x44	addi x0 x0 0	addi x0, x0, 0 
0x48	addi x0 x0 0	addi x0, x0, 0 
0x4c	addi x0 x0 0	addi x0, x0, 0 
0x50	addi x5 x5 1	addi x5, x5, 1 #x5 <== 0x1 00128293 0x4c
0x54	jalr x0 x1 0	jalr x0, x1, 0 #ret 00008067 0x50 cc13
0x58	addi x0 x0 0	addi x0, x0, 0
0x5c	addi x0 x0 0	addi x0, x0, 0
0x60	addi x0 x0 0	addi x0, x0, 0
0x64	addi x0 x0 0	addi x0, x0, 0
0x68	addi x5 x5 1	end: addi x5, x5, 1 #x5 <== 0x3