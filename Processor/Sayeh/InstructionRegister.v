//Instruction Register

`timescale 1ns/100ps

module InstructionRegister (in, IRload, clk, out);
input [15:0] in;
input IRload;
input clk;
output [15:0] out;
reg [15:0] out;

  always @(posedge clk)
    if (IRload == 1) out = in;

endmodule
