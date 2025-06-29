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
    output reg Stall
);

  always @(*) begin
    Stall = 1'b0;  // 默认值

    if (ID_EX_rd != 5'd0) begin
      // load-use 型
      if (ID_EX_MemRead && ((ID_EX_rd == rs1) || (ID_EX_rd == rs2))) begin
        Stall= 1'b1;
      end
      // Addi Jalr/B
      if ((NPCOp == `NPC_BRANCH || NPCOp == `NPC_JALR) && ID_EX_RegWrite && ((ID_EX_rd == rs1) || (ID_EX_rd == rs2))) begin
        Stall = 1'b1;
      end
    end 
    // 这里是 if 就会让 Stall 由 1 到 0
    else if (EX_MEM_rd != 5'd0) begin
      // load-use 型的第二次停顿
      if (EX_MEM_MemRead && ((EX_MEM_rd == rs1) || (EX_MEM_rd == rs2))) begin
        Stall = 1'b1;
      end
    end
    else begin
      Stall = 1'b0;
    end
  end


endmodule
