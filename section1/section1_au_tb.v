//*****************************************************
// Project		: Adding arithmetic unit
// File			: section1_au_tb
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
	
		// Immediate add op (ADI)
		$display("----------------------------------------------");
		dut.IR			= 0;
		dut.`imm_mode	= 1;
		dut.`oper_type	= 2;
		dut.`rsrc1		= 2;	// GPR[2] = 2
		dut.`rdst		= 0;	// GPR[0]
		dut.`isrc		= 4;
		#10;
		$display("OP: ADI  Rdst:%0d Rsrc1:%0d Imm_data:%0d", dut.GPR[dut.`rdst], dut.GPR[dut.`rsrc1], dut.`isrc);
		$display("----------------------------------------------");
		
		// Register add op (ADD)
		$display("----------------------------------------------");
		dut.IR			= 0;
		dut.`imm_mode	= 0;
		dut.`oper_type	= 2;
		dut.`rsrc1		= 4;	// GPR[4]
		dut.`rsrc2		= 5;	// GPR[5]
		dut.`rdst		= 0;	// GPR[0]
		#10;
		$display("OP: ADD  Rdst:%0d Rsrc1:%0d Rsrc2:%0d", dut.GPR[dut.`rdst], dut.GPR[dut.`rsrc1], dut.GPR[dut.`rsrc2]);
		$display("----------------------------------------------");
		
		// Immediate mov op (MOVI)
		$display("----------------------------------------------");
		dut.IR			= 0;
		dut.`imm_mode	= 1;
		dut.`oper_type	= 1;
		dut.`rdst		= 4;	// GPR[4]
		dut.`isrc		= 55;
		#10;
		$display("OP: MOVI Rdst:%0d Imm_data:%0d", dut.GPR[dut.`rdst], dut.`isrc);
		$display("----------------------------------------------");
		
		// Register mov op (MOV)
		$display("----------------------------------------------");
		dut.IR			= 0;
		dut.`imm_mode	= 0;
		dut.`oper_type	= 1;
		dut.`rdst		= 4;	// GPR[4]
		dut.`rsrc1		= 7;	// GPR[7]
		#10;
		$display("OP: MOV  Rdst:%0d Rsrc1:%0d", dut.GPR[dut.`rdst], dut.GPR[dut.`rsrc1]);
		$display("----------------------------------------------");

	end

endmodule