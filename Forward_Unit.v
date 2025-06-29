`include "ctrl_encode_def.v"

module Forward_unit (
    input  [4:0] ID_EX_rs1,        // ID/EX.rs1
    input  [4:0] ID_EX_rs2,        // ID/EX.rs2
    input  [4:0] EX_MEM_rd,        // EX/MEM.rd
    input  [4:0] MEM_WB_rd,        // MEM/WB.rd
    input        EX_MEM_RegWrite,  // EX/MEM.RegWrite
    input        MEM_WB_RegWrite,  // MEM/WB.RegWrite
    input EX_MEM_MemRead,
    input MEM_WB_MemRead,
    input  [2:0] NPCOp,
    input  [4:0] rs1,
    input [4:0] rs2,
    output [3:0] ForwardA,
    output [3:0] ForwardB
);

  // 送出 ALUOut(上一条一定是 RegWrite 指令, 不能是 lw 指令, 不然送的不对)
  wire EX_MEM_ForwardA = (EX_MEM_rd != 0) && (EX_MEM_rd == ID_EX_rs1) && EX_MEM_RegWrite && (!EX_MEM_MemRead);

  // 送出 WD(可能是 ALUOut 或者 MemData)
  // RegWrite -> ALUOut / (PC + 4)
  // MemRead  -> WD 对应 内存数据
  wire MEM_WB_ForwardA = (MEM_WB_rd != 0) && (MEM_WB_rd == ID_EX_rs1) && (MEM_WB_RegWrite || MEM_WB_MemRead) && !EX_MEM_ForwardA;

  // 跳转指令需要的前递(ID判断分支条件是否成立), 如 beq, jal, jalr

  wire ID_EX_ForwardA = (EX_MEM_rd != 0) && (EX_MEM_rd == rs1) && (EX_MEM_RegWrite) && (!EX_MEM_MemRead) && (NPCOp == `NPC_BRANCH || NPCOp == `NPC_JALR || NPCOp == `NPC_JUMP);

  // 送出 WD(可能是 ALUOut 或者 MemData)
  wire ID_MEM_ForwardA = (MEM_WB_rd != 0) && (MEM_WB_rd == rs1) && (MEM_WB_RegWrite || MEM_WB_MemRead) && (NPCOp == `NPC_BRANCH || NPCOp == `NPC_JALR || NPCOp == `NPC_JUMP) && !ID_EX_ForwardA;

  wire EX_MEM_ForwardB = (EX_MEM_rd != 0) && (EX_MEM_rd == ID_EX_rs2) && EX_MEM_RegWrite;

  // 送出 WD(可能是 ALUOut 或者 MemData)
  wire MEM_WB_ForwardB = (MEM_WB_rd != 0) && (MEM_WB_rd == ID_EX_rs2) && (MEM_WB_RegWrite || MEM_WB_MemRead) && !EX_MEM_ForwardB;

  wire ID_EX_ForwardB = (EX_MEM_rd != 0) && (EX_MEM_rd == rs2) && (EX_MEM_RegWrite) && (!EX_MEM_MemRead) && (NPCOp == `NPC_BRANCH || NPCOp == `NPC_JALR || NPCOp == `NPC_JUMP);

  // 送出 WD(可能是 ALUOut 或者 MemData)
  wire ID_MEM_ForwardB = (MEM_WB_rd != 0) && (MEM_WB_rd == rs2) && (MEM_WB_RegWrite || MEM_WB_MemRead) && (NPCOp == `NPC_BRANCH || NPCOp == `NPC_JALR || NPCOp == `NPC_JUMP) && !ID_EX_ForwardB;

  // 优先 forward EX_MEM 旁路的值 
  assign ForwardA = {ID_EX_ForwardA, ID_MEM_ForwardA, EX_MEM_ForwardA, MEM_WB_ForwardA};

  assign ForwardB = {ID_EX_ForwardB, ID_MEM_ForwardB, EX_MEM_ForwardB, MEM_WB_ForwardB};

endmodule
