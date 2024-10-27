//*****************************************************
// Project		: Assignment 1
// File			: section1_a1_tb
// Editor		: Wenmei Wang
// Date			: 27/10/2024
// Description	: Testing multiplication operation
//*****************************************************

// Add code in testbench top to verify multiplication operation. Try multiplying GPR0 and GPR1 and saving the LSB 16-bit result to GPR2 and the MSB 16-bit result to GPR3.

module tb;

	integer i = 0;
	
	top dut ();
	
	initial begin
	
		// Update value of all GPR to 2
		for(i = 0; i < 32; i = i + 1) begin
		
			dut.GPR[i] = 2;
		
		end
		
		dut.GPR[0] = 16'b0000_0000_0000_1000;
		dut.GPR[1] = 16'b1000_0000_0000_0000;
	
	end
	
	initial begin
		
		// Register mul op (mul)
		$display("----------------------------------------------");
		dut.IR			= 0;
		dut.`imm_mode	= 0;
		dut.`oper_type	= 4;
		dut.`rsrc1		= 0;		// GPR[0]
		dut.`rsrc2		= 1;		// GPR[1]
		dut.`rdst		= 2;		// GPR[2] - LSB 16-bit
		#10;
		$display("OP: MUL     MSB16-bit:%0d LSB16-bit:%0d Rsrc1:%0d Rsrc2:%0d", dut.SGPR, dut.GPR[dut.`rdst], dut.GPR[dut.`rsrc1], dut.GPR[dut.`rsrc2]);
		$display("----------------------------------------------");
		
		// Speical register mov op (movsgpr)
		$display("----------------------------------------------");
		dut.IR			= 0;
		dut.`imm_mode	= 0;
		dut.`oper_type	= 0;
		dut.`rdst		= 3;	// GPR[3]
		#10;
		$display("OP: MOVSGPR Rdst:%0d Rspec:%0d", dut.GPR[dut.`rdst], dut.SGPR);
		$display("----------------------------------------------");

	end

endmodule