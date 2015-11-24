// Window Pointer
`timescale 1ns/100ps

module WindowPointer (in, clk, WPreset, WPadd, out);
input [5:0] in;
input clk;
input WPreset;
input WPadd;
output [5:0] out;
reg [5:0] out;

  always @(posedge clk)
    if (WPreset == 1) out = 0;
    else if (WPadd == 1) begin
      out = out + in;
    end

endmodule
