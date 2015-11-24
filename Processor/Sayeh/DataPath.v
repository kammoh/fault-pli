// Data Path 
`timescale 1ns/100ps

module DataPath (
  clk, Addressbus, 
    ResetPC, PCplusI, PCplus1, RplusI, Rplus0,
    Rs_on_AddressUnitRSide, Rd_on_AddressUnitRSide, EnablePC,
    B15to0, AandB, AorB, notB, shlB, shrB, AaddB, AsubB, AmulB, AcmpB,
    RFLwrite, RFHwrite,
    WPreset, WPadd, IRload, SRload, 
    Address_on_Databus, ALU_on_Databus, IR_on_LOpndBus, IR_on_HOpndBus, RFright_on_OpndBus,
    Cset, Creset, Zset, Zreset, Shadow, 

    Instruction, Cout, Zout, Databus_in, Databus_out
);

input clk;
input [15:0] Databus_in;
output [15:0] Addressbus;
input ResetPC;
input PCplusI;
input PCplus1;
input RplusI;
input Rplus0;
input Rs_on_AddressUnitRSide;
input Rd_on_AddressUnitRSide;
input EnablePC;
input B15to0;
input AandB;
input AorB;
input notB;
input shlB;
input shrB;
input AaddB;
input AsubB;
input AmulB;
input AcmpB;
input RFLwrite;
input RFHwrite;
input WPreset;
input WPadd;
input IRload;
input SRload;
input Address_on_Databus;
input ALU_on_Databus;
input IR_on_LOpndBus;
input IR_on_HOpndBus;
input RFright_on_OpndBus;
input Cset;
input Creset;
input Zset;
input Zreset;
input Shadow;

output [15:0] Databus_out;
output [15:0] Instruction;
output Cout;
output Zout;

wire [15:0] Right, Left, OpndBus, IRout, Address, AddressUnitRSideBus, ALUout;
wire SRCin, SRZin, SRZout, SRCout;  
wire [5:0] WPout;
wire 
  ResetPC, PCplusI, PCplus1, RplusI, Rplus0,
  Rs_on_AddressUnitRSide, Rd_on_AddressUnitRSide, EnablePC,
  B15to0, AandB, AorB, notB, shlB, shrB, AaddB, AsubB, AmulB, AcmpB,
  RFHwrite,
  WPreset, WPadd, IRload, SRload, 
  Address_on_Databus, ALU_on_Databus, IR_on_LOpndBus, IR_on_HOpndBus, RFright_on_OpndBus,
  Cset, Creset, Zset, Zreset, Shadow;
wire [1:0] Raddr, Laddr;
wire [15:0]intermediateWire;

  AddressingUnit AU (
    AddressUnitRSideBus, IRout[7:0], Address, clk, ResetPC, PCplusI, PCplus1, RplusI, Rplus0, EnablePC
  );
  
  ArithmeticUnit AL (
    Left, OpndBus, B15to0, AandB, AorB, notB, shlB, shrB, AaddB, AsubB, AmulB, AcmpB,
    ALUout, SRCout, SRZin, SRCin
  );

  RegisterFile RF (
    intermediateWire, clk, Laddr, Raddr, WPout, RFLwrite, RFHwrite, Left, Right
  );

  InstructionRegister IR (intermediateWire, IRload, clk, IRout);

  StatusRegister SR (SRCin, SRZin, SRload, clk, Cset, Creset, Zset, Zreset, SRCout, SRZout);

  WindowPointer WP (IRout[5:0], clk, WPreset, WPadd, WPout);

  assign AddressUnitRSideBus = 
    (Rs_on_AddressUnitRSide) ? Right : (Rd_on_AddressUnitRSide) ? Left : 16'd 0;

  assign Addressbus = Address;
  
  assign intermediateWire = (Address_on_Databus) ? Address : (ALU_on_Databus) ? ALUout : Databus_in;
  
  assign Databus_out = (Address_on_Databus) ? Address : (ALU_on_Databus) ? ALUout : 16'd 0;
  
  assign OpndBus[7:0] = IR_on_LOpndBus == 1 ? IRout[7:0] :
						RFright_on_OpndBus == 1 ? Right[7:0] : 8'd 0;

  assign OpndBus[15:8] = IR_on_HOpndBus == 1 ? IRout[7:0] :
						RFright_on_OpndBus == 1 ? Right[15:8] : 8'd 0;
						
  assign Zout = SRZout;

  assign Cout = SRCout;

  assign Instruction = IRout[15:0];

  assign Laddr = (~Shadow) ? IRout[11:10] : IRout[3:2];

  assign Raddr = (~Shadow) ? IRout[09:08] : IRout[1:0];

endmodule
