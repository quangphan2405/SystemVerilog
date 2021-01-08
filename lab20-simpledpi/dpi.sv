`include "math.sv"
module dpi;
   
   import "DPI-C" function int system (input string command);
   import "DPI-C" function string getenv (input string name);
   import "DPI-C" function real sin (input real angle);

   int ok;
   real sinval, angle;
   
   initial begin
      // Print 'Hello World'
      ok = system("echo 'Hello World'");

      // Print current day and time
      ok = system("date");

      // Print current PATH environmental variable
      $display("Current PATH: %s", getenv("PATH"));

      // Display the first eight sine values at pi/4 interval
      for (int i=0; i<8; i++) begin
	 angle = `M_PI_4*i;
	 sinval = sin(angle);
	 $display("sin(%0f)= %0f", angle, sinval);
      end
   end
endmodule // dpi
