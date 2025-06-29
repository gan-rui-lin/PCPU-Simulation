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

    input [4:0] reg_sel,  // register selection (for debug use)
    output [31:0] reg_data,  // selected register data (for debug use)
    output [2:0] DMType_out,
    output MemRead_out
);
  wire        MemWrite;
  wire        MemRead;
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
  assign B = (ALUSrc) ? immout : RD2;

  wire Stall;

  reg [31:0] ALU_A;  // 前递后真正输入 ALU 的信号
  reg [31:0] ALU_B;
  reg [31:0] ALU_RD2;

  // IF/ID
  // 考虑 beq 跳转成功(ID 阶段判断) flush 掉 IF 阶段的指令
  reg IF_ID_valid;
  reg IF_Flush;
  reg [31:0] IF_ID_PC, IF_ID_Inst;
  always @(posedge clk) begin
    if (reset) begin
      IF_ID_valid <= 0;
      // 被 flush 掉了!
    end else if (Stall) begin
      IF_ID_PC   <= IF_ID_PC;
      IF_ID_Inst <= IF_ID_Inst;
    end else if (IF_Flush) begin
      IF_ID_PC   <= 32'hffffffff;  // not used
      IF_ID_Inst <= `NOP;
    end else begin
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
  reg [31:0] ID_EX_PC, ID_EX_RD1, ID_EX_RD2, ID_EX_Imm, ID_EX_Inst;
  reg [4:0] ID_EX_rs1, ID_EX_rs2, ID_EX_rd;
  reg [4:0] ID_EX_ALUOp;
  reg [2:0] ID_EX_NPCOp;
  reg ID_EX_ALUSrc, ID_EX_RegWrite, ID_EX_MemWrite, ID_EX_MemRead;
  reg [1:0] ID_EX_WDSel;
  reg [2:0] ID_EX_DMType;
  always @(posedge clk) begin
    if (reset) begin
      ID_EX_valid <= 0;
      ID_EX_NPCOp <= `NPC_PLUS4;  // 初始化为默认值
      ID_EX_PC <= 0;
    end  // ID 阶段没准备好的 Stall





    else if (Stall) begin
      ID_EX_Inst <= `NOP;
      ID_EX_PC <= 32'hffffffff;
      // 清除控制信号
      ID_EX_NPCOp <= `NPC_PLUS4;  // 初始化为默认值
      ID_EX_MemRead <= 0;
      ID_EX_ALUOp <= 0;
      ID_EX_RegWrite <= 0;
      ID_EX_DMType <= 0;
      ID_EX_MemWrite <= 0;
    end else begin  // 否则保持原样
      ID_EX_Inst <= IF_ID_Inst;
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
      ID_EX_MemWrite <= MemWrite;
      ID_EX_NPCOp <= NPCOp;
      ID_EX_MemRead <= MemRead;
    end
  end



  // EX/MEM
  reg EX_MEM_valid;
  reg [31:0] EX_MEM_ALUResult, EX_MEM_RD2, EX_MEM_PC, EX_MEM_Inst;
  reg [4:0] EX_MEM_rd;
  reg EX_MEM_RegWrite, EX_MEM_MemWrite, EX_MEM_MemRead;
  reg [2:0] EX_MEM_NPCOp;
  reg [1:0] EX_MEM_WDSel;
  reg [2:0] EX_MEM_DMType;
  always @(posedge clk) begin
    if (reset) EX_MEM_valid <= 0;
    // EX 阶段没准备好的 Stall
    else if (0) begin
      EX_MEM_Inst <= `NOP;
      EX_MEM_PC   <= 32'hffffffff;
    end else begin
      EX_MEM_Inst <= ID_EX_Inst;
      EX_MEM_valid <= ID_EX_valid;
      EX_MEM_PC <= ID_EX_PC;  // 最终到 MEM_WB_PC
      EX_MEM_ALUResult <= aluout;
      EX_MEM_NPCOp <= NPCOp;
      EX_MEM_RD2 <= ALU_RD2;  // S-type 的前递!
      EX_MEM_rd <= ID_EX_rd;
      EX_MEM_RegWrite <= ID_EX_RegWrite;
      EX_MEM_MemWrite <= ID_EX_MemWrite;
      EX_MEM_WDSel <= ID_EX_WDSel;
      EX_MEM_DMType <= ID_EX_DMType;
      EX_MEM_MemRead <= ID_EX_MemRead;
    end
  end



  // MEM/WB
  reg MEM_WB_valid;
  reg [31:0] MEM_WB_MemData, MEM_WB_ALUResult, MEM_WB_PC, MEM_WB_RD2, MEM_WB_Inst;
  reg [4:0] MEM_WB_rd;
  reg MEM_WB_RegWrite, MEM_WB_MemWrite, MEM_WB_MemRead;
  reg [1:0] MEM_WB_WDSel;
  always @(posedge clk) begin
    if (reset) MEM_WB_valid <= 0;
    else begin
      MEM_WB_Inst <= EX_MEM_Inst;
      MEM_WB_PC <= EX_MEM_PC;
      MEM_WB_valid <= EX_MEM_valid;
      MEM_WB_MemData <= Data_in; // EX/MEM 阶段提供读信号, MEM/WB 等待上升沿接收数据
      MEM_WB_ALUResult <= EX_MEM_ALUResult;
      MEM_WB_rd <= EX_MEM_rd;
      MEM_WB_RD2 <= EX_MEM_RD2;
      MEM_WB_RegWrite <= EX_MEM_RegWrite;
      MEM_WB_WDSel <= EX_MEM_WDSel;
      MEM_WB_MemWrite <= EX_MEM_MemWrite;
      MEM_WB_MemRead <= EX_MEM_MemRead;
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
      .DMType(DMType),
      .MemRead(MemRead)
  );

  PC U_PC (
      .clk(clk),
      .rst(reset),
      .NPC(NPC),
      .PC(PC_out),
      .Stall(Stall)
  );

  reg [31:0] True_PC_for_next;
  reg [2:0] True_NPCOp;

  // 用 case 替代三目运算符，解决 xxx 问题
  // // True_PC_for_next 在 EX 阶段准备好, 同理 NPC; 在 MEM 阶段写入新的正确的 PC
  // 修改为 ID 阶段全判断
  wire Can_Branch;
  always @* begin
    case (NPCOp)
      `NPC_JALR, `NPC_JUMP: begin
        True_PC_for_next <= IF_ID_PC;
        True_NPCOp <= NPCOp;
      end
      `NPC_BRANCH: begin
        if (Can_Branch == 1) begin
          True_PC_for_next <= IF_ID_PC;
          True_NPCOp <= NPCOp;
        end else begin
          True_PC_for_next <= PC_out;
          True_NPCOp <= `NPC_PLUS4;
        end
      end
      default: begin
        True_PC_for_next <= PC_out;
        True_NPCOp <= `NPC_PLUS4;
      end
    endcase
  end

  reg  [31:0] RD1_For_Jalr;
  wire [31:0] jalr_next = RD1_For_Jalr + immout;


  always @* begin
    case (NPCOp)
      `NPC_JALR: IF_Flush = 1'b1;
      `NPC_JUMP: IF_Flush = 1'b1;
      `NPC_BRANCH: begin
        if (Can_Branch == 1) IF_Flush = 1'b1;
        else IF_Flush = 1'b0;
      end
      default:   IF_Flush = 1'b0;
    endcase
  end


  NPC U_NPC (
      .PC(True_PC_for_next),
      .NPCOp(True_NPCOp),
      .IMM(immout),
      .aluout(jalr_next),
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

  always @(*) begin
    if (ID_EX_ALUSrc) ALU_B = ID_EX_Imm;
    else ALU_B = ALU_RD2;
  end

  alu U_alu (
      .A(ALU_A),
      .B(ALU_B),  // 应该和立即数做加法
      .ALUOp(ID_EX_ALUOp),
      .C(aluout),
      .Zero(Zero),
      .PC(ID_EX_PC)
  );

  reg  [31:0] ALU_A_Btype;
  reg  [31:0] ALU_B_Btype;
  reg [31:0] ALU_RD2_Btype;

  always @(*) begin
    if (ALUSrc) ALU_B_Btype = immout;
    else ALU_B_Btype = ALU_RD2_Btype;
  end

  wire [31:0] not_used;
  alu U_alu_Btype (
      .A(ALU_A_Btype),
      .B(ALU_B_Btype),
      .ALUOp(ALUOp),
      .C(not_used),
      .Zero(Can_Branch),
      .PC(IF_ID_PC)
  );

  // 在 MEM 阶段传递地址、待写数据(下周期真正写) 给DM 模块, WB 阶段读出 Data_in 准备写回寄存器(下周期写);
  assign Addr_out = EX_MEM_ALUResult; // 传给外层的 sccomp
  assign Data_out = EX_MEM_RD2;     // 传给外层的 sccomp
  assign mem_w = EX_MEM_MemWrite;   // 传给外层的 sccomp
  assign DMType_out = EX_MEM_DMType;
  assign MemRead_out = EX_MEM_MemRead;

  always @* begin
    case (MEM_WB_WDSel)
      `WDSel_FromALU: WD = MEM_WB_ALUResult;
      `WDSel_FromMEM: WD = MEM_WB_MemData;
      `WDSel_FromPC:  WD = MEM_WB_PC + 4;
      default:        WD = 32'hffffffff;
    endcase
  end

  wire [3:0] ForwardA;
  wire [3:0] ForwardB;

  Forward_unit U_Forward_unit (
      .ID_EX_rs1(ID_EX_rs1),
      .ID_EX_rs2(ID_EX_rs2),
      .EX_MEM_rd(EX_MEM_rd),
      .MEM_WB_rd(MEM_WB_rd),
      .EX_MEM_RegWrite(EX_MEM_RegWrite),
      .MEM_WB_RegWrite(MEM_WB_RegWrite),
      .NPCOp(NPCOp),
      .rs1(rs1),
      .rs2(rs2),
      .ForwardA(ForwardA),
      .ForwardB(ForwardB),
      .EX_MEM_MemRead(EX_MEM_MemRead),
      .MEM_WB_MemRead(MEM_WB_MemRead)
  );

  Hazard_detection U_Hazard_Detection (
      .ID_EX_MemRead (ID_EX_MemRead),
      .EX_MEM_MemRead(EX_MEM_MemRead),
      .ID_EX_RegWrite(ID_EX_RegWrite),
      .rs1           (rs1),
      .rs2           (rs2),
      .ID_EX_rd      (ID_EX_rd),
      .EX_MEM_rd     (EX_MEM_rd),
      .Stall         (Stall),
      .NPCOp         (NPCOp)
  );


  // Forward = {ID_EX, ID_MEM, EX_MEM, MEM_WB}
  always @(*) begin
    case (ForwardA[1:0])
      2'b00: ALU_A <= ID_EX_RD1;
      // 这里的 MEM_EX 旁路, 只能是将即将要写回RF的值(WD)往EX送,其它均不准确
      2'b01: ALU_A <= WD;
      2'b10: ALU_A <= EX_MEM_ALUResult;
      default ALU_A <= ID_EX_RD1;
    endcase
    case (ForwardB[1:0])
      2'b00: ALU_RD2 <= ID_EX_RD2;
      2'b01: ALU_RD2 <= WD;
      2'b10: ALU_RD2 <= EX_MEM_ALUResult;
      default ALU_RD2 <= ID_EX_RD2;
    endcase
  end

  // 前递给 小ALU 做分支判断, 前递给 jalr 得到跳转地址
  always @(*) begin
    case (ForwardA[3:2])
      2'b00:   ALU_A_Btype = RD1;
      2'b01:   ALU_A_Btype = MEM_WB_MemData;
      2'b10:   ALU_A_Btype = EX_MEM_ALUResult;
      default: ALU_A_Btype = RD1;
    endcase

    case (ForwardB[3:2])
      2'b00:   ALU_RD2_Btype = RD2;
      2'b01:   ALU_RD2_Btype = MEM_WB_MemData;
      2'b10:   ALU_RD2_Btype = EX_MEM_ALUResult;
      default: ALU_RD2_Btype = RD2;
    endcase
  end

  // 只有 rs1
  always @(*) begin
    case (ForwardA[3:2])
      2'b00:   RD1_For_Jalr = RD1;
      2'b01:   RD1_For_Jalr = WD;
      2'b10:   RD1_For_Jalr = EX_MEM_ALUResult;
      default: RD1_For_Jalr = RD1;
    endcase
  end



endmodule
