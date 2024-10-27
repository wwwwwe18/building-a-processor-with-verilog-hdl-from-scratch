//*****************************************************
// Project		: Working with Verilog arrays
// File			: section4_mem_arr_tb
// Editor		: Wenmei Wang
// Date			: 27/10/2024
// Description	: Testbench
//*****************************************************

module tb;

    reg				clk = 0, wea = 0;
    reg		[10:0]	addr;
    reg		[31:0]	din;
	wire	[31:0]	dout;
	
	reg		[31:0]	mem	[15:0];	// Size, depth
	
	initial begin
	
		$readmemh("data.mem", mem);
		//$readmemb("", mem);
	
	end
	
	reg		[31:0]	IR;
	
	always #5 clk = ~clk;
	
	integer count = 0;
	integer delay = 0;
	
	always@(posedge clk) begin
	
		if(delay < 4) begin
		
			delay	<= delay + 1;
		
		end
		else begin
		
			count	<= count + 1;
			delay	<= 0;
			
		end
	
	end
	
	always@(*) begin
	
		IR = mem[count];
	
	end

endmodule