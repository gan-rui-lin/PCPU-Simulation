module Forward_unit(
    input  [4:0] ID_EX_rs1,               // ID/EX.rs1
    input  [4:0] ID_EX_rs2,               // ID/EX.rs2
    input  [4:0] EX_MEM_rd,            // EX/MEM.rd
    input  [4:0] MEM_WB_rd,            // MEM/WB.rd
    input        EX_MEM_RegWrite,      // EX/MEM.RegWrite
    input        MEM_WB_RegWrite,      // MEM/WB.RegWrite
    output [1:0] ForwardA,
    output [1:0] ForwardB
);

    wire EX_MEM_ForwardA = (EX_MEM_rd != 0) && (EX_MEM_rd == ID_EX_rs1) && EX_MEM_RegWrite;
    wire MEM_WB_ForwardA = (MEM_WB_rd != 0) && (MEM_WB_rd == ID_EX_rs1) && MEM_WB_RegWrite && !EX_MEM_ForwardA;

    wire EX_MEM_ForwardB = (EX_MEM_rd != 0) && (EX_MEM_rd == ID_EX_rs2) && EX_MEM_RegWrite;
    wire MEM_WB_ForwardB = (MEM_WB_rd != 0) && (MEM_WB_rd == ID_EX_rs2) && MEM_WB_RegWrite && !EX_MEM_ForwardB;

    // 优先 forward EX_MEM 旁路的值
    assign ForwardA = EX_MEM_ForwardA ? 2'b10 :
                      MEM_WB_ForwardA ? 2'b01 : 
                      2'b00;

    assign ForwardB = EX_MEM_ForwardB ? 2'b10 :
                      MEM_WB_ForwardB ? 2'b01 :
                      2'b00;

endmodule
