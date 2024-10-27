//*****************************************************
// Project		: Adding condition flags
// File			: section3_flag_design
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

// Logial operation: and or xor xnor nand nor not
`define ror			5'b00101	// or is Verilog reserved keyword
`define rand		5'b00110
`define rxor		5'b00111
`define rxnor		5'b01000
`define rnand		5'b01001
`define rnor		5'b01010
`define rnot		5'b01011


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
		
			// -------------------------------------------
			// Arithmetic operation
			// -------------------------------------------
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
			
			// -------------------------------------------
			// Logical operation
			// -------------------------------------------
			`ror: begin		// Bitwise or
			
				if(`imm_mode)
			
					GPR[`rdst] = GPR[`rsrc1] | `isrc;
					
				else
				
					GPR[`rdst] = GPR[`rsrc1] | GPR[`rsrc2];
			
			end
			
			`rand: begin	// Bitwise and
			
				if(`imm_mode)
			
					GPR[`rdst] = GPR[`rsrc1] & `isrc;
					
				else
				
					GPR[`rdst] = GPR[`rsrc1] & GPR[`rsrc2];
			
			end
			
			`rxor: begin	// Bitwise xor
			
				if(`imm_mode)
			
					GPR[`rdst] = GPR[`rsrc1] ^ `isrc;
					
				else
				
					GPR[`rdst] = GPR[`rsrc1] ^ GPR[`rsrc2];
			
			end
			
			`rxnor: begin	// Bitwise xnor
			
				if(`imm_mode)
			
					GPR[`rdst] = GPR[`rsrc1] ~^ `isrc;
					
				else
				
					GPR[`rdst] = GPR[`rsrc1] ~^ GPR[`rsrc2];
			
			end
			
			`rnand: begin	// Bitwise nand
			
				if(`imm_mode)
			
					GPR[`rdst] = ~(GPR[`rsrc1] & `isrc);
					
				else
				
					GPR[`rdst] = ~(GPR[`rsrc1] & GPR[`rsrc2]);
			
			end
			
			`rnor: begin	// Bitwise nor
			
				if(`imm_mode)
			
					GPR[`rdst] = ~(GPR[`rsrc1] | `isrc);
					
				else
				
					GPR[`rdst] = ~(GPR[`rsrc1] | GPR[`rsrc2]);
			
			end
			
			`rnot: begin	// Not
			
				if(`imm_mode)
			
					GPR[`rdst] = ~(`isrc);
					
				else
				
					GPR[`rdst] = ~(GPR[`rsrc1]);
			
			end
		
		endcase
	
	end
	
	// -------------------------------------------
	// Condition flag
	// -------------------------------------------
	
	// Logic for condition flags
	reg sign = 0, zero = 0, overflow = 0, carry = 0;
	reg [16:0] temp_sum;
	
	always@(*) begin
	
		// Sign bit
		if(`oper_type == `mul)
		
			sign = SGPR[15];	// MSB
		
		else
	
			sign = GPR[`rdst][15];
			
		// Zero bit
		if(`oper_type == `mul)
		
			zero = ~((|SGPR) | (|GPR[`rdst]));
		
		else
	
			zero = ~(|GPR[`rdst]);
	
		// Carry bit
		if(`oper_type == `add) begin
		
			if(`imm_mode)
			
				temp_sum = GPR[`rsrc1] + `isrc;

			else
			
				temp_sum = GPR[`rsrc1] + GPR[`rsrc2];
			
			carry = temp_sum[16];
		
		end
		else begin
		
			carry = 1'b0;
		
		end
			
		// Overflow bit
		if(`oper_type == `add) begin
		
			if(`imm_mode)
			
				overflow = ((~GPR[`rsrc1][15] & ~IR[15] & GPR[`rdst][15]) | (GPR[`rsrc1][15] & IR[15] & ~GPR[`rdst][15]));
			
			else
		
				overflow = ((~GPR[`rsrc1][15] & ~GPR[`rsrc2][15] & GPR[`rdst][15]) | (GPR[`rsrc1][15] & GPR[`rsrc2][15] & ~GPR[`rdst][15]));
		
		end
		else if(`oper_type == `sub) begin
		
			if(`imm_mode)
			
				overflow = ((~GPR[`rsrc1][15] & IR[15] & GPR[`rdst][15]) | (GPR[`rsrc1][15] & ~IR[15] & ~GPR[`rdst][15]));
			
			else
		
				overflow = ((~GPR[`rsrc1][15] & GPR[`rsrc2][15] & GPR[`rdst][15]) | (GPR[`rsrc1][15] & ~GPR[`rsrc2][15] & ~GPR[`rdst][15]));
		
		end
		else begin
		
			overflow = 1'b0;
		
		end
	
	end

endmodule