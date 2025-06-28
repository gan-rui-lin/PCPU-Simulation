// `include "ctrl_encode_def.v"

//123
module ctrl (
    Op,
    Funct7,
    Funct3,
    Zero,
    RegWrite,
    MemWrite,
    EXTOp,
    ALUOp,
    NPCOp,
    ALUSrc,
    GPRSel,
    WDSel,
    DMType,
    MemRead
);

  input [6:0] Op;  // opcode
  input [6:0] Funct7;  // funct7
  input [2:0] Funct3;  // funct3
  input Zero;

  output RegWrite;  // control signal for register write
  output MemWrite;  // control signal for memory write
  output [5:0] EXTOp;  // control signal to signed extension
  output [4:0] ALUOp;  // ALU opertion
  output [2:0] NPCOp;  // next pc operation
  output ALUSrc;  // ALU source for A
  output [2:0] DMType;
  output [1:0] GPRSel;  // general purpose register selection
  output [1:0] WDSel;  // (register) write data selection
  output MemRead;

  wire is_rtype = (Op == 7'b0110011);
  wire is_itype_l = (Op == 7'b0000011);  // load
  wire is_itype_r = (Op == 7'b0010011);  // r,r,r
  wire is_stype = (Op == 7'b0100011);
  wire is_sbtype = (Op == 7'b1100011);
  wire is_jal = (Op == 7'b1101111);
  wire is_jalr = (Op == 7'b1100111);
  wire is_lui = (Op == 7'b0110111);
  wire is_auipc = (Op == 7'b0010111);

  // R type 算术指令
  wire is_add = is_rtype & (Funct3 == 3'b000) & (Funct7 == 7'b0000000);
  wire is_sub = is_rtype & (Funct3 == 3'b000) & (Funct7 == 7'b0100000);
  wire is_or = is_rtype & (Funct3 == 3'b110) & (Funct7 == 7'b0000000);
  wire is_and = is_rtype & (Funct3 == 3'b111) & (Funct7 == 7'b0000000);
  wire is_xor = is_rtype & (Funct3 == 3'b100) & (Funct7 == 7'b0000000);
  wire is_sll = is_rtype & (Funct3 == 3'b001) & (Funct7 == 7'b0000000);
  wire is_slt = is_rtype & (Funct3 == 3'b010) & (Funct7 == 7'b0000000);
  wire is_sltu = is_rtype & (Funct3 == 3'b011) & (Funct7 == 7'b0000000);
  wire is_sra = is_rtype & (Funct3 == 3'b101) & (Funct7 == 7'b0100000);
  wire is_srl = is_rtype & (Funct3 == 3'b101) & (Funct7 == 7'b0000000);

  // I type Load
  wire is_lw = is_itype_l & (Funct3 == 3'b010);
  wire is_lb = is_itype_l & (Funct3 == 3'b000);
  wire is_lh = is_itype_l & (Funct3 == 3'b001);
  wire is_lbu = is_itype_l & (Funct3 == 3'b100);
  wire is_lhu = is_itype_l & (Funct3 == 3'b101);

  // I type 算术指令
  wire is_addi = is_itype_r & (Funct3 == 3'b000);
  wire is_ori = is_itype_r & (Funct3 == 3'b110);
  wire is_andi = is_itype_r & (Funct3 == 3'b111);
  wire is_xori = is_itype_r & (Funct3 == 3'b100);
  wire is_slli = is_itype_r & (Funct3 == 3'b001) & (Funct7 == 7'b0000000);
  wire is_slti = is_itype_r & (Funct3 == 3'b010);
  wire is_sltiu = is_itype_r & (Funct3 == 3'b011);
  wire is_srai = is_itype_r & (Funct3 == 3'b101) & (Funct7 == 7'b0100000);
  wire is_srli = is_itype_r & (Funct3 == 3'b101) & (Funct7 == 7'b0000000);

  // S type
  wire is_sw = is_stype & (Funct3 == 3'b010);
  wire is_sb = is_stype & (Funct3 == 3'b000);
  wire is_sh = is_stype & (Funct3 == 3'b001);

  // B type
  wire is_beq = is_sbtype & (Funct3 == 3'b000);
  wire is_blt = is_sbtype & (Funct3 == 3'b100);
  wire is_bltu = is_sbtype & (Funct3 == 3'b110);
  wire is_bne = is_sbtype & (Funct3 == 3'b001);
  wire is_bge = is_sbtype & (Funct3 == 3'b101);
  wire is_bgeu = is_sbtype & (Funct3 == 3'b111);

  // RegWrite, MemWrite, ALUSrc
  assign RegWrite = is_rtype | is_itype_r | is_jalr | is_jal | is_lui | is_auipc | is_itype_l;
  assign MemWrite = is_stype;

  // 为 1 选择 imm
  assign ALUSrc = is_itype_r | is_stype | is_jal | is_jalr | is_itype_l | is_lui | is_auipc;

  // EXTOp: 5 种解码模式
  // EXT_CTRL_ITYPE_SHAMT 6'b100000
  // EXT_CTRL_ITYPE	      6'b010000
  // EXT_CTRL_STYPE	      6'b001000
  // EXT_CTRL_BTYPE	      6'b000100
  // EXT_CTRL_UTYPE	      6'b000010
  // EXT_CTRL_JTYPE	      6'b000001
  assign EXTOp[5] = is_slli | is_srli | is_srai;
  assign EXTOp[4] = is_itype_l | is_addi | is_ori | is_andi | is_xori | is_jalr | is_slti | is_sltiu;
  assign EXTOp[3] = is_stype;
  assign EXTOp[2] = is_sbtype && Zero;
  assign EXTOp[1] = is_lui | is_auipc;
  assign EXTOp[0] = is_jal;

  // WDSel
  // WDSel_FromALU 2'b00
  // WDSel_FromMEM 2'b01
  // WDSel_FromPC  2'b10 
  assign WDSel[0] = is_itype_l;
  assign WDSel[1] = is_jal | is_jalr;

  // NPCOp: Next PC
  // NPC_PLUS4   3'b000
  // NPC_BRANCH  3'b001
  // NPC_JUMP    3'b010
  // NPC_JALR	3'b100
  assign NPCOp[0] = is_sbtype;
  assign NPCOp[1] = is_jal;
  assign NPCOp[2] = is_jalr;

  // ALUOp 
  // ALUOp_nop 5'b00000
  // ALUOp_lui 5'b00001
  // ALUOp_auipc 5'b00010
  // ALUOp_add 5'b00011
  // ALUOp_sub 5'b00100
  // ALUOp_bne 5'b00101
  // ALUOp_blt 5'b00110
  // ALUOp_bge 5'b00111
  // ALUOp_bltu 5'b01000
  // ALUOp_bgeu 5'b01001
  // ALUOp_slt 5'b01010
  // ALUOp_sltu 5'b01011
  // ALUOp_xor 5'b01100
  // ALUOp_or 5'b01101
  // ALUOp_and 5'b01110
  // ALUOp_sll 5'b01111
  // ALUOp_srl 5'b10000
  // ALUOp_sra 5'b10001
  assign ALUOp[0] = is_itype_l | is_stype | is_addi | is_ori | is_add | is_or | is_lui | is_slli | is_sll | is_sltu | is_sltiu | is_jalr | is_bne | is_bge | is_bgeu | is_sra | is_srai;
  assign ALUOp[1] = is_jalr | is_itype_l | is_stype | is_add | is_addi | is_and | is_andi | is_auipc | is_slli | is_sll | is_slt | is_sltu | is_slti | is_sltiu | is_blt | is_bge;
  assign ALUOp[2] = is_andi | is_and | is_ori | is_or | is_sub | is_xori | is_xor | is_slli | is_sll | is_blt | is_bne | is_bge | is_beq;
  assign ALUOp[3] = is_andi | is_and | is_ori | is_or | is_xori | is_xor | is_slli | is_sll | is_slt | is_sltu | is_slti | is_sltiu | is_bltu | is_bgeu;
  assign ALUOp[4] = is_sra | is_srl | is_srai | is_srli;

  // DMType
  assign DMType[0] = is_lh | is_sh | is_sb | is_lb;
  assign DMType[1] = is_lhu | is_sb | is_lb;
  assign DMType[2] = is_lbu;

  assign MemRead = is_itype_l;

endmodule