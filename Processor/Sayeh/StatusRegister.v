//Status Register

`timescale 1ns/100ps

module StatusRegister (Cin, Zin, SRload, clk, Cset, Creset, Zset, Zreset, Cout, Zout);

input Cin;
input Zin;
input Cset;
input Creset;
input Zset;
input Zreset;
input SRload;
input clk;
output Cout;
output Zout;
reg Cout;
reg Zout;

  always @(posedge clk) 
    if (SRload == 1) begin
      Cout = Cin;
      Zout = Zin;
    end else if (Cset)
      Cout = 1;
    else if (Creset)
      Cout = 0;
    else if (Zset)
      Zout = 1;
    else if (Zreset)
      Zout = 0;

endmodule
