module scale_mux #(parameter WIDTH = 1)
   (input  logic sel_a,
    input  logic [WIDTH-1:0] in_a, in_b,
    output logic [WIDTH-1:0] out);

   timeunit 1ns;
   timeprecision 100ps;

   // 2:1 MUX
   always_comb
     begin : MUX
        unique case ( sel_a )
	  1'b1: out = in_a;
	  1'b0: out = in_b;
	  default: out = 'x;
	endcase
     end : MUX

endmodule : scale_mux

	
	
 
	
