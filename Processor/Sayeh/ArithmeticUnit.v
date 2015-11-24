//Arithmetic Logic Unit (ALU)
`timescale 1ns/100ps

module ArithmeticUnit (
  A, B, 
  B15to0, AandB, AorB, notB, shlB, shrB, AaddB, AsubB, AmulB, AcmpB,  
  aluout, cin, zout, cout
);
input [15:0] A;
input [15:0] B;
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
input cin;
output [15:0] aluout;
output zout;
output cout;
reg [15:0] aluout;
reg zout;
reg cout;

  always @(
    A or B or B15to0 or AandB or AorB or notB or shlB or shrB or AaddB or AsubB  or AmulB  or AcmpB or cin
  ) 
  begin
    zout = 0; cout = 0; aluout = 0;
    case ({B15to0, AandB, AorB, notB, shlB, shrB, AaddB, AsubB, AmulB, AcmpB})
      10'b1000000000:aluout = B;
      10'b0100000000: aluout = A & B;
      10'b0010000000:  aluout = A | B;
      10'b0001000000:  aluout = ~B;
      10'b0000100000:  aluout = {B[14:0], B[0]};
      10'b0000010000:  aluout = {B[15], B[15:1]};
      10'b0000001000: {cout, aluout} = A + B + cin;
      10'b0000000100:  {cout, aluout} = A - B - cin;
      10'b0000000010:  aluout = A[7:0] * B[7:0];
      10'b0000000001: begin
          aluout = A;
        if (A> B) cout = 1; else cout = 0;
        if (A==B) zout = 1; else zout = 0;
      end
      default: aluout = 0;
    endcase
    if (aluout == 0) zout = 1'b1;
    end
endmodule
