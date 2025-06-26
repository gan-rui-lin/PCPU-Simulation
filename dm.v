
`include "ctrl_encode_def.v"
// data memory
module dm (
    clk,
    DMWr,
    addr,
    din,
    DMType,
    dout
);
  input clk;
  input DMWr;
  input [2:0] DMType;
  input [8:2] addr;
  input [31:0] din;
  output reg [31:0] dout;

  reg [31:0] dmem[127:0];
  wire [31:0] word = dmem[addr];

  // 写操作（时钟上升沿）
  always @(posedge clk) begin
    if (DMWr) begin
      case (DMType)
        `dm_word: dmem[addr] <= din;

        `dm_halfword: begin
            dmem[addr] <= {din[15:0], word[15:0]};
        end

        `dm_byte: begin
          dmem[addr] <= {din[7:0], word[23:0]};
        end

        default: ;  // 不写
      endcase

      $display("dmem[0x%08X] = 0x%08X,", {addr, 2'b00}, din);
    end
  end

  always @(*) begin
    case (DMType)
      `dm_word: dout = word;

      `dm_halfword:
        dout = {{16{word[15]}}, word[15:0]};

      `dm_halfword_unsigned:
        dout = {16'b0, word[15:0]};

      `dm_byte:
        dout = {{24{word[7]}}, word[7:0]};

      `dm_byte_unsigned:
        dout = {24'b0, word[7:0]};

      default: dout = 32'b0;
    endcase
  end

endmodule
