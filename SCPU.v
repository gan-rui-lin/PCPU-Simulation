`include "ctrl_encode_def.v"
module SCPU (
    input        clk,      // clock
    input        reset,    // reset
    input [31:0] inst_in,  // instruction
    input [31:0] Data_in,  // data from data memory

    output        mem_w,     // output: memory write signal
    output [31:0] PC_out,    // PC address
    // memory write
    output [31:0] Addr_out,  // ALU output
    output [31:0] Data_out,  // data to data memory

    input  [ 4:0] reg_sel,    // register selection (for debug use)
    output [31:0] reg_data,   // selected register data (for debug use)
    output [ 2:0] DMType_out
);
  wire        MemWrite;
  wire        RegWrite;  // control signal to register write
  wire [ 5:0] EXTOp;  // control signal to signed extension
  wire [ 4:0] ALUOp;  // ALU opertion
  wire [ 2:0] NPCOp;  // next PC operation

  wire [ 1:0] WDSel;  // (register) write data selection
  wire [ 1:0] GPRSel;  // general purpose register selection

  wire        ALUSrc;  // ALU source for A
  wire        Zero;  // ALU ouput zero

  wire [31:0] NPC;  // next PC

  wire [ 4:0] rs1;  // rs
  wire [ 4:0] rs2;  // rt
  wire [ 4:0] rd;  // rd
  wire [ 6:0] Op;  // opcode
  wire [ 6:0] Funct7;  // funct7
  wire [ 2:0] Funct3;  // funct3
  wire [11:0] Imm12;  // 12-bit immediate
  wire [31:0] Imm32;  // 32-bit immediate
  wire [19:0] IMM;  // 20-bit immediate (address)
  wire [ 4:0] A3;  // register address for write, 来自 MEM/WB 寄存器
  reg  [31:0] WD;  // register write data, 来自 MEM/WB 寄存器
  wire [31:0] RD1, RD2;  // register data specified by rs
  wire [31:0] B;  // operator for ALU B
  wire [ 2:0] DMType;

  wire [ 4:0] iimm_shamt;
  wire [11:0] iimm, simm, bimm;
  wire [19:0] uimm, jimm;
  wire [31:0] immout;
  wire [31:0] aluout;
  assign Addr_out = aluout;
  assign B = (ALUSrc) ? immout : RD2;


  // IF/ID
  reg IF_ID_valid;
  reg [31:0] IF_ID_PC, IF_ID_Inst;
  always @(posedge clk) begin
    if (reset) IF_ID_valid <= 0;
    else begin
      IF_ID_valid <= 1;
      IF_ID_PC <= PC_out;
      IF_ID_Inst <= inst_in;
    end
  end

  // 从 IF/ID 寄存器里面取指令
  assign iimm_shamt = IF_ID_Inst[24:20];
  assign iimm = IF_ID_Inst[31:20];
  assign simm = {IF_ID_Inst[31:25], IF_ID_Inst[11:7]};
  assign bimm = {IF_ID_Inst[31], IF_ID_Inst[7], IF_ID_Inst[30:25], IF_ID_Inst[11:8]};
  assign uimm = IF_ID_Inst[31:12];
  assign jimm = {IF_ID_Inst[31], IF_ID_Inst[19:12], IF_ID_Inst[20], IF_ID_Inst[30:21]};

  assign Op = IF_ID_Inst[6:0];  // instruction
  assign Funct7 = IF_ID_Inst[31:25];  // funct7
  assign Funct3 = IF_ID_Inst[14:12];  // funct3
  assign rs1 = IF_ID_Inst[19:15];  // rs1
  assign rs2 = IF_ID_Inst[24:20];  // rs2
  assign rd = IF_ID_Inst[11:7];  // rd
  assign Imm12 = IF_ID_Inst[31:20];  // 12-bit immediate
  assign IMM = IF_ID_Inst[31:12];  // 20-bit immediate

  // ID/EX
  reg ID_EX_valid;
  reg [31:0] ID_EX_PC, ID_EX_RD1, ID_EX_RD2, ID_EX_Imm;
  reg [4:0] ID_EX_rs1, ID_EX_rs2, ID_EX_rd;
  reg [4:0] ID_EX_ALUOp;
  reg ID_EX_ALUSrc, ID_EX_RegWrite;
  reg [1:0] ID_EX_WDSel;
  reg [2:0] ID_EX_DMType;
  always @(posedge clk) begin
    if (reset) ID_EX_valid <= 0;
    else begin
      ID_EX_valid <= IF_ID_valid;
      ID_EX_PC <= IF_ID_PC;  // 往后传就是了
      ID_EX_RD1 <= RD1;
      ID_EX_RD2 <= RD2;
      ID_EX_Imm <= immout;
      ID_EX_rs1 <= rs1;
      ID_EX_rs2 <= rs2;
      ID_EX_rd <= rd;
      ID_EX_ALUOp <= ALUOp;
      ID_EX_ALUSrc <= ALUSrc;
      ID_EX_RegWrite <= RegWrite;
      ID_EX_WDSel <= WDSel;
      ID_EX_DMType <= DMType;
    end
  end

  // EX/MEM
  reg EX_MEM_valid;
  reg [31:0] EX_MEM_ALUResult, EX_MEM_RD2, EX_MEM_PC;
  reg [4:0] EX_MEM_rd;
  reg EX_MEM_RegWrite, EX_MEM_MemWrite;
  reg [1:0] EX_MEM_WDSel;
  reg [2:0] EX_MEM_DMType;
  always @(posedge clk) begin
    if (reset) EX_MEM_valid <= 0;
    else begin
      EX_MEM_valid <= ID_EX_valid;
      EX_MEM_PC <= ID_EX_PC;  // 最终到 MEM_WB_PC
      EX_MEM_ALUResult <= aluout;
      EX_MEM_RD2 <= ID_EX_RD2;
      EX_MEM_rd <= ID_EX_rd;
      EX_MEM_RegWrite <= ID_EX_RegWrite;
      EX_MEM_MemWrite <= MemWrite;
      EX_MEM_WDSel <= ID_EX_WDSel;
      EX_MEM_DMType <= ID_EX_DMType;
    end
  end

  assign DMType_out = EX_MEM_DMType;

  // MEM/WB
  reg MEM_WB_valid;
  reg [31:0] MEM_WB_MemData, MEM_WB_ALUResult, MEM_WB_PC;
  reg [4:0] MEM_WB_rd;
  reg MEM_WB_RegWrite;
  reg [1:0] MEM_WB_WDSel;
  always @(posedge clk) begin
    if (reset) MEM_WB_valid <= 0;
    else begin
      MEM_WB_PC <= EX_MEM_PC;
      MEM_WB_valid <= EX_MEM_valid;
      MEM_WB_MemData <= Data_in;
      MEM_WB_ALUResult <= EX_MEM_ALUResult;
      MEM_WB_rd <= EX_MEM_rd;
      MEM_WB_RegWrite <= EX_MEM_RegWrite;
      MEM_WB_WDSel <= EX_MEM_WDSel;
    end
  end

  // 控制模块
  ctrl U_ctrl (
      .Op(Op),
      .Funct7(Funct7),
      .Funct3(Funct3),
      .Zero(Zero),
      .RegWrite(RegWrite),
      .MemWrite(MemWrite),
      .EXTOp(EXTOp),
      .ALUOp(ALUOp),
      .NPCOp(NPCOp),
      .ALUSrc(ALUSrc),
      .GPRSel(GPRSel),
      .WDSel(WDSel),
      .DMType(DMType)
  );

  PC U_PC (
      .clk(clk),
      .rst(reset),
      .NPC(NPC),
      .PC (PC_out)
  );
  NPC U_NPC (
      .PC(PC_out),
      .NPCOp(NPCOp),
      .IMM(immout),
      .aluout(aluout),
      .NPC(NPC)
  );
  EXT U_EXT (
      .iimm_shamt(iimm_shamt),
      .iimm(iimm),
      .simm(simm),
      .bimm(bimm),
      .uimm(uimm),
      .jimm(jimm),
      .EXTOp(EXTOp),
      .immout(immout)
  );

  RF U_RF (
      .clk(clk),
      .rst(reset),
      .RFWr(MEM_WB_RegWrite),
      .A1(rs1),
      .A2(rs2),
      .A3(MEM_WB_rd),
      .WD(WD),  // 来自 WB 阶段决定
      .RD1(RD1),
      .RD2(RD2),
      .reg_sel(reg_sel),
      .reg_data(reg_data)
  );

  wire [31:0] alu_B = (ID_EX_ALUSrc) ? ID_EX_Imm : ID_EX_RD2;
  alu U_alu (
      .A(ID_EX_RD1),
      .B(alu_B),
      .ALUOp(ID_EX_ALUOp),
      .C(aluout),
      .Zero(Zero),
      .PC(ID_EX_PC)
  );

  assign Addr_out = EX_MEM_ALUResult; // 传给外层的 sccomp
  assign Data_out = EX_MEM_RD2;     // 传给外层的 sccomp
  assign mem_w = EX_MEM_MemWrite;   // 传给外层的 sccomp

  always @* begin
    case (MEM_WB_WDSel)
      `WDSel_FromALU: WD = MEM_WB_ALUResult;
      `WDSel_FromMEM: WD = MEM_WB_MemData;
      `WDSel_FromPC:  WD = MEM_WB_PC + 4;
      default:        WD = 32'hffffffff;
    endcase
  end



endmodule
