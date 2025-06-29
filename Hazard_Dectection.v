`include "ctrl_encode_def.v"
module Hazard_detection (
    input            ID_EX_MemRead,
    input            EX_MEM_MemRead,
    input            ID_EX_RegWrite,
    input      [4:0] rs1,
    input      [4:0] rs2,
    input      [4:0] ID_EX_rd,
    input      [4:0] EX_MEM_rd,
    input      [2:0] NPCOp,
    output reg       Stall
);

  always @(*) begin
    Stall = 1'b0;  // 默认值

    // 第一个阶段 load-use hazard
    if (ID_EX_MemRead && (ID_EX_rd != 5'd0) && ((ID_EX_rd == rs1) || (ID_EX_rd == rs2))) begin
      Stall = 1'b1;
    end

    // Jalr 或 Branch 对 ID_EX_rd 的依赖
    if ((NPCOp == `NPC_BRANCH || NPCOp == `NPC_JALR) &&
      ID_EX_RegWrite && (ID_EX_rd != 5'd0) &&
      ((ID_EX_rd == rs1) || (ID_EX_rd == rs2))) begin
      Stall = 1'b1;
    end

    // 第二阶段 load-use hazard
    if (EX_MEM_MemRead && (EX_MEM_rd != 5'd0) && ((EX_MEM_rd == rs1) || (EX_MEM_rd == rs2))) begin
      Stall = 1'b1;
    end
  end



endmodule
