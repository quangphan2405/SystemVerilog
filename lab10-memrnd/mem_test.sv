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
   // SYSTEMVERILOG: timeunit and timeprecision specification
   timeunit 1ns;
   timeprecision 1ns;

   // SYSTEMVERILOG: new data types - bit ,logic
   bit 				     debug = 1;
   logic [7:0] 			     rdata;      // stores data read from memory for checking
   logic [7:0] 			     random_data;
   int 				     gen;

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

	$display("Clear Memory Test");

	for (int i = 0; i< 32; i++)
	  // Write zero data to every address location
	  tb.write_mem(debug, i, 'h00);     
	for (int i = 0; i<32; i++)
	  begin 
             // Read every address location
	     tb.read_mem(debug, i, rdata);
             // check each memory location for data = 'h00
	     if ( rdata !== 'h00 )
	       error_status += 1;
	  end

	// print results of test
	printstatus(error_status);
	
	$display("Data = Address Test");

	for (int i = 0; i< 32; i++)
	  // Write data = address to every address location
	  tb.write_mem(debug, i , i);
	for (int i = 0; i<32; i++)
	  begin
             // Read every address location
	     tb.read_mem(debug, i , rdata);
             // check each memory location for data = address
	     if ( rdata !== i )
	       error_status += 1;
	  end

	// print results of test
	printstatus(error_status);

	$display("Random Data");

	for (int i = 0; i< 32; i++) begin
	  // Write zero data to every address location
	  gen = randomize(random_data) with { random_data dist { [8'h41:8'h5a]:=8, [8'h61:8'h7a]:=2 }; };
	  tb.write_mem(debug, i, random_data);   	
	  tb.read_mem(debug, i, rdata);
          // check each memory location for data = 'h00
	  if ( rdata !== random_data )
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
