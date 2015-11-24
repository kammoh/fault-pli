//Program Counter

`timescale 1ns/100ps

module ProgramCounter (in, enable, clk, out);
input [15:0] in;
input enable;
input clk;
output [15:0] out;
reg [15:0] out;

  always @(posedge clk)
    if (enable) out = in;

endmodule
