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
   logic [7:0]  rdata;  // stores data read from memory for checking
   knob_t knob;
   virtual interface bus busif;

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

   function new(input int add, dat, 
		input knob_t mode);
      addr = add;
      data = dat;
      knob = mode;
   endfunction : new

   function void configure(virtual interface bus itf);
       busif = itf;
   endfunction : configure
   

   task write_mem (input logic debug = 1);
      @(negedge busif.clk);
      busif.addr    <= addr;
      busif.data_in <= data;
      busif.write   <= 1;
      busif.read    <= 0;

      @(negedge busif.clk);
      busif.write   <= 0;   
      if ( debug )
	$display("At write address: %b , data value: %c", addr, data);
   endtask : write_mem

   // Read from memory
   task read_mem (input  logic debug = 1);

      @(negedge busif.clk);
      busif.addr  <= addr;
      busif.write <= 0;
      busif.read  <= 1;   

      @(negedge busif.clk);
      rdata = busif.data_out;
      busif.read  <= 0;
      if ( debug )
	$display("At read address: %b, data value: %c", addr, rdata);
   endtask : read_mem

endclass : random_value
   
   // SYSTEMVERILOG: timeunit and timeprecision specification
   timeunit 1ns;
   timeprecision 1ns;   

   // SYSTEMVERILOG: new data types - bit ,logic
   bit 	        debug = 1;   
   logic [7:0]  random_data;
   int 	        gen;
   random_value random_val;
   knob_t knob;   

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

	// Class construction
	random_val = new(0, 0, knob_t'(2'b11));
	random_val.configure(tb);

	$display("Random Data Test");

	for (int i = 0; i< 32; i++) begin
	  // Write zero data to every address location
	  gen = random_val.randomize();
	  random_val.write_mem(debug);  	
	  random_val.read_mem(debug);
          // check each memory location for data = 'h00
	  if ( random_val.rdata !== random_val.data )
	     error_status += 1;
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
