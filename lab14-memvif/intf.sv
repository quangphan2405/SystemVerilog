`timescale 1ns/100ps
interface bus (input clk);
   logic read, write;
   logic [4:0] addr;
   logic [7:0] data_in, data_out;

   modport des (input clk, read, write, addr, data_in,
		output data_out);
   modport tb  (input clk, data_out,
	        output read, write, addr, data_in,
		import write_mem, read_mem);
   
endinterface : bus
