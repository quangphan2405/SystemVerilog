interface bus (input clk);
   logic read, write;
   logic [4:0] addr;
   logic [7:0] data_in, data_out;

   modport des (input clk, read, write, addr, data_in,
		output data_out);
   modport tb  (input clk, data_out,
	        output read, write, addr, data_in,
		import write_mem, read_mem);

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

      @(negedge clk);
      rdata = data_out;
      read  <= 0;
      if ( debug )
	$display("At read address: %b, data value: %h", raddr, rdata);
   endtask : read_mem
   
endinterface : bus
