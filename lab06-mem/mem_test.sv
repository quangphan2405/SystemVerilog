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

module mem_test ( input  logic clk, 
                  output logic read, 
                  output logic write, 
                  output logic [4:0] addr, 
                  output logic [7:0] data_in,     // data TO memory
                  input  wire  [7:0] data_out     // data FROM memory
                );
   // SYSTEMVERILOG: timeunit and timeprecision specification
   timeunit 1ns;
   timeprecision 1ns;

   // SYSTEMVERILOG: new data types - bit ,logic
   bit 				     debug = 1;
   logic [7:0] 			     rdata;      // stores data read from memory for checking

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
	  write_mem(debug, i, 'h00);     
	for (int i = 0; i<32; i++)
	  begin 
             // Read every address location
	     read_mem(debug, i, rdata);
             // check each memory location for data = 'h00
	     if ( rdata !== 'h00 )
	       error_status += 1;
	  end

	// print results of test
	printstatus(error_status);
	
	$display("Data = Address Test");

	for (int i = 0; i< 32; i++)
	  // Write data = address to every address location
	  write_mem(debug, i , i);
	for (int i = 0; i<32; i++)
	  begin
             // Read every address location
	     read_mem(debug, i , rdata);
             // check each memory location for data = address
	     if ( rdata !== i )
	       error_status += 1;
	  end

	// print results of test
	printstatus(error_status);
	$finish;
     end

   // Write to memory
   task write_mem
     (input logic debug = 1,
      input logic [4:0] waddr,
      input logic [7:0] wdata);

      @(negedge clk);
      addr    <= waddr;
      data_in <= wdata;
      write   <= 1;
      read    <= 0;

      @(negedge clk);
      write   <= 0;   
      if ( debug )
	$display("At write address: %b , data value: %h", waddr, wdata);
   endtask : write_mem

   // Read from memory
   task read_mem
     (input  logic debug = 1,
      input  logic [4:0]  raddr,
      output logic [7:0] rdata);

      @(negedge clk);
      addr  <= raddr;
      write <= 0;
      read  <= 1;

      // Short propagation delay for output updating
      @(posedge clk) #1ns rdata = data_out;

      @(negedge clk);
      read  <= 0;
      if ( debug )
	$display("At read address: %b, data value: %h", raddr, rdata);
   endtask : read_mem
   
   // add result print function
   function void printstatus
     (input int status);
      if ( status == 0 )
	$display("TEST PASSED");
      else
	$display("TEST FAILED WITH %d ERRORS", status);   
   endfunction : printstatus
   
endmodule
