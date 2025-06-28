module PC (
    clk,
    rst,
    NPC,
    PC,
    Stall
);

  input clk;
  input rst;
  input [31:0] NPC;
  input [1:0] Stall;
  output reg [31:0] PC;

  always @(posedge clk, posedge rst)
    if (rst) PC <= 32'h0000_0000;
    else if (Stall === 2'bxx || Stall == 0) PC <= NPC;
endmodule

