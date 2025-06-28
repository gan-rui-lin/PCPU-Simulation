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
  input [8:0] addr;
  input [31:0] din;
  input [2:0] DMType;
  output reg [31:0] dout;

  reg [7:0] dmem[255:0];

  always @(posedge clk) begin
    if (DMWr) begin

      case (DMType)
        `dm_byte: dmem[addr] <= din[7:0];
        `dm_byte_unsigned: dmem[addr] <= din[7:0];
        `dm_halfword: begin
          dmem[addr]   <= din[7:0];
          dmem[addr+1] <= din[15:8];
        end
        `dm_halfword_unsigned: begin
          dmem[addr]   <= din[7:0];
          dmem[addr+1] <= din[15:8];
        end
        `dm_word: begin
          dmem[addr]   <= din[7:0];
          dmem[addr+1] <= din[15:8];
          dmem[addr+2] <= din[23:16];
          dmem[addr+3] <= din[31:24];
        end
      endcase
      $display("dmem[0x%8X] = 0x%8X,", addr, dmem[addr]);
      $display("dmem[0x%8X] = 0x%8X,", addr + 1, dmem[addr+1]);
      $display("dmem[0x%8X] = 0x%8X,", addr + 2, dmem[addr+2]);
      $display("dmem[0x%8X] = 0x%8X,", addr + 3, dmem[addr+3]);
    end
  end
  always @(*) begin
    case (DMType)
      `dm_byte: dout = {{24{dmem[addr][7]}}, dmem[addr][7:0]};
      `dm_byte_unsigned: dout = {24'b0, dmem[addr][7:0]};
      `dm_halfword: dout <= {{16{dmem[addr+1][7]}}, dmem[addr+1][7:0], dmem[addr][7:0]};
      `dm_halfword_unsigned: dout <= {16'b0, dmem[addr+1][7:0], dmem[addr][7:0]};
      `dm_word:
      dout <= {{dmem[addr+3][7:0]}, {dmem[addr+2][7:0]}, {dmem[addr+1][7:0]}, dmem[addr][7:0]};
      default: dout <= 32'b0;
    endcase
  end

endmodule
