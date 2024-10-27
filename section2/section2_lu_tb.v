//*****************************************************
// Project		: Adding logical unit
// File			: section2_lu_tb
// Editor		: Wenmei Wang
// Date			: 27/10/2024
// Description	: Testbench
//*****************************************************

module tb;

	integer i = 0;
	
	top dut ();
	
	// Update value of all GPR to 2
	initial begin
	
		for(i = 0; i < 32; i = i + 1) begin
		
			dut.GPR[i] = 2;
		
		end
	
	end
	
	initial begin
	
		// Logical and imm (ANDI)
		$display("----------------------------------------------");
		dut.IR			= 0;
		dut.`imm_mode	= 1;
		dut.`oper_type	= 6;
		dut.`rsrc1		= 7;	// GPR[7]
		dut.`rdst		= 4;	// GPR[4]
		dut.`isrc		= 56;
		#10;
		$display("OP: ANDI  Rdst:%8b Rsrc1:%8b Imm_data:%8b", dut.GPR[dut.`rdst], dut.GPR[dut.`rsrc1], dut.`isrc);
		$display("----------------------------------------------");
		
		// Logical xor imm (XORI)
		$display("----------------------------------------------");
		dut.IR			= 0;
		dut.`imm_mode	= 1;
		dut.`oper_type	= 7;
		dut.`rsrc1		= 7;	// GPR[7]
		dut.`rdst		= 4;	// GPR[4]
		dut.`isrc		= 56;
		#10;
		$display("OP: XORI  Rdst:%8b Rsrc1:%8b Imm_data:%8b", dut.GPR[dut.`rdst], dut.GPR[dut.`rsrc1], dut.`isrc);
		$display("----------------------------------------------");

	end

endmodule