module counter
  (input  logic clk, rst_, load, enable,
   input  logic [4:0] data,
   output logic [4:0] count);

   timeunit 1ns;
   timeprecision 100ps;

   // Counter
   always_ff @(posedge clk or negedge rst_)
     begin : COUNTER
	if ( !rst_ )
	  count <= '0;
	else if ( load )
	  count <= data;
	else if ( enable )
	  count <= count + 1;
	else
	  count <= count;
     end : COUNTER

endmodule : counter

   
