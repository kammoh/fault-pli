module Sayeh (
  clk,
  ReadMem, WriteMem, ReadIO, WriteIO,
  Addressbus,
  ExternalReset, MemDataready, Databus_in, Databus_out
);

input clk;
output ReadMem;
output WriteMem;
output ReadIO;
output WriteIO;
input [15: 0] Databus_in;
output [15: 0] Databus_out;
output [15: 0] Addressbus;
input ExternalReset;
input MemDataready;

reg [49:0] temp;

//----------------------------------------------------------------------
wire[15:0] Instruction;
wire
  ResetPC, PCplusI, PCplus1, RplusI, Rplus0,
  Rs_on_AddressUnitRSide, Rd_on_AddressUnitRSide, EnablePC,
  B15to0, AandB, AorB, notB, shlB, shrB, AaddB, AsubB, AmulB, AcmpB,
  RFHwrite, RFLwrite, 
  WPreset, WPadd, IRload, SRload, 
  Address_on_Databus, ALU_on_Databus, IR_on_LOpndBus, IR_on_HOpndBus, RFright_on_OpndBus,
  Cset, Creset, Zset, Zreset, Shadow,
  Cflag, Zflag;  

  DataPath dp (
    clk, Addressbus, ResetPC, PCplusI, PCplus1, RplusI, Rplus0,
    Rs_on_AddressUnitRSide, Rd_on_AddressUnitRSide, EnablePC,
    B15to0, AandB, AorB, notB, shlB, shrB, AaddB, AsubB, AmulB, AcmpB,
    RFLwrite, RFHwrite,
    WPreset, WPadd, IRload, SRload, 
    Address_on_Databus, ALU_on_Databus, IR_on_LOpndBus, IR_on_HOpndBus, RFright_on_OpndBus,
    Cset, Creset, Zset, Zreset, Shadow,
    Instruction, Cflag, Zflag, Databus_in, Databus_out
  );

  controller ctrl (
    ExternalReset, clk,
    ResetPC, PCplusI, PCplus1, RplusI, Rplus0, 
    Rs_on_AddressUnitRSide, Rd_on_AddressUnitRSide, EnablePC, 
    B15to0, AandB, AorB, notB, shlB, shrB, AaddB, AsubB, AmulB, AcmpB,
    RFLwrite, RFHwrite,
    WPreset, WPadd,IRload, SRload, 
    Address_on_Databus, ALU_on_Databus, IR_on_LOpndBus, IR_on_HOpndBus, RFright_on_OpndBus,
    ReadMem, WriteMem,ReadIO, WriteIO, Cset, Creset, Zset, Zreset, Shadow, 
    Instruction, Cflag, Zflag, MemDataready
  );
    
endmodule 