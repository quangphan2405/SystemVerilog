module alu import typedefs::*;
   (input  logic       clk,
    input  logic [7:0] accum, data,
    input  opcode_t    opcode,
    output logic       zero,
    output logic [7:0] out);
   

   timeunit 1ns;
   timeprecision 100ps;

   // Generate "zero"
   always_comb
     if ( accum == '0 )
       zero <= 1;
     else
       zero <= 0;

   // Generate output
   always_ff @( negedge clk )
     unique case ( opcode )
       HLT, SKZ, STO, JMP: out <= accum;
       ADD               : out <= data + accum;
       AND               : out <= data & accum;
       XOR               : out <= data ^ accum;
       LDA               : out <= data;
       default           : out <= accum;
     endcase // unique case ( opcode )

endmodule : alu

       
     
	
   
