# # Test the RISC-V processor in simulation
# # 已经能正确执行：addi, lui, jal
# # 待验证：beq, bne, blt, bge, bltu, bgeu
# # 本测试只验证单条指令的功能，不考察转发和冒险检测的功能，所以在相关指令之间添加了足够多的nop指令

# #		Assembly                Description
# main:   addi    x5, x0, 0               #x5 <== 0x0
#         addi    x6, x0, 0               #x6 <== 0x0
#         lui     x7, 0xfffff             #x7 <== 0xFFFFF000
#         addi    x0, x0, 0               #instr 00000013
#         addi    x0, x0, 0
#         addi    x0, x0, 0

#         beq     x6, x0, br1             #beq taken
#         addi    x0, x0, 0
#         addi    x0, x0, 0
#         addi    x0, x0, 0
#         addi    x0, x0, 0
# br1ret: beq     x7, x0, br2ret          #beq not taken
#         addi    x0, x0, 0
#         addi    x0, x0, 0
#         addi    x0, x0, 0
#         addi    x0, x0, 0          
#         addi    x5, x5, 1               #x5 = 2
#         addi    x0, x0, 0
#         addi    x0, x0, 0
#         addi    x0, x0, 0
# br2ret: bne     x7, x0, br3             #bne taken
#         addi    x0, x0, 0
#         addi    x0, x0, 0
#         addi    x0, x0, 0
#         addi    x0, x0, 0
# br3ret: bne     x6, x0, br4             #bne not taken
#         addi    x0, x0, 0
#         addi    x0, x0, 0
#         addi    x0, x0, 0
#         addi    x0, x0, 0
#         addi    x5, x5, 1               #x5 = 4
#         addi    x0, x0, 0
#         addi    x0, x0, 0
#         addi    x0, x0, 0
# br4ret: blt     x7, x6, br5             #blt taken
#         addi    x0, x0, 0
#         addi    x0, x0, 0
#         addi    x0, x0, 0
#         addi    x0, x0, 0
# br5ret: blt     x6, x7, br6             #blt not taken
#         addi    x0, x0, 0
#         addi    x0, x0, 0
#         addi    x0, x0, 0
#         addi    x0, x0, 0
#         addi    x5, x5, 1               #x5 = 6
#         addi    x0, x0, 0
#         addi    x0, x0, 0
#         addi    x0, x0, 0
# br6ret: bge     x6, x0, br7             #bge taken
#         addi    x0, x0, 0
#         addi    x0, x0, 0
#         addi    x0, x0, 0
#         addi    x0, x0, 0
# br7ret: bge     x6, x7, br8             #bge taken
#         addi    x0, x0, 0
#         addi    x0, x0, 0
#         addi    x0, x0, 0
#         addi    x0, x0, 0
# br8ret: bge     x7, x0, br9             #bge not taken
#         addi    x0, x0, 0
#         addi    x0, x0, 0
#         addi    x0, x0, 0
#         addi    x0, x0, 0
#         addi    x5, x5, 1               #x5 = 9
#         addi    x0, x0, 0
#         addi    x0, x0, 0
#         addi    x0, x0, 0
# br9ret: bltu    x6, x7, br10            #bltu taken
#         addi    x0, x0, 0
#         addi    x0, x0, 0
#         addi    x0, x0, 0
#         addi    x0, x0, 0
# br10ret:bltu    x7, x6, br11            #bltu not taken
#         addi    x0, x0, 0
#         addi    x0, x0, 0
#         addi    x0, x0, 0
#         addi    x0, x0, 0
#         addi    x5, x5, 1               #x5 = 0xB
#         addi    x0, x0, 0
#         addi    x0, x0, 0
#         addi    x0, x0, 0
# br11ret:bgeu    x7, x6, br12            #bgtu taken
#         addi    x0, x0, 0
#         addi    x0, x0, 0
#         addi    x0, x0, 0
#         addi    x0, x0, 0
# br12ret:bgeu    x6, x7, br13            #bgtu not taken
#         addi    x0, x0, 0
#         addi    x0, x0, 0
#         addi    x0, x0, 0
#         addi    x0, x0, 0
#         addi    x5, x5, 1               #x5 = 0xD
#         addi    x0, x0, 0
#         addi    x0, x0, 0
#         addi    x0, x0, 0
# br13ret:jal     x0, end                  #x5 should be 0xD for correct implementation
#         addi    x0, x0, 0
#         addi    x0, x0, 0
#         addi    x0, x0, 0

