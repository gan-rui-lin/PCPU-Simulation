`include "macro.v"
module sccomp (
    input clk,
    input rstn,
    input [15:0] sw_i,
    output [7:0] disp_an_o,
    output [7:0] disp_seg_o,
    input [4:0] reg_sel,
    output [31:0] reg_data
);



  /* ---------------- clock and buttons ---------------- */
  wire fast_disp = sw_i[15];
  wire pc_pause = sw_i[0];
  wire rf_pause = sw_i[1];
  wire alu_pause = sw_i[2];
  wire dm_pause = sw_i[3];
  wire [3:0] initial_addr_sel = sw_i[5:2];
  wire [4:0] dm_disp_addr = sw_i[8:4];
  wire clk_fast, clk_slow, clk_used, clk_disp;

  clk_divider #(
      .DIV_NUM(25)
  ) div24 (
      .clk(clk),
      .clk_out(clk_fast)
  );
  clk_divider #(
      .DIV_NUM(27)
  ) div27 (
      .clk(clk),
      .clk_out(clk_slow)
  );
  clk_divider #(
      .DIV_NUM(14)
  ) div12 (
      .clk(clk),
      .clk_out(clk_disp)
  );

  wire clk_addr = fast_disp ? clk_fast : clk_slow;
  assign clk_used = pc_pause ? 1'b0 : clk_addr;

  // for running tb file
  // assign clk_used = clk;

  wire rom_disp = sw_i[14], rf_disp = sw_i[13], alu_disp = sw_i[12], dm_disp = sw_i[11], imm_disp = sw_i[10], pc_disp = sw_i[9];

  /* ----------------- logic part ----------------- */
  wire [$clog2(`RF_SIZE)-1:0] rf_addr;
  //   wire [$clog2(`ALU_SIZE)-1:0] alu_addr;
  //   wire [$clog2(`DM_SIZE)-1:0] dm_addr_sel;
  reg [31:0] rf_disp_data;
  //   reg [31:0] alu_disp_data;
  //   reg [31:0] dm_disp_data;

  wire [31:0] instr;
  wire [31:0] PC;
  wire MemWrite;
  wire MemRead;
  wire [2:0] DMType;
  wire [31:0] dm_addr, dm_din, dm_dout;


  wire rst = ~rstn;

  // instantiation of single-cycle CPU   
  SCPU U_SCPU (
      .clk        (clk_used),      // input:  cpu clock
      .reset      (rst),           // input:  reset
      .inst_in    (instr),         // input:  instruction
      .Data_in    (dm_dout),       // input:  data to cpu  
      .mem_w      (MemWrite),      // output: memory write signal
      .PC_out     (PC),            // output: PC
      .Addr_out   (dm_addr),       // output: address from cpu to memory
      .Data_out   (dm_din),        // output: data from cpu to memory
      .reg_sel    (rf_addr),       // input:  register selection
      .reg_data   (rf_disp_data),  // output: register data
      .DMType_out (DMType),
      .MemRead_out(MemRead)
  );

  // instantiation of data memory  
  dm U_DM (
      .clk   (clk_used),      // input:  cpu clock
      .DMWr  (MemWrite),      // input:  ram write
      .DMRd  (MemRead),
      .DMType(DMType),
      .addr  (dm_addr[8:0]),  // input:  ram address
      .din   (dm_din),        // input:  data to ram
      .dout  (dm_dout)        // output: data from ram
  );

  // instantiation of intruction memory (used for simulation)
  im U_IM (
      .addr(PC[31:2]),  // input:  rom address
      .dout(instr)     // output: instruction
  );

  addr_controller #(
      .ADDR_SIZE(`RF_SIZE)
  ) u_rf_addr (
      .clk(clk_addr),
      .rstn(rstn),
      .addr_pause(rf_pause),
      .data_out(rf_addr)
  );

  // addr_controller #(
  //     .ADDR_SIZE(`ALU_SIZE)
  // ) u_alu_addr (
  //     .clk(clk_addr),
  //     .rstn(rstn),
  //     .addr_pause(alu_pause),
  //     .data_out(alu_addr)
  // );

  //   always @(posedge clk_addr) begin
  //     rf_disp_data <= u_rf.register_file[rf_addr];
  //   end

  //   always @(*) begin
  //     case (alu_addr)
  //       0: alu_disp_data = A;
  //       1: alu_disp_data = B;
  //       2: alu_disp_data = C;
  //       3: alu_disp_data = {{31{1'b0}}, zero};
  //       4: alu_disp_data = {32{1'b1}};
  //       default: alu_disp_data = 32'hff;
  //     endcase
  //   end

  // check one byte
  //   always @(posedge clk_addr) begin
  //     dm_disp_data <= u_dm.dmem[dm_disp_addr];
  //   end

  reg [31:0] disp_data;
  always @(*) begin
    case ({
      rom_disp, rf_disp, alu_disp, dm_disp, imm_disp, pc_disp
    })
      `ROM_DISP: begin
        disp_data = instr;
      end
      `RF_DISP: begin
        disp_data = rf_disp_data;
      end
      //   `ALU_DISP: begin
      //     disp_data = alu_disp_data;
      //   end
      //   `DM_DISP: begin
      //     disp_data = dm_disp_data;
      //   end
      //   `IMM_DISP: begin
      //     disp_data = imm_ext;
      //   end
      //   `PC_DISP: begin
      //     disp_data = pc;
      //   end
      default: disp_data = 32'hffffffff;
    endcase
  end

  disp_seg16x u_disp_seg16x (
      .clk(clk_disp),
      .rstn(rstn),
      .disp_data(disp_data),
      .an_o(disp_an_o),
      .seg_o(disp_seg_o)
  );



endmodule




/* ------- clk_divider  -------*/

module clk_divider #(
    parameter DIV_NUM = 24
) (
    input  clk,
    output clk_out
);
  reg [DIV_NUM:0] counter;
  always @(posedge clk) begin
    counter <= counter + 1;
  end
  assign clk_out = counter[DIV_NUM];
endmodule

/* ------- addr_controller  -------*/

module addr_controller #(
    parameter ADDR_SIZE = 20
) (
    input clk,
    input rstn,
    input addr_pause,
    output reg [$clog2(ADDR_SIZE)-1:0] data_out
);
  always @(posedge clk, negedge rstn) begin
    if (!rstn) begin
      data_out <= 0;
    end else if (addr_pause) begin
      data_out <= data_out;
    end else begin
      if (data_out == ADDR_SIZE - 1) begin
        data_out <= 0;
      end else begin
        data_out <= data_out + 1;
      end
    end
  end
endmodule


