// SAYEH Controller

`timescale 1ns/100ps

module controller (
  ExternalReset, clk,
    ResetPC, PCplusI, PCplus1, RplusI, Rplus0,
    Rs_on_AddressUnitRSide, Rd_on_AddressUnitRSide, EnablePC, 
    B15to0, AandB, AorB, notB, shlB, shrB, AaddB, AsubB, AmulB, AcmpB,
    RFLwrite, RFHwrite,
    WPreset, WPadd, IRload, SRload, 
    Address_on_Databus, ALU_on_Databus, IR_on_LOpndBus, IR_on_HOpndBus, RFright_on_OpndBus,
    ReadMem, WriteMem, ReadIO, WriteIO, Cset, Creset, Zset, Zreset, Shadow,
  Instruction,
  Cflag, Zflag, memDataReady
);

input ExternalReset;
input clk;
input[15:0] Instruction;
input Cflag;
input Zflag;
input memDataReady;

output ResetPC;
output PCplusI;
output PCplus1;
output RplusI;
output Rplus0;
output Rs_on_AddressUnitRSide;
output Rd_on_AddressUnitRSide;
output EnablePC;
output B15to0;
output AandB;
output AorB;
output notB;
output shlB;
output shrB;
output AaddB;
output AsubB;
output AmulB;
output AcmpB;
output RFLwrite;
output RFHwrite;
output WPreset;
output WPadd;
output IRload;
output SRload;
output Address_on_Databus;
output ALU_on_Databus;
output IR_on_LOpndBus;
output IR_on_HOpndBus;
output RFright_on_OpndBus;
output ReadMem;
output WriteMem;
output ReadIO;
output WriteIO;
output Cset;
output Creset;
output Zset;
output Zreset;
output Shadow;

reg ResetPC;
reg PCplusI;
reg PCplus1;
reg RplusI;
reg Rplus0;
reg Rs_on_AddressUnitRSide;
reg Rd_on_AddressUnitRSide;
reg EnablePC;
reg B15to0;
reg AandB;
reg AorB;
reg notB;
reg shlB;
reg shrB;
reg AaddB;
reg AsubB;
reg AmulB;
reg AcmpB;
reg RFLwrite;
reg RFHwrite;
reg WPreset;
reg WPadd;
reg IRload;
reg SRload;
reg Address_on_Databus;
reg ALU_on_Databus;
reg IR_on_LOpndBus;
reg IR_on_HOpndBus;
reg RFright_on_OpndBus;
reg ReadMem;
reg WriteMem;
reg ReadIO;
reg WriteIO;
reg Cset;
reg Creset;
reg Zset;
reg Zreset;
reg Shadow;
    
reg[3:0] Pstate, Nstate;
reg Regd_MemDataReady;

wire ShadowEn = ~(Instruction[7:0] == 8'b00001111);

//--------------------------------------------------------------------


  always @ (Instruction or Pstate or ExternalReset or Cflag or Zflag or Regd_MemDataReady)
  begin    
    ResetPC 			   = 1'b0;
    PCplusI 			   = 1'b0;
    PCplus1 			   = 1'b0;
    RplusI 				   = 1'b0;
    Rplus0  			   = 1'b0;
    EnablePC 			   = 1'b0;
    B15to0 				   = 1'b0;
    AandB 				   = 1'b0;
    AorB 				   = 1'b0;
    notB 				   = 1'b0;
    shrB 				   = 1'b0;
    shlB 				   = 1'b0;
    AaddB  				   = 1'b0;
    AsubB 				   = 1'b0;
    AmulB  				   = 1'b0;
    AcmpB  				   = 1'b0;
    RFLwrite			   = 1'b0;
    RFHwrite 			   = 1'b0;
    WPreset				   = 1'b0;
    WPadd				   = 1'b0;
    IRload 				   = 1'b0;
    SRload  			   = 1'b0;
    Address_on_Databus 	   = 1'b0;
    ALU_on_Databus 		   = 1'b0;
    IR_on_LOpndBus 		   = 1'b0;
    IR_on_HOpndBus		   = 1'b0;
    RFright_on_OpndBus 	   = 1'b0;
    ReadMem 			   = 1'b0;
    WriteMem 			   = 1'b0;
    ReadIO 				   = 1'b0;
    WriteIO 			   = 1'b0;
    Shadow				   = 1'b0;
    Cset				   = 1'b0;
    Creset				   = 1'b0;
    Zset				   = 1'b0;
    Zreset				   = 1'b0;
    Rs_on_AddressUnitRSide = 1'b0;
    Rd_on_AddressUnitRSide = 1'b0;

    case (Pstate)
    4'b0000 : // 0000
      if(ExternalReset == 1'b1) begin
        WPreset = 1'b1;
        ResetPC = 1'b1;
        EnablePC=1'b1;
        Creset = 1'b1;
        Zreset = 1'b1;
        Nstate = 4'b0000;
      end
      else
        Nstate = 4'b0010;

    4'b0001 : // 0001
      if(ExternalReset == 1'b1)
        Nstate = 4'b0010;
      else
        Nstate = 4'b0001;

    4'b0010 : // 0010
      if(ExternalReset == 1'b1)
        Nstate = 4'b0000;
      else begin
        ReadMem = 1'b1;
        Nstate = 4'b0011;
      end 

    4'b0011 : // 0011
      if(ExternalReset == 1'b1)
        Nstate = 4'b0000;
      else begin
        if (Regd_MemDataReady == 1'b0) begin
          ReadMem = 1'b1;
          Nstate = 4'b0011;
        end
        else begin   
          ReadMem = 1'b1;
          IRload = 1'b1;   
          Nstate = 4'b0100;
        end
      end

    4'b0100 : // 0100
      if(ExternalReset == 1'b1)
        Nstate = 4'b0000;
      else begin
        case (Instruction[15:12])
        4'b0000 :
          case (Instruction[11:8]) 
          4'b0000 :
            if (ShadowEn==1'b1)  
              Nstate = 4'b0101;
            else begin
              PCplus1 = 1'b1;
              EnablePC=1'b1;
              Nstate = 4'b0010;
            end

          4'b0001 :
            Nstate = 4'b0001;

          4'b0010 : begin
            Zset = 1'b1;
            if (ShadowEn==1'b1)  
              Nstate = 4'b0101;
            else begin
              PCplus1 = 1'b1;
              EnablePC=1'b1;
              Nstate = 4'b0010; 
            end
          end

          4'b0011 : begin
            Zreset = 1'b1;
            if (ShadowEn==1'b1)  
              Nstate = 4'b0101;
            else begin
              PCplus1 = 1'b1;
              EnablePC=1'b1;
              Nstate = 4'b0010; 
            end
          end

          4'b0100 : begin
            Cset = 1'b1;
            if (ShadowEn==1'b1)  
              Nstate = 4'b0101;
            else begin
              PCplus1 = 1'b1;
              EnablePC=1'b1;
              Nstate = 4'b0010; 
            end
          end

          4'b0101 : begin
            Creset = 1'b1;
            if (ShadowEn==1'b1)  
              Nstate = 4'b0101;
            else begin
              PCplus1 = 1'b1;
              EnablePC=1'b1;
              Nstate = 4'b0010; 
            end
          end

          4'b0110 : begin
            WPreset = 1'b1;
            if (ShadowEn==1'b1)  
              Nstate = 4'b0101;
            else begin
              PCplus1 = 1'b1;
              EnablePC=1'b1;
              Nstate = 4'b0010; 
            end
          end

          4'b0111 : begin
            PCplusI = 1'b1;
            EnablePC=1'b1;
            Nstate = 4'b0010;
          end

          4'b1000 : begin
            if(Zflag == 1'b1) begin
              PCplusI = 1'b1;
              EnablePC=1'b1;
            end
            else begin
              PCplus1 = 1'b1;
              EnablePC=1'b1;
            end
            Nstate = 4'b0010;
          end

          4'b1001 : begin
            if(Cflag == 1'b1) begin 
              PCplusI = 1'b1;
              EnablePC=1'b1;
            end
            else begin
              PCplus1 = 1'b1;
              EnablePC=1'b1;
            end  
            Nstate = 4'b0010;
          end

          4'b1010 : begin
            PCplus1 = 1'b1;
            EnablePC = 1'b1;
            WPadd = 1'b1;
            Nstate = 4'b0010;
          end

          default: begin
            PCplus1 = 1'b1;
            EnablePC = 1'b1;
            Nstate = 4'b0010;
          end
          endcase

        4'b0001 : begin
          RFright_on_OpndBus = 1'b1;
          B15to0 = 1'b1;
          ALU_on_Databus = 1'b1;
          RFLwrite = 1'b1;
          RFHwrite = 1'b1;
          SRload = 1'b1;
          if (ShadowEn==1'b1)  
            Nstate = 4'b0101;
          else begin
            PCplus1 = 1'b1;
            EnablePC=1'b1;
            Nstate = 4'b0010; 
          end
        end

        4'b0010 : begin
          Rplus0 = 1'b1;
          Rs_on_AddressUnitRSide = 1'b1;
          ReadMem = 1'b1;
            RFLwrite = 1'b1;
            RFHwrite = 1'b1;
          Nstate = 4'b0110;
        end

        4'b0011 : begin
          Rplus0 = 1'b1;
          Rd_on_AddressUnitRSide = 1'b1;
          RFright_on_OpndBus = 1'b1;
          B15to0 = 1'b1;
          ALU_on_Databus = 1'b1;
          WriteMem = 1'b1;
            Nstate = 4'b1001;
//					if (ShadowEn==1'b1)  
//						Nstate = 4'b0101;
//					else
//						Nstate = 4'b1000; 
        end

        4'b0100 : begin
          Rplus0 = 1'b1;
          Rs_on_AddressUnitRSide = 1'b1;
          ReadIO = 1'b1;
          RFLwrite = 1'b1;
          RFHwrite = 1'b1;
          SRload = 1'b1;
          if (ShadowEn==1'b1)  
            Nstate = 4'b0101;
          else
            Nstate = 4'b1000; 
        end

        4'b0101 : begin
          Rplus0 = 1'b1;
          Rd_on_AddressUnitRSide = 1'b1;
          B15to0 = 1'b1;
          ALU_on_Databus = 1'b1;
          WriteIO = 1'b1;
          if (ShadowEn==1'b1)  
            Nstate = 4'b0101;
          else
            Nstate = 4'b1000; 
        end

        4'b0110 : begin
          RFright_on_OpndBus = 1'b1;
          AandB = 1'b1;
          ALU_on_Databus = 1'b1;
          RFLwrite = 1'b1;
          RFHwrite = 1'b1;
          SRload = 1'b1;
          if (ShadowEn==1'b1)  
            Nstate = 4'b0101;
          else begin
            PCplus1 = 1'b1;
            EnablePC=1'b1;
            Nstate = 4'b0010; 
          end
        end

        4'b0111 : begin
          RFright_on_OpndBus = 1'b1;
          AorB = 1'b1;
          ALU_on_Databus = 1'b1;
          RFLwrite = 1'b1;
          RFHwrite = 1'b1;
          SRload = 1'b1;
          if (ShadowEn==1'b1)  
            Nstate = 4'b0101;
          else begin
            PCplus1 = 1'b1;
            EnablePC=1'b1;
            Nstate = 4'b0010; 
          end
        end

        4'b1000 : begin
          RFright_on_OpndBus = 1'b1;
          notB = 1'b1;
          ALU_on_Databus = 1'b1;
          RFLwrite = 1'b1;
          RFHwrite = 1'b1;
          SRload = 1'b1;
          if (ShadowEn==1'b1)
            Nstate = 4'b0101;
          else begin
            PCplus1 = 1'b1;
            EnablePC=1'b1;
            Nstate = 4'b0010; 
          end
        end

        4'b1001 : begin
          RFright_on_OpndBus = 1'b1;
          shlB = 1'b1;
          ALU_on_Databus = 1'b1;
          RFLwrite = 1'b1;
          RFHwrite = 1'b1;
          SRload = 1'b1;
          if (ShadowEn==1'b1)  
            Nstate = 4'b0101;
          else begin
            PCplus1 = 1'b1;
            EnablePC=1'b1;
            Nstate = 4'b0010; 
          end
        end

        4'b1010 : begin
          RFright_on_OpndBus = 1'b1;
          shrB = 1'b1;
          ALU_on_Databus = 1'b1;
          RFLwrite = 1'b1;
          RFHwrite = 1'b1;
          SRload = 1'b1;
          if (ShadowEn==1'b1)  
            Nstate = 4'b0101;
          else begin
            PCplus1 = 1'b1;
            EnablePC=1'b1;
            Nstate = 4'b0010; 
          end
        end

        4'b1011 : begin
          RFright_on_OpndBus = 1'b1;
          AaddB = 1'b1;
          ALU_on_Databus = 1'b1;
          RFLwrite = 1'b1;
          RFHwrite = 1'b1;
          SRload = 1'b1;
          if (ShadowEn==1'b1)  
            Nstate = 4'b0101;
          else begin
            PCplus1 = 1'b1;
            EnablePC=1'b1;
            Nstate = 4'b0010; 
          end
        end

        4'b1100 : begin
          RFright_on_OpndBus = 1'b1;
          AsubB = 1'b1;
          ALU_on_Databus = 1'b1;
          RFLwrite = 1'b1;
          RFHwrite = 1'b1;
          SRload = 1'b1;
          if (ShadowEn==1'b1)  
            Nstate = 4'b0101;
          else begin
            PCplus1 = 1'b1;
            EnablePC=1'b1;
            Nstate = 4'b0010; 
          end
        end

        4'b1101 : begin
          RFright_on_OpndBus = 1'b1;
          AmulB = 1'b1;
          ALU_on_Databus = 1'b1;
          RFLwrite = 1'b1;
          RFHwrite = 1'b1;
          SRload = 1'b1;
          if (ShadowEn==1'b1)  
            Nstate = 4'b0101;
          else begin
            PCplus1 = 1'b1;
            EnablePC=1'b1;
            Nstate = 4'b0010; 
          end
        end

        4'b1110 : begin
          RFright_on_OpndBus = 1'b1;
          AcmpB = 1'b1;
          SRload = 1'b1;
          if (ShadowEn==1'b1)  
            Nstate = 4'b0101;
          else begin
            PCplus1 = 1'b1;
            EnablePC=1'b1;
            Nstate = 4'b0010; 
          end
        end

        4'b1111 :
          case (Instruction[9: 8]) 
          2'b00 : begin
            IR_on_LOpndBus = 1'b1;
            ALU_on_Databus = 1'b1;
            B15to0 = 1'b1;
            RFLwrite = 1'b1;
            SRload = 1'b1;
            PCplus1 = 1'b1;
            EnablePC=1'b1;
            Nstate = 4'b0010;
          end

          2'b01 : begin
            IR_on_HOpndBus = 1'b1;
            ALU_on_Databus = 1'b1;
            B15to0 = 1'b1;
            RFHwrite = 1'b1;
            SRload = 1'b1;
            PCplus1 = 1'b1;
            EnablePC=1'b1;
            Nstate = 4'b0010;
          end

          2'b10 : begin
            PCplusI = 1'b1;
            Address_on_Databus = 1'b1;
            RFLwrite = 1'b1;
            RFHwrite = 1'b1;
           // EnablePC=1'b1; //commented by ati
		   Nstate = 4'b1000; //added by ati
          //  Nstate = 4'b0010; //commented by ati
          end

          2'b11 : begin
            Rd_on_AddressUnitRSide = 1'b1;
            RplusI = 1'b1;
            EnablePC=1'b1;
            Nstate = 4'b0010; 
          end

          default:
            Nstate = 4'b0010;
          endcase

        default :
          Nstate = 4'b0010;
        endcase
      end 

    4'b0110 : 
      if(ExternalReset == 1'b1)
        Nstate = 4'b0000;
      else begin
        if (Regd_MemDataReady == 1'b0) begin
          Rplus0 = 1'b1;
          Rs_on_AddressUnitRSide = 1'b1;
          ReadMem = 1'b1;
           RFLwrite = 1'b1;
            RFHwrite = 1'b1;
            Nstate = 4'b0110;
        end
        else begin  
          if (ShadowEn==1'b1)  
            Nstate = 4'b0101;
          else begin
            PCplus1 = 1'b1;
            EnablePC=1'b1;
            Nstate = 4'b0010;
          end
        end
      end
  
    4'b1001 :
     if (ExternalReset ==1'b1) 
            Nstate = 4'b0000;
     else begin
       if (Regd_MemDataReady == 1'b0) begin
             Rplus0 = 1'b1;
             Rd_on_AddressUnitRSide = 1'b1;
             RFright_on_OpndBus = 1'b1;
             B15to0 = 1'b1;
             ALU_on_Databus = 1'b1;
             WriteMem = 1'b1;
             Nstate = 4'b1001;
        end
        else begin  
         if (ShadowEn == 1'b1)
              Nstate = 4'b0101;
         else
            Nstate = 4'b1000; 
        end
    end

    4'b0101 : begin // 0101
      Shadow=1'b1;
      if(ExternalReset == 1'b1)
        Nstate = 4'b0000;
      else begin
        case (Instruction[7:4])
        4'b0000 :
          case (Instruction[3: 0]) 
          4'b0001 :
            Nstate = 4'b0001;

          4'b0010 : begin
            Zset = 1'b1;
            PCplus1 = 1'b1;
            EnablePC = 1'b1;
            Nstate = 4'b0010;
          end

          4'b0011 : begin
            Zreset = 1'b1;
            PCplus1 = 1'b1;
            EnablePC = 1'b1;
            Nstate = 4'b0010; 
          end

          4'b0100 : begin
            Cset = 1'b1;
            PCplus1 = 1'b1;
            EnablePC = 1'b1;
            Nstate = 4'b0010; 
          end

          4'b0101 : begin
            Creset = 1'b1;
            PCplus1 = 1'b1;
            EnablePC = 1'b1;
            Nstate = 4'b0010; 
          end

          4'b0110 : begin
            WPreset = 1'b1;
            PCplus1 = 1'b1;
            EnablePC = 1'b1;
            Nstate = 4'b0010; 
          end

          default : begin
            PCplus1 = 1'b1;
            EnablePC = 1'b1;
            Nstate = 4'b0010;
          end
          endcase
        4'b0001 : begin
          RFright_on_OpndBus = 1'b1;
          B15to0 = 1'b1;
          ALU_on_Databus = 1'b1;
          RFLwrite = 1'b1;
          RFHwrite = 1'b1;
          SRload = 1'b1;
          PCplus1 = 1'b1;
          EnablePC = 1'b1;
          Nstate = 4'b0010; 
        end

        4'b0010 : begin
          Rplus0 = 1'b1;
          Rs_on_AddressUnitRSide = 1'b1;
          ReadMem = 1'b1;
           RFLwrite = 1'b1;
            RFHwrite = 1'b1;
          Nstate = 4'b0111;
        end

        4'b0011 : begin
          Rplus0 = 1'b1;
          Rd_on_AddressUnitRSide = 1'b1;
          RFright_on_OpndBus = 1'b1;
          B15to0 = 1'b1;
          ALU_on_Databus = 1'b1;
          WriteMem = 1'b1;
          Nstate = 4'b1010; 
        end

        4'b0100 : begin
          Rplus0 = 1'b1;
          Rs_on_AddressUnitRSide = 1'b1;
          ReadIO = 1'b1;
          RFLwrite = 1'b1;
          RFHwrite = 1'b1;
          SRload = 1'b1;
          Nstate = 4'b1000; 
        end

        4'b0101 : begin
          Rplus0 = 1'b1;
          Rd_on_AddressUnitRSide = 1'b1;
          B15to0 = 1'b1;
          ALU_on_Databus = 1'b1;
          WriteIO = 1'b1;
          Nstate = 4'b1000; 
        end

        4'b0110 : begin
          RFright_on_OpndBus = 1'b1;
          AandB = 1'b1;
          ALU_on_Databus = 1'b1;
          RFLwrite = 1'b1;
          RFHwrite = 1'b1;
          SRload = 1'b1;
          PCplus1 = 1'b1;
          EnablePC = 1'b1;
          Nstate = 4'b0010; 
        end

        4'b0111 : begin
          RFright_on_OpndBus = 1'b1;
          AorB = 1'b1;
          ALU_on_Databus = 1'b1;
          RFLwrite = 1'b1;
          RFHwrite = 1'b1;
          SRload = 1'b1;
          PCplus1 = 1'b1;
          EnablePC = 1'b1;
          Nstate = 4'b0010; 
        end

        4'b1000 : begin
          RFright_on_OpndBus = 1'b1;
          notB = 1'b1;
          ALU_on_Databus = 1'b1;
          RFLwrite = 1'b1;
          RFHwrite = 1'b1;
          SRload = 1'b1;
          PCplus1 = 1'b1;
          EnablePC = 1'b1;
          Nstate = 4'b0010; 
        end

        4'b1001 : begin
          RFright_on_OpndBus = 1'b1;
          shlB = 1'b1;
          ALU_on_Databus = 1'b1;
          RFLwrite = 1'b1;
          RFHwrite = 1'b1;
          SRload = 1'b1;
          PCplus1 = 1'b1;
          EnablePC = 1'b1;
          Nstate = 4'b0010; 
        end

        4'b1010 : begin
          RFright_on_OpndBus = 1'b1;
          shrB = 1'b1;
          ALU_on_Databus = 1'b1;
          RFLwrite = 1'b1;
          RFHwrite = 1'b1;
          SRload = 1'b1;
          PCplus1 = 1'b1;
          EnablePC = 1'b1;
          Nstate = 4'b0010; 
        end

        4'b1011 : begin
          RFright_on_OpndBus = 1'b1;
          AaddB = 1'b1;
          ALU_on_Databus = 1'b1;
          RFLwrite = 1'b1;
          RFHwrite = 1'b1;
          SRload = 1'b1;
          PCplus1 = 1'b1;
          EnablePC = 1'b1;
          Nstate = 4'b0010; 
        end

        4'b1100 : begin
          RFright_on_OpndBus = 1'b1;
          AsubB = 1'b1;
          ALU_on_Databus = 1'b1;
          RFLwrite = 1'b1;
          RFHwrite = 1'b1;
          SRload = 1'b1;
          PCplus1 = 1'b1;
          EnablePC = 1'b1;
          Nstate = 4'b0010; 
        end

        4'b1101 : begin
          RFright_on_OpndBus = 1'b1;
          AmulB = 1'b1;
          ALU_on_Databus = 1'b1;
          RFLwrite = 1'b1;
          RFHwrite = 1'b1;
          SRload = 1'b1;
          PCplus1 = 1'b1;
          EnablePC = 1'b1;
          Nstate = 4'b0010; 
        end

        4'b1110 : begin
          RFright_on_OpndBus = 1'b1;
          AcmpB = 1'b1;
          SRload = 1'b1;
          PCplus1 = 1'b1;
          EnablePC = 1'b1;
          Nstate = 4'b0010; 
        end

        default:
          Nstate = 4'b0010;

        endcase
      end
    end

    4'b0111 : begin
      Shadow=1'b1;
      if(ExternalReset == 1'b1)
        Nstate = 4'b0000;
      else begin
        if (Regd_MemDataReady == 1'b0) begin
          Rplus0 = 1'b1;
          Rs_on_AddressUnitRSide = 1'b1;
          ReadMem = 1'b1;
            RFLwrite = 1'b1;
            RFHwrite = 1'b1;
          Nstate = 4'b0111;
        end
        else begin   
          PCplus1 = 1'b1;
          EnablePC = 1'b1;
          Nstate = 4'b0010;
        end
      end
    end

    4'b1010 : begin
     Shadow = 1'b1;
     if (ExternalReset == 1'b1) 
            Nstate = 4'b0000;
     else begin
       if (Regd_MemDataReady == 1'b0) begin
             Rplus0 = 1'b1;
             Rd_on_AddressUnitRSide = 1'b1;
             RFright_on_OpndBus = 1'b1;
             B15to0 = 1'b1;
             ALU_on_Databus = 1'b1;
             WriteMem = 1'b1;
             Nstate = 4'b1001;
        end
        else begin  
             Nstate = 4'b1000; 
        end
      end

    end

    4'b1000 : begin
      PCplus1 = 1'b1;
      EnablePC = 1'b1;
      Nstate = 4'b0010;
    end
    
    default:  Nstate = 4'b0000;

    endcase
  end

  always @ (posedge clk) begin
    Regd_MemDataReady <= memDataReady;
    Pstate <= Nstate;
  end

endmodule
