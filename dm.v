`include "ctrl_encode_def.v"
// data memory
module dm (
    clk,
    DMWr,
    DMRd,
    addr,
    din,
    DMType,
    dout
);
  input clk;
  input DMWr;
  input DMRd;
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
  always @(DMRd or DMType or addr or dmem[addr] or dmem[addr+1] or dmem[addr+2] or dmem[addr+3]) begin

    if (DMRd) begin
      case (DMType)
        `dm_byte: dout <= {{24{dmem[addr][7]}}, dmem[addr]};
        `dm_byte_unsigned: dout <= {24'b0, dmem[addr]};
        `dm_halfword: dout <= {{16{dmem[addr+1][7]}}, dmem[addr+1], dmem[addr]};
        `dm_halfword_unsigned: dout <= {16'b0, dmem[addr+1], dmem[addr]};
        `dm_word: dout <= {dmem[addr+3], dmem[addr+2], dmem[addr+1], dmem[addr]};
        default: dout <= 32'hFFFFFFFF;
      endcase
    end else begin
      dout <= 32'h12345678;
    end
  end


endmodule
