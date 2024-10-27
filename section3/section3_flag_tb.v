//*****************************************************
// Project		: Adding condition flags
// File			: section3_flag_tb
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
		
		// Sign flag
		$display("----------------------------------------------");
		dut.IR			= 0;
		dut.GPR[0]		= 16'h8000;	// 1000_0000_0000_0000
		dut.GPR[1]		= 0;
		dut.`imm_mode	= 0;	// Reg mode
		dut.`oper_type	= 2;	// Add
		dut.`rsrc1		= 0;	// GPR[0]
		dut.`rsrc2		= 1;	// GPR[1]
		dut.`rdst		= 2;	// GPR[2]
		#10;
		$display("OP: SIGN             Rdst:%0d Rsrc1:%0d Rsrc2:%0d", dut.GPR[dut.`rdst], dut.GPR[dut.`rsrc1], dut.GPR[dut.`rsrc2]);
		$display("----------------------------------------------");
		
		// Zero flag
		$display("----------------------------------------------");
		dut.IR			= 0;
		dut.GPR[0]		= 0;
		dut.GPR[1]		= 0;
		dut.`imm_mode	= 0;	// Reg mode
		dut.`oper_type	= 2;	// Add
		dut.`rsrc1		= 0;	// GPR[0]
		dut.`rsrc2		= 1;	// GPR[1]
		dut.`rdst		= 2;	// GPR[2]
		#10;
		$display("OP: ZERO             Rdst:%0d Rsrc1:%0d Rsrc2:%0d", dut.GPR[dut.`rdst], dut.GPR[dut.`rsrc1], dut.GPR[dut.`rsrc2]);
		$display("----------------------------------------------");
		
		// Carry & overflow flag
		$display("----------------------------------------------");
		dut.IR			= 0;
		dut.GPR[0]		= 16'h8000;	// 1000_0000_0000_0000	< 0
		dut.GPR[1]		= 16'h8002;	// 1000_0000_0000_0010	< 0
		dut.`imm_mode	= 0;		// Reg mode
		dut.`oper_type	= 2;		// Add
		dut.`rsrc1		= 0;		// GPR[0]
		dut.`rsrc2		= 1;		// GPR[1]
		dut.`rdst		= 2;		// GPR[2] = 0000_0000_0000_0010 > 0
		#10;
		$display("OP: CARRY & OVERFLOW Rdst:%0d Rsrc1:%0d Rsrc2:%0d", dut.GPR[dut.`rdst], dut.GPR[dut.`rsrc1], dut.GPR[dut.`rsrc2]);
		$display("----------------------------------------------");

	end

endmodule