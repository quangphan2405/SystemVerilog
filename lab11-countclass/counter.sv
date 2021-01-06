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

// Counter class
class counter;   
   protected int count;
   int 		 maxlim, minlim;

   function new(input int val = 0, maxval, minval);
      check_limit(maxval, minval);
      check_set(val);
   endfunction : new

   function void load(input int val);
      check_set(val);
   endfunction : load

   function int getcount();
      return count;
   endfunction : getcount

   function void check_limit(input int a,b);
      begin
	 maxlim = (a >= b) ? a : b;
	 minlim = (a <  b) ? a : b;
      end
   endfunction : check_limit

   function void check_set(input int set);
      if (set >= minlim && set <= maxlim)
	count = set;
      else begin
	 count = minlim;
	 $display("Warning: given input not in range!");
      end
   endfunction : check_set 	          
endclass : counter

// Derived classes
class upcounter extends counter;
   static int upcount;
   bit carry;
   
   function new(input int val, maxval, minval);
      super.new(val, maxval, minval);
      carry = 0;
      upcount++;
   endfunction : new

   function int getcarry();
      return carry;
   endfunction : getcarry

   function void next();
      carry = (count == maxlim) ? 1 : 0;
      count = (count == maxlim) ? minlim : (count + 1);
   endfunction : next

   static function int get_upcount();
      return (upcount);
   endfunction : get_upcount
endclass : upcounter

class downcounter extends counter;
   static int downcount;
   bit borrow;
   
   function new(input int val, maxval, minval);
      super.new(val, maxval, minval);
      borrow = 0;
      downcount++;
   endfunction : new

   function int getborrow();
      return borrow;
   endfunction : getborrow
   
   function void next();
      borrow = (count == minlim) ? 1: 0;
      count  = (count == minlim) ? maxlim : (count - 1);
   endfunction : next

   static function int get_downcount();
      return (downcount);
   endfunction : get_downcount
endclass : downcounter

// Aggregate class
class timer;
   upcounter hours;
   upcounter minutes;
   upcounter seconds;

   function new(input int h, m, s);
      hours   = new(h, 0, 23);
      minutes = new(m, 0, 59);
      seconds = new(s, 0, 59);
   endfunction : new

   function void load(input int h, m, s);
      hours.load(h);
      minutes.load(m);
      seconds.load(s);
   endfunction : load

   function void showval();
      $display("Current time is %0d:%0d:%0d", hours.getcount(),
	       minutes.getcount(), seconds.getcount());
   endfunction : showval

   function void next();
      seconds.next();
      if (seconds.getcarry() == 1) begin
	minutes.next();
	if (minutes.getcarry() == 1)
	  hours.next;
      end
      $display("New time is %0d:%0d:%0d", hours.getcount(),
	       minutes.getcount(), seconds.getcount());
   endfunction : next
endclass : timer
   
   
   // Initialize to 1 second before midnight
   timer timecnt = new(23, 59, 59);

   // Stimulus
   initial begin
      timecnt.showval();
      timecnt.next();
   end

endmodule
