`include "math_computer_macros.sv"
`include "math_computer_itf.sv"

class InDUT;
	rand logic[`DATASIZE-1:0] a;
	rand logic[`DATASIZE-1:0] b;
	rand logic[`DATASIZE-1:0] c;
endclass : InDUT

class InDUTspec extends InDUT;
	constraint pair {
		if (a[0] == 1'b0)
			b[0] == 1'b1;
	}
	constraint a_range {
		a dist {
			[0:10] 				:/ 1,
			[11:2**`DATASIZE-1]	:/ 1
		};
	}
	constraint c_range {
		(a > b)		->	c < 1000;
	}
endclass : InDUTspec
