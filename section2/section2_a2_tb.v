//*****************************************************
// Project		: Assignment 2
// File			: section2_a2_tb
// Editor		: Wenmei Wang
// Date			: 27/10/2024
// Description	: Testing logical operation in register mode
//*****************************************************

// Add code in testbench top to verify OR, NOR and NOT operation. Try performing ORing and NORing between GPR4 and GPR16 also perform NOT operation with GPR6. Update the result of each operation in GPR0.

module tb;

	integer i = 0;
	
	top dut ();
	
	// Update value of all GPR to 2
	initial begin
	
		for(i = 0; i < 32; i = i + 1) begin
		
			dut.GPR[i] = 2;
		
		end
		
		dut.GPR[4]	= 16'b0000_1010_1101_0010;
		dut.GPR[6]	= 16'b1100_1010_1101_1010;
		dut.GPR[16]	= 16'b0110_0110_0000_1110;
	
	end
	
	initial begin
	
		// Logical or register (OR)
		$display("----------------------------------------------");
		dut.IR			= 0;
		dut.`imm_mode	= 0;
		dut.`oper_type	= 5;
		dut.`rsrc1		= 4;	// GPR[4]
		dut.`rsrc2		= 16;	// GPR[16]
		dut.`rdst		= 0;	// GPR[0]
		#10;
		$display("OP: OR  Rdst:%16b Rsrc1:%16b Rsrc2:%16b", dut.GPR[dut.`rdst], dut.GPR[dut.`rsrc1], dut.GPR[dut.`rsrc2]);
		$display("----------------------------------------------");
		
		// Logical or register (NOR)
		$display("----------------------------------------------");
		dut.IR			= 0;
		dut.`imm_mode	= 0;
		dut.`oper_type	= 10;
		dut.`rsrc1		= 4;	// GPR[4]
		dut.`rsrc2		= 16;	// GPR[16]
		dut.`rdst		= 0;	// GPR[0]
		#10;
		$display("OP: NOR Rdst:%16b Rsrc1:%16b Rsrc2:%16b", dut.GPR[dut.`rdst], dut.GPR[dut.`rsrc1], dut.GPR[dut.`rsrc2]);
		$display("----------------------------------------------");
		
		// Logical not register (NOT)
		$display("----------------------------------------------");
		dut.IR			= 0;
		dut.`imm_mode	= 0;
		dut.`oper_type	= 11;
		dut.`rsrc1		= 6;	// GPR[6]
		dut.`rdst		= 0;	// GPR[0]
		#10;
		$display("OP: NOT Rdst:%16b Rsrc1:%16b", dut.GPR[dut.`rdst], dut.GPR[dut.`rsrc1]);
		$display("----------------------------------------------");

	end

endmodule