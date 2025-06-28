`include "ctrl_encode_def.v"
module Hazard_detection (
    input        ID_EX_MemRead,
    input        EX_MEM_MemRead,
    input        ID_EX_RegWrite,
    input  [4:0] rs1,
    input  [4:0] rs2,
    input  [4:0] ID_EX_rd,
    input  [4:0] EX_MEM_rd,
    input  [2:0] NPCOp,
    output [1:0] Stall
);

  reg Stall_EX;
  reg Stall_ID;

  always @(*) begin
    Stall_EX = 1'b0;  // 默认值
    Stall_ID = 1'b0;  // 默认值

    if (ID_EX_rd != 5'd0) begin
      if (ID_EX_MemRead && ((ID_EX_rd == rs1) || (ID_EX_rd == rs2))) begin
        Stall_EX = 1'b1;
      end
      if ((NPCOp == `NPC_BRANCH || NPCOp == `NPC_JALR) && ID_EX_RegWrite && ((ID_EX_rd == rs1) || (ID_EX_rd == rs2))) begin
        Stall_ID = 1'b1;
      end
    end else if (EX_MEM_rd != 5'd0) begin
      if ((NPCOp == `NPC_BRANCH || NPCOp == `NPC_JALR) && EX_MEM_MemRead && ((EX_MEM_rd == rs1) || (EX_MEM_rd == rs2))) begin
        Stall_ID = 1'b1;
      end
    end
  end


  assign Stall = {Stall_EX, Stall_ID};

endmodule
