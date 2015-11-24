// Register File

`timescale 1ns/1ns

module RegisterFile (in, clk, Laddr, Raddr, Base, RFLwrite, RFHwrite, Lout, Rout);

input [15:0] in;
input clk;
input RFLwrite;
input RFHwrite;
input [1:0] Laddr;
input [1:0] Raddr;
input [5:0] Base;
output [15:0] Lout;
output [15:0] Rout;

reg [15:0] MemoryFile [0:63]; // a 64 bit reg file

wire [5:0] Laddress = Base + Laddr;
wire [5:0] Raddress = Base + Raddr;

assign Lout = MemoryFile [Laddress];
assign Rout = MemoryFile [Raddress];

reg [15:0] TempReg;

  always @(posedge clk) begin
      TempReg = MemoryFile [Laddress];
    if (RFLwrite) TempReg [7:0] = in [7:0];
    if (RFHwrite) TempReg [15:8] = in [15:8];
    MemoryFile [Laddress] = TempReg;
  end

endmodule
