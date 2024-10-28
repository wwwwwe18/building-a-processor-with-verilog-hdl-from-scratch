//*****************************************************
// Project		: Processor
// File			: proc_tb
// Editor		: Wenmei Wang
// Date			: 28/10/2024
// Description	: Testbench
//*****************************************************

// Perform multiplication of 6 and 5 without MUL instruction

module tb;

	integer i = 0;
	
	reg				clk = 0, sys_rst = 0;
	reg		[15:0]	din = 0;
	wire	[15:0]	dout;
	
	top dut (clk, sys_rst, din, dout);
	
	always #5 clk = ~clk;
	
	initial begin
	
		sys_rst = 1'b1;
		repeat(5) @(posedge clk);
		sys_rst = 1'b0;
		#800;
		$stop;
		
	end
	
endmodule