///////////////////////////////////////////////////////////////////////////
// (c) Copyright 2013 Cadence Design Systems, Inc. All Rights Reserved.
//
// File name   : counter.sv
// Title       : Simple class
// Project     : SystemVerilog Training
// Created     : 2013-4-8
// Description : Simple counter class
// Notes       :
// 
///////////////////////////////////////////////////////////////////////////

module counterclass;

   // add counter class here
class counter;
   protected int count;

   function void load(input int data);
      count = data;
   endfunction : load

   function int getcount();
      return count;
   endfunction : getcount

endclass : counter

   int 		 result;
   counter cnt = new;
   cnt.load(3);
   result = cnt.getcount();
   $display("Count is %d", result);

endmodule