# br1:    addi    x5, x5, 1               #x5 = 1
#         addi    x0, x0, 0
#         addi    x0, x0, 0
#         addi    x0, x0, 0
#         jal     x0, br1ret
#         addi    x0, x0, 0
#         addi    x0, x0, 0
#         addi    x0, x0, 0
#         addi    x0, x0, 0

# br2:    jal     x0, br2ret
#         addi    x0, x0, 0
#         addi    x0, x0, 0
#         addi    x0, x0, 0
#         addi    x0, x0, 0

# br3:    addi    x5, x5, 1               #x5 = 3
#         addi    x0, x0, 0
#         addi    x0, x0, 0
#         addi    x0, x0, 0
#         jal     x0, br3ret
#         addi    x0, x0, 0
#         addi    x0, x0, 0
#         addi    x0, x0, 0
#         addi    x0, x0, 0

# br4:    jal     x0, br4ret
#         addi    x0, x0, 0
#         addi    x0, x0, 0
#         addi    x0, x0, 0
#         addi    x0, x0, 0

# br5:    addi    x5, x5, 1               #x5 = 5
#         addi    x0, x0, 0
#         addi    x0, x0, 0
#         addi    x0, x0, 0
#         jal     x0, br5ret
#         addi    x0, x0, 0
#         addi    x0, x0, 0
#         addi    x0, x0, 0
#         addi    x0, x0, 0

# br6:    jal     x0, br6ret
#         addi    x0, x0, 0
#         addi    x0, x0, 0
#         addi    x0, x0, 0
#         addi    x0, x0, 0

# br7:    addi    x5, x5, 1               #x5 = 7
#         addi    x0, x0, 0
#         addi    x0, x0, 0
#         addi    x0, x0, 0
#         jal     x0, br7ret
#         addi    x0, x0, 0
#         addi    x0, x0, 0
#         addi    x0, x0, 0
#         addi    x0, x0, 0

# br8:    addi    x5, x5, 1               #x5 = 8
#         addi    x0, x0, 0
#         addi    x0, x0, 0
#         addi    x0, x0, 0
#         jal     x0, br8ret
#         addi    x0, x0, 0
#         addi    x0, x0, 0
#         addi    x0, x0, 0
#         addi    x0, x0, 0

# br9:    jal     x0, br9ret
#         addi    x0, x0, 0
#         addi    x0, x0, 0
#         addi    x0, x0, 0
#         addi    x0, x0, 0

# br10:   addi    x5, x5, 1               #x5 = 0xA
#         addi    x0, x0, 0
#         addi    x0, x0, 0
#         addi    x0, x0, 0
#         jal     x0, br10ret
#         addi    x0, x0, 0
#         addi    x0, x0, 0
#         addi    x0, x0, 0
#         addi    x0, x0, 0

# br11:   jal     x0, br11ret
#         addi    x0, x0, 0
#         addi    x0, x0, 0
#         addi    x0, x0, 0
#         addi    x0, x0, 0

# br12:   addi    x5, x5, 1               #x5 = 0xC
#         addi    x0, x0, 0
#         addi    x0, x0, 0
#         addi    x0, x0, 0
#         jal     x0, br12ret
#         addi    x0, x0, 0
#         addi    x0, x0, 0
#         addi    x0, x0, 0
#         addi    x0, x0, 0

# br13:   jal     x0, br13ret
#         addi    x0, x0, 0
#         addi    x0, x0, 0
#         addi    x0, x0, 0
#         addi    x0, x0, 0

# end:    addi    x5, x5, 1

