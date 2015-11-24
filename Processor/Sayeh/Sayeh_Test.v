`timescale 1 ns /1 ns

module SayehTest ();
reg clk, ExternalReset;


parameter num_faults = 5;

wire [15:0] Databus_in, Addressbus, Databus_out;
wire ReadMem, WriteMem, ReadIO, WriteIO, MemDataready;



always #20 clk = ~clk;

initial begin : RunCPU
clk = 0; ExternalReset = 0; 

#05 ExternalReset = 1; #81 ExternalReset = 0;
//#370000;
//$stop;
end



Sayeh U1 (clk, ReadMem, WriteMem, ReadIO, WriteIO,
Addressbus, ExternalReset, MemDataready, Databus_in, Databus_out);

MemIP memory(.addr(Addressbus[9:0]), .clk(clk), .din(Databus_out), //.rfd(),
			 .dout(Databus_in), .nd(ReadMem), .rdy(MemDataready), .we(WriteMem));

`define FAULT_DELAY 40
			 
initial begin
	#`FAULT_DELAY;
`ifdef SUBMODULE_FAULT
    $inject_hlf_sub(SayehTest.U1, `num_faults, `submodule_index);
`elsif MAIN_FAULT
    $inject_hlf(SayehTest.U1, `num_faults);
`endif
end
			 
endmodule
