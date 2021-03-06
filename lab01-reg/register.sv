module register
  (input  logic clk, rst_, enable,
   input  logic [7:0] data,
   output logic [7:0] out);

   timeunit 1ns;
   timeprecision 100ps;

   // Register
   always_ff @(posedge clk or negedge rst_)
     begin : REG
	if ( !rst_ )
	  out <= '0;
	else if ( enable )
	  out <= data;
	else
	  out <= out;
     end : REG

endmodule : register
