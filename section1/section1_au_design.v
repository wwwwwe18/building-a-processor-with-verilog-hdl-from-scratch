//*****************************************************
// Project		: Adding arithmetic unit
// File			: section1_au_design
// Editor		: Wenmei Wang
// Date			: 27/10/2024
// Description	: Design
//*****************************************************

`timescale 1ns / 1ps

// Fields of IR
`define oper_type	IR[31:27]	// Operation type
`define rdst		IR[26:22]	// Destination register
`define rsrc1		IR[21:17]	// Source register 1
`define imm_mode	IR[16]		// Mode selection
`define rsrc2		IR[15:11]	// Source register 2
`define isrc		IR[15:0]	// Immediate data

// Arithmetic operation
`define movsgpr		5'b00000
`define mov			5'b00001
`define add			5'b00010
`define sub			5'b00011
`define mul			5'b00100


module top();

	// Instruction register
	// IR		<--IR[31:27]--><--IR[26:22]--><--IR[21:17]--><-- IR[16]  --><--IR[15:11]--><--IR[10:0]-->
	// Fields	<--  oper   --><--  rdst   --><--  rsrc1  --><-- imm_mode--><--  rsrc2  --><-- unused -->
	// Fields	<--  oper   --><--  rdst   --><--  rsrc1  --><-- imm_mode--><--     immediate_data    -->
	reg	[31:0]	IR;
	
	// General purpose register
	// IR[26:22] --> 2^5
	// GPR[0] ... GPR[31]
	reg	[15:0]	GPR	[31:0];	// Size of each reg: 16 bits
	
	// Special register --> MSB of multiplication
	reg	[15:0]	SGPR;
	
	reg	[31:0]	mul_res;
	
	always@(*) begin
	
		case(`oper_type)
		
			`movsgpr: begin
			
				GPR[`rdst] = SGPR;
			
			end
			
			`mov: begin
			
				if(`imm_mode)	// Store immidiate data
			
					GPR[`rdst] = `isrc;
					
				else
				
					GPR[`rdst] = GPR[`rsrc1];
					
			end
			
			`add: begin
			
				if(`imm_mode)
			
					GPR[`rdst] = GPR[`rsrc1] + `isrc;
					
				else
				
					GPR[`rdst] = GPR[`rsrc1] + GPR[`rsrc2];
			
			end
			
			`sub: begin
			
				if(`imm_mode)
			
					GPR[`rdst] = GPR[`rsrc1] - `isrc;
					
				else
				
					GPR[`rdst] = GPR[`rsrc1] - GPR[`rsrc2];
			
			end
			
			`mul: begin
			
				if(`imm_mode)
			
					mul_res = GPR[`rsrc1] * `isrc;
					
				else
				
					mul_res = GPR[`rsrc1] * GPR[`rsrc2];
					
				GPR[`rdst]	= mul_res[15:0];	// LSB 16-bit
				SGPR		= mul_res[31:16];	// MSB 16-bit
			
			end
		
		endcase
	
	end

endmodule