`timescale 1 ns /1 ns

module MemIP(
  addr,
  clk,
  din,
  dout,
  nd,
//	rfd,
  rdy,
  we);


input [9 : 0] addr;
input clk;
input [15 : 0] din;
output [15 : 0] dout;
input nd;
//output rfd;
output rdy;
input we;
reg [15:0] dout;
reg [15:0] SayehRAM [0:1023];
reg rdy;

integer memout;
initial begin : IOfiles
$readmemh ("SayehRAM.hex", SayehRAM);
dout = 16'bZ;
end

always @(negedge clk) begin : MemoryRead
if (nd) begin
#1 rdy = 1 ;
dout = SayehRAM [addr];
end 
else 
begin
#1 rdy = 0;
dout = 16'hZZZZ;
end
end

initial begin
    $writememh("OutputRAM.hex", SayehRAM);
end

always @(negedge clk) begin : MemoryWrite
#1 if (we) 
begin
    #1 SayehRAM [addr] = din;
    $writememh("OutputRAM.hex", SayehRAM);
rdy = 1; //added by ati
end
end

endmodule