0x0	0x00000293	addi x5 x0 0	main: addi x5, x0, 0 #x5 <== 0x0
0x4	0x00000313	addi x6 x0 0	addi x6, x0, 0 #x6 <== 0x0
0x8	0xFFFFF3B7	lui x7 1048575	lui x7, 0xfffff #x7 <== 0xFFFFF000
0xc	0x00000013	addi x0 x0 0	addi x0, x0, 0 #instr 00000013
0x10	0x00000013	addi x0 x0 0	addi x0, x0, 0
0x14	0x00000013	addi x0 x0 0	addi x0, x0, 0
0x18	0x16030A63	beq x6 x0 372	beq x6, x0, br1 #beq taken
0x1c	0x00000013	addi x0 x0 0	addi x0, x0, 0
0x20	0x00000013	addi x0 x0 0	addi x0, x0, 0
0x24	0x00000013	addi x0 x0 0	addi x0, x0, 0
0x28	0x00000013	addi x0 x0 0	addi x0, x0, 0
0x2c	0x02038263	beq x7 x0 36	br1ret: beq x7, x0, br2ret #beq not taken
0x30	0x00000013	addi x0 x0 0	addi x0, x0, 0
0x34	0x00000013	addi x0 x0 0	addi x0, x0, 0
0x38	0x00000013	addi x0 x0 0	addi x0, x0, 0
0x3c	0x00000013	addi x0 x0 0	addi x0, x0, 0
0x40	0x00128293	addi x5 x5 1	addi x5, x5, 1 #x5 = 2
0x44	0x00000013	addi x0 x0 0	addi x0, x0, 0
0x48	0x00000013	addi x0 x0 0	addi x0, x0, 0
0x4c	0x00000013	addi x0 x0 0	addi x0, x0, 0
0x50	0x16039A63	bne x7 x0 372	br2ret: bne x7, x0, br3 #bne taken
0x54	0x00000013	addi x0 x0 0	addi x0, x0, 0
0x58	0x00000013	addi x0 x0 0	addi x0, x0, 0
0x5c	0x00000013	addi x0 x0 0	addi x0, x0, 0
0x60	0x00000013	addi x0 x0 0	addi x0, x0, 0
0x64	0x18031263	bne x6 x0 388	br3ret: bne x6, x0, br4 #bne not taken
0x68	0x00000013	addi x0 x0 0	addi x0, x0, 0
0x6c	0x00000013	addi x0 x0 0	addi x0, x0, 0
0x70	0x00000013	addi x0 x0 0	addi x0, x0, 0
0x74	0x00000013	addi x0 x0 0	addi x0, x0, 0
0x78	0x00128293	addi x5 x5 1	addi x5, x5, 1 #x5 = 4
0x7c	0x00000013	addi x0 x0 0	addi x0, x0, 0
0x80	0x00000013	addi x0 x0 0	addi x0, x0, 0
0x84	0x00000013	addi x0 x0 0	addi x0, x0, 0
0x88	0x1663CA63	blt x7 x6 372	br4ret: blt x7, x6, br5 #blt taken
0x8c	0x00000013	addi x0 x0 0	addi x0, x0, 0
0x90	0x00000013	addi x0 x0 0	addi x0, x0, 0
0x94	0x00000013	addi x0 x0 0	addi x0, x0, 0
0x98	0x00000013	addi x0 x0 0	addi x0, x0, 0
0x9c	0x18734263	blt x6 x7 388	br5ret: blt x6, x7, br6 #blt not taken
0xa0	0x00000013	addi x0 x0 0	addi x0, x0, 0
0xa4	0x00000013	addi x0 x0 0	addi x0, x0, 0
0xa8	0x00000013	addi x0 x0 0	addi x0, x0, 0
0xac	0x00000013	addi x0 x0 0	addi x0, x0, 0
0xb0	0x00128293	addi x5 x5 1	addi x5, x5, 1 #x5 = 6
0xb4	0x00000013	addi x0 x0 0	addi x0, x0, 0
0xb8	0x00000013	addi x0 x0 0	addi x0, x0, 0
0xbc	0x00000013	addi x0 x0 0	addi x0, x0, 0
0xc0	0x16035A63	bge x6 x0 372	br6ret: bge x6, x0, br7 #bge taken
0xc4	0x00000013	addi x0 x0 0	addi x0, x0, 0
0xc8	0x00000013	addi x0 x0 0	addi x0, x0, 0
0xcc	0x00000013	addi x0 x0 0	addi x0, x0, 0
0xd0	0x00000013	addi x0 x0 0	addi x0, x0, 0
0xd4	0x18735263	bge x6 x7 388	br7ret: bge x6, x7, br8 #bge taken
0xd8	0x00000013	addi x0 x0 0	addi x0, x0, 0
0xdc	0x00000013	addi x0 x0 0	addi x0, x0, 0
0xe0	0x00000013	addi x0 x0 0	addi x0, x0, 0
0xe4	0x00000013	addi x0 x0 0	addi x0, x0, 0
0xe8	0x1803DA63	bge x7 x0 404	br8ret: bge x7, x0, br9 #bge not taken
0xec	0x00000013	addi x0 x0 0	addi x0, x0, 0
0xf0	0x00000013	addi x0 x0 0	addi x0, x0, 0
0xf4	0x00000013	addi x0 x0 0	addi x0, x0, 0
0xf8	0x00000013	addi x0 x0 0	addi x0, x0, 0
0xfc	0x00128293	addi x5 x5 1	addi x5, x5, 1 #x5 = 9
0x100	0x00000013	addi x0 x0 0	addi x0, x0, 0
0x104	0x00000013	addi x0 x0 0	addi x0, x0, 0
0x108	0x00000013	addi x0 x0 0	addi x0, x0, 0
0x10c	0x18736263	bltu x6 x7 388	br9ret: bltu x6, x7, br10 #bltu taken
0x110	0x00000013	addi x0 x0 0	addi x0, x0, 0
0x114	0x00000013	addi x0 x0 0	addi x0, x0, 0
0x118	0x00000013	addi x0 x0 0	addi x0, x0, 0
0x11c	0x00000013	addi x0 x0 0	addi x0, x0, 0
0x120	0x1863EA63	bltu x7 x6 404	br10ret:bltu x7, x6, br11 #bltu not taken
0x124	0x00000013	addi x0 x0 0	addi x0, x0, 0
0x128	0x00000013	addi x0 x0 0	addi x0, x0, 0
0x12c	0x00000013	addi x0 x0 0	addi x0, x0, 0
0x130	0x00000013	addi x0 x0 0	addi x0, x0, 0
0x134	0x00128293	addi x5 x5 1	addi x5, x5, 1 #x5 = 0xB
0x138	0x00000013	addi x0 x0 0	addi x0, x0, 0
0x13c	0x00000013	addi x0 x0 0	addi x0, x0, 0
0x140	0x00000013	addi x0 x0 0	addi x0, x0, 0
0x144	0x1863F263	bgeu x7 x6 388	br11ret:bgeu x7, x6, br12 #bgtu taken
0x148	0x00000013	addi x0 x0 0	addi x0, x0, 0
0x14c	0x00000013	addi x0 x0 0	addi x0, x0, 0
0x150	0x00000013	addi x0 x0 0	addi x0, x0, 0
0x154	0x00000013	addi x0 x0 0	addi x0, x0, 0
0x158	0x18737A63	bgeu x6 x7 404	br12ret:bgeu x6, x7, br13 #bgtu not taken
0x15c	0x00000013	addi x0 x0 0	addi x0, x0, 0
0x160	0x00000013	addi x0 x0 0	addi x0, x0, 0
0x164	0x00000013	addi x0 x0 0	addi x0, x0, 0
0x168	0x00000013	addi x0 x0 0	addi x0, x0, 0
0x16c	0x00128293	addi x5 x5 1	addi x5, x5, 1 #x5 = 0xD
0x170	0x00000013	addi x0 x0 0	addi x0, x0, 0
0x174	0x00000013	addi x0 x0 0	addi x0, x0, 0
0x178	0x00000013	addi x0 x0 0	addi x0, x0, 0
0x17c	0x1840006F	jal x0 388	br13ret:jal x0, end #x5 should be 0xD for correct implementation
0x180	0x00000013	addi x0 x0 0	addi x0, x0, 0
0x184	0x00000013	addi x0 x0 0	addi x0, x0, 0
0x188	0x00000013	addi x0 x0 0	addi x0, x0, 0
0x18c	0x00128293	addi x5 x5 1	br1: addi x5, x5, 1 #x5 = 1
0x190	0x00000013	addi x0 x0 0	addi x0, x0, 0
0x194	0x00000013	addi x0 x0 0	addi x0, x0, 0
0x198	0x00000013	addi x0 x0 0	addi x0, x0, 0
0x19c	0xE91FF06F	jal x0 -368	jal x0, br1ret
0x1a0	0x00000013	addi x0 x0 0	addi x0, x0, 0
0x1a4	0x00000013	addi x0 x0 0	addi x0, x0, 0
0x1a8	0x00000013	addi x0 x0 0	addi x0, x0, 0
0x1ac	0x00000013	addi x0 x0 0	addi x0, x0, 0
0x1b0	0xEA1FF06F	jal x0 -352	br2: jal x0, br2ret
0x1b4	0x00000013	addi x0 x0 0	addi x0, x0, 0
0x1b8	0x00000013	addi x0 x0 0	addi x0, x0, 0
0x1bc	0x00000013	addi x0 x0 0	addi x0, x0, 0
0x1c0	0x00000013	addi x0 x0 0	addi x0, x0, 0
0x1c4	0x00128293	addi x5 x5 1	br3: addi x5, x5, 1 #x5 = 3
0x1c8	0x00000013	addi x0 x0 0	addi x0, x0, 0
0x1cc	0x00000013	addi x0 x0 0	addi x0, x0, 0
0x1d0	0x00000013	addi x0 x0 0	addi x0, x0, 0
0x1d4	0xE91FF06F	jal x0 -368	jal x0, br3ret
0x1d8	0x00000013	addi x0 x0 0	addi x0, x0, 0
0x1dc	0x00000013	addi x0 x0 0	addi x0, x0, 0
0x1e0	0x00000013	addi x0 x0 0	addi x0, x0, 0
0x1e4	0x00000013	addi x0 x0 0	addi x0, x0, 0
0x1e8	0xEA1FF06F	jal x0 -352	br4: jal x0, br4ret
0x1ec	0x00000013	addi x0 x0 0	addi x0, x0, 0
0x1f0	0x00000013	addi x0 x0 0	addi x0, x0, 0
0x1f4	0x00000013	addi x0 x0 0	addi x0, x0, 0
0x1f8	0x00000013	addi x0 x0 0	addi x0, x0, 0
0x1fc	0x00128293	addi x5 x5 1	br5: addi x5, x5, 1 #x5 = 5
0x200	0x00000013	addi x0 x0 0	addi x0, x0, 0
0x204	0x00000013	addi x0 x0 0	addi x0, x0, 0
0x208	0x00000013	addi x0 x0 0	addi x0, x0, 0
0x20c	0xE91FF06F	jal x0 -368	jal x0, br5ret
0x210	0x00000013	addi x0 x0 0	addi x0, x0, 0
0x214	0x00000013	addi x0 x0 0	addi x0, x0, 0
0x218	0x00000013	addi x0 x0 0	addi x0, x0, 0
0x21c	0x00000013	addi x0 x0 0	addi x0, x0, 0
0x220	0xEA1FF06F	jal x0 -352	br6: jal x0, br6ret
0x224	0x00000013	addi x0 x0 0	addi x0, x0, 0
0x228	0x00000013	addi x0 x0 0	addi x0, x0, 0
0x22c	0x00000013	addi x0 x0 0	addi x0, x0, 0
0x230	0x00000013	addi x0 x0 0	addi x0, x0, 0
0x234	0x00128293	addi x5 x5 1	br7: addi x5, x5, 1 #x5 = 7
0x238	0x00000013	addi x0 x0 0	addi x0, x0, 0
0x23c	0x00000013	addi x0 x0 0	addi x0, x0, 0
0x240	0x00000013	addi x0 x0 0	addi x0, x0, 0
0x244	0xE91FF06F	jal x0 -368	jal x0, br7ret
0x248	0x00000013	addi x0 x0 0	addi x0, x0, 0
0x24c	0x00000013	addi x0 x0 0	addi x0, x0, 0
0x250	0x00000013	addi x0 x0 0	addi x0, x0, 0
0x254	0x00000013	addi x0 x0 0	addi x0, x0, 0
0x258	0x00128293	addi x5 x5 1	br8: addi x5, x5, 1 #x5 = 8
0x25c	0x00000013	addi x0 x0 0	addi x0, x0, 0
0x260	0x00000013	addi x0 x0 0	addi x0, x0, 0
0x264	0x00000013	addi x0 x0 0	addi x0, x0, 0
0x268	0xE81FF06F	jal x0 -384	jal x0, br8ret
0x26c	0x00000013	addi x0 x0 0	addi x0, x0, 0
0x270	0x00000013	addi x0 x0 0	addi x0, x0, 0
0x274	0x00000013	addi x0 x0 0	addi x0, x0, 0
0x278	0x00000013	addi x0 x0 0	addi x0, x0, 0
0x27c	0xE91FF06F	jal x0 -368	br9: jal x0, br9ret
0x280	0x00000013	addi x0 x0 0	addi x0, x0, 0
0x284	0x00000013	addi x0 x0 0	addi x0, x0, 0
0x288	0x00000013	addi x0 x0 0	addi x0, x0, 0
0x28c	0x00000013	addi x0 x0 0	addi x0, x0, 0
0x290	0x00128293	addi x5 x5 1	br10: addi x5, x5, 1 #x5 = 0xA
0x294	0x00000013	addi x0 x0 0	addi x0, x0, 0
0x298	0x00000013	addi x0 x0 0	addi x0, x0, 0
0x29c	0x00000013	addi x0 x0 0	addi x0, x0, 0
0x2a0	0xE81FF06F	jal x0 -384	jal x0, br10ret
0x2a4	0x00000013	addi x0 x0 0	addi x0, x0, 0
0x2a8	0x00000013	addi x0 x0 0	addi x0, x0, 0
0x2ac	0x00000013	addi x0 x0 0	addi x0, x0, 0
0x2b0	0x00000013	addi x0 x0 0	addi x0, x0, 0
0x2b4	0xE91FF06F	jal x0 -368	br11: jal x0, br11ret
0x2b8	0x00000013	addi x0 x0 0	addi x0, x0, 0
0x2bc	0x00000013	addi x0 x0 0	addi x0, x0, 0
0x2c0	0x00000013	addi x0 x0 0	addi x0, x0, 0
0x2c4	0x00000013	addi x0 x0 0	addi x0, x0, 0
0x2c8	0x00128293	addi x5 x5 1	br12: addi x5, x5, 1 #x5 = 0xC
0x2cc	0x00000013	addi x0 x0 0	addi x0, x0, 0
0x2d0	0x00000013	addi x0 x0 0	addi x0, x0, 0
0x2d4	0x00000013	addi x0 x0 0	addi x0, x0, 0
0x2d8	0xE81FF06F	jal x0 -384	jal x0, br12ret
0x2dc	0x00000013	addi x0 x0 0	addi x0, x0, 0
0x2e0	0x00000013	addi x0 x0 0	addi x0, x0, 0
0x2e4	0x00000013	addi x0 x0 0	addi x0, x0, 0
0x2e8	0x00000013	addi x0 x0 0	addi x0, x0, 0
0x2ec	0xE91FF06F	jal x0 -368	br13: jal x0, br13ret
0x2f0	0x00000013	addi x0 x0 0	addi x0, x0, 0
0x2f4	0x00000013	addi x0 x0 0	addi x0, x0, 0
0x2f8	0x00000013	addi x0 x0 0	addi x0, x0, 0
0x2fc	0x00000013	addi x0 x0 0	addi x0, x0, 0
0x300	0x00128293	addi x5 x5 1	end: addi x5, x5, 1