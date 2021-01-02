///////////////////////////////////////////////////////////////////////////
// (c) Copyright 2013 Cadence Design Systems, Inc. All Rights Reserved.
//
// File name   : control.sv
// Title       : Control Module
// Project     : SystemVerilog Training
// Created     : 2013-4-8
// Description : Defines the Control module
// Notes       :
// 
///////////////////////////////////////////////////////////////////////////

// import SystemVerilog package for opcode_t and state_t
import typedefs::*;

module control  (
                output logic      load_ac ,
                output logic      mem_rd  ,
                output logic      mem_wr  ,
                output logic      inc_pc  ,
                output logic      load_pc ,
                output logic      load_ir ,
                output logic      halt    ,
                input  opcode_t   opcode  ,
                input             zero    ,
                input             clk     ,
                input             rst_   
                );
   // SystemVerilog: time units and time precision specification
   timeunit 1ns;
   timeprecision 100ps;

   state_t state, nstate;
   bit 	   ALUOP;
   
   // Intermediate variable
   assign ALUOP = ( opcode inside {ADD, AND, XOR, LDA} );

   // State & control logic and outputs
   always_ff @(posedge clk or negedge rst_)
     if (!rst_) begin
	state   <= INST_ADDR;
	{mem_rd, load_ir, halt, inc_pc, load_ac, load_pc, mem_wr} <= '0;
     end    
     else begin
	state <= nstate;
	unique case ( nstate )
	  INST_FETCH      : mem_rd <= 1;
	  INST_LOAD, IDLE : begin
	     load_ir <= 1;
	  end
	  OP_ADDR         : begin
	     mem_rd  <= 0;
	     load_ir <= 0;
	     halt    <= ( opcode == HLT );
	     inc_pc  <= 1;
	  end
	  OP_FETCH        : begin
	     mem_rd  <= ALUOP;
	     halt    <= 0;
	     inc_pc  <= 0;
	  end
	  ALU_OP          : begin
	     inc_pc  <= ( opcode == SKZ && zero );
	     load_ac <= ALUOP;
	     load_pc <= ( opcode == JMP );
	  end
	  STORE           : begin
	     inc_pc  <= ( opcode == JMP );
	     load_pc <= ( opcode == JMP );
	     mem_wr  <= ( opcode == STO );
	  end
	  default: {mem_rd, load_ir, halt, inc_pc, load_ac, load_pc, mem_wr} <= '0;
	endcase // unique case ( nstate )
     end   

   // Next state logic
   always_comb
     unique case ( state )
       INST_ADDR : nstate <= rst_ ? INST_FETCH : INST_ADDR;
       INST_FETCH: nstate <= INST_LOAD;
       INST_LOAD : nstate <= IDLE;
       IDLE      : nstate <= OP_ADDR;
       OP_ADDR   : nstate <= OP_FETCH;
       OP_FETCH  : nstate <= ALU_OP;
       ALU_OP    : nstate <= STORE;
       STORE     : nstate <= INST_ADDR;
       default   : nstate <= INST_ADDR;
     endcase // unique case ( state )   

endmodule : control
