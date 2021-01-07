///////////////////////////////////////////////////////////////////////////
// (c) Copyright 2013 Cadence Design Systems, Inc. All Rights Reserved.
//
// File name   : mem_test.sv
// Title       : Memory Testbench Module
// Project     : SystemVerilog Training
// Created     : 2013-4-8
// Description : Defines the Memory testbench module
// Notes       :
// 
///////////////////////////////////////////////////////////////////////////

module mem_test ( bus tb );
   typedef enum bit [1:0] {ASCII = 0, AZ = 1, az = 2, AZ_weight = 3} knob_t;

class random_value;
   randc bit [4:0] addr;
   rand  bit [7:0] data;
   knob_t knob;

   constraint c1 { 
   if (knob == 2'b00)
     data inside { [8'h20:8'h7f] };
   else if (knob == 2'b01)
     data inside { [8'h41:8'h5a] };
   else if (knob == 2'b10)
     data inside { [8'h61:8'h7a] };
   else     
     data dist { [8'h41:8'h5a]:=80, [8'h61:8'h7a]:=20 }; 
   };

   function new(input add, dat, 
		input knob_t mode);
      addr = add;
      data = dat;
      knob = mode;      
   endfunction : new
endclass : random_value

   // Covergroup
   covergroup cg @(posedge tb.clk);
      c1: coverpoint tb.addr;
      c2: coverpoint tb.data_in {
				 bins upcase  = { [8'h41:8'h5a] };
				 bins locase  = { [8'h61:8'h7a] };
				 bins restofb = default;
				 }
      c3: coverpoint tb.data_out {
				  bins upcase  = { [8'h41:8'h5a] };
				  bins locase  = { [8'h61:8'h7a] };
				  bins restofb = default;
				  }
   endgroup : cg				 
   
   // SYSTEMVERILOG: timeunit and timeprecision specification
   timeunit 1ns;
   timeprecision 1ns;   

   // SYSTEMVERILOG: new data types - bit ,logic
   bit 	        debug = 1;
   logic [7:0]  rdata;      // stores data read from memory for checking
   logic [7:0]  random_data;
   int 	        gen;
   random_value random_val;
   knob_t knob;
   cg cg_inst = new();

   logic [12:0] queue[$:32];
   logic [12:0] info;
   
   // Monitor Results
   initial begin
      $timeformat ( -9, 0, " ns", 9 );
      // SYSTEMVERILOG: Time Literals
      #40000ns $display ( "MEMORY TEST TIMEOUT" );
      $finish;
   end

   initial
     begin: memtest
	int error_status;

	knob = AZ_weight;
	random_val = new(0, 0, knob);
	
	$display("Random Data");

	for (int i = 0; i< 32; i++) begin
	  // Write zero data to every address location
	  gen = random_val.randomize();	  	   
	  tb.write_mem(debug, random_val.addr, random_val.data);
   	  queue.push_back({ random_val.addr, random_val.data});	  
	  cg_inst.sample();
        end
	
	$display("Addresses assigned: %0d", queue.size());
	repeat (queue.size())
	  begin
	     info = queue.pop_back();
	     tb.read_mem(~debug, info[12:8], rdata);
	     if (rdata !== info[7:0]) begin
	       $display("Error at address: %b", info[12:8]);
	       error_status += 1;
	     end	     
	  end

	// print results of test
	printstatus(error_status);
	$finish;
     end
   
   // add result print function
   function void printstatus
     (input int status);
      if ( status == 0 )
	$display("TEST PASSED");
      else
	$display("TEST FAILED WITH %d ERRORS", status);   
   endfunction : printstatus
   
endmodule
