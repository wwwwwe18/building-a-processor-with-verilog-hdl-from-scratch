//*****************************************************
// Project		: Working with memory generator IP
// File			: section4_mem_ip_design
// Editor		: Wenmei Wang
// Date			: 27/10/2024
// Description	: Design
//*****************************************************

module tb;

    reg				clk = 0, wea = 0;
    reg		[10:0]	addr;
    reg		[31:0]	din;
	wire	[31:0]	dout;
    
    blk_mem_gen_0 dut (clk, wea, addr, din, dout);
	
	reg		[31:0]	IR;
	
	always #5 clk = ~clk;
	
	integer count = 0;
	integer delay = 0;
	
	always@(posedge clk) begin
	
		if(delay < 4) begin
		
			addr	<= count;
			IR		<= dout;
			delay	<= delay + 1;
		
		end
		else begin
		
			count	<= count + 1;
			delay	<= 0;
			
		end
	
	end

endmodule