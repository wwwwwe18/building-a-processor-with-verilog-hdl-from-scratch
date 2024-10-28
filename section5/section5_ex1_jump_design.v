//*****************************************************
// Project		: Adding jump instructions
// File			: section5_ex1_jump_design
// Editor		: Wenmei Wang
// Date			: 28/10/2024
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
`define ror			5'b00101
`define rand		5'b00110
`define rxor		5'b00111
`define rxnor		5'b01000
`define rnand		5'b01001
`define rnor		5'b01010
`define rnot		5'b01011

// Load & store instruction
`define storereg	5'b01101	// Store content of register in data memory
`define storedin	5'b01110	// Store content of din bus in data memory
`define senddout	5'b01111	// Send data from DM to dout bus
`define senddreg	5'b10001	// Send data from DM to register

// Jump and branch instruction
`define jump		5'b10010	// Jump to address
`define jcarry		5'b10011	// Jump if carry
`define jnocarry	5'b10100
`define jsign		5'b10101	// Jump if sign
`define jnosign		5'b10110
`define jzero		5'b10111	// Jump if zero
`define jnozero		5'b11000
`define joverflow	5'b11001	// Jump if overflow
`define jnooverflow	5'b11010

// Halt
`define halt		5'b11011

module top(
	
	input		clk, sys_rst,
	input		[15:0]	din,
	output	reg	[15:0]	dout

);

	// Adding program and data memory
	reg	[31:0]	inst_mem	[15:0];	// Program memory
	reg	[15:0]	data_mem	[15:0];	// Data memory

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
	
	// Logic for condition flags
	reg sign = 0, zero = 0, overflow = 0, carry = 0;
	reg [16:0] temp_sum;
	
	// Jump
	reg jmp_flag = 0;
	reg stop = 0;
	
	task decode_inst();
	
	begin
	
		jmp_flag = 1'b0;
		stop = 1'b0;
	
		case(`oper_type)
		
			// -------------------------------------------
			// Arithmetic operations
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
			// Logical operations
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
			
			// -------------------------------------------
			// Work with ports and data memory
			// -------------------------------------------
			`storereg: begin	// Store content of register in data memory
			
				data_mem[`isrc] = GPR[`rsrc1];
			
			end
			
			`storedin: begin	// Store content of din bus in data memory
			
				data_mem[`isrc] = din;
			
			end
			
			`senddout: begin	// Send data from DM to dout bus
			
				dout = data_mem[`isrc];
			
			end
			
			`senddreg: begin	// Send data from DM to register
			
				GPR[`rdst] = data_mem[`isrc];
			
			end
			
			// -------------------------------------------
			// Jump, branch and halt
			// -------------------------------------------
			`jump: begin
			
				jmp_flag = 1'b1;
			
			end
			
			`jcarry: begin
			
				if(carry == 1'b1)
				
					jmp_flag = 1'b1;
					
				else
				
					jmp_flag = 1'b0;
			
			end
			
			`jsign: begin
			
				if(sign == 1'b1)
				
					jmp_flag = 1'b1;
					
				else
				
					jmp_flag = 1'b0;
			
			end
			
			`jzero: begin
			
				if(zero == 1'b1)
				
					jmp_flag = 1'b1;
					
				else
				
					jmp_flag = 1'b0;
			
			end
			
			`joverflow: begin
			
				if(overflow == 1'b1)
				
					jmp_flag = 1'b1;
					
				else
				
					jmp_flag = 1'b0;
			
			end
			
			`jnocarry: begin
			
				if(carry == 1'b0)
				
					jmp_flag = 1'b1;
					
				else
				
					jmp_flag = 1'b0;
			
			end
			
			`jnosign: begin
			
				if(sign == 1'b0)
				
					jmp_flag = 1'b1;
					
				else
				
					jmp_flag = 1'b0;
			
			end
			
			`jnozero: begin
			
				if(zero == 1'b0)
				
					jmp_flag = 1'b1;
					
				else
				
					jmp_flag = 1'b0;
			
			end
			
			`jnooverflow: begin
			
				if(overflow == 1'b0)
				
					jmp_flag = 1'b1;
					
				else
				
					jmp_flag = 1'b0;
			
			end
			
			// Halt
			`halt: begin
			
				stop = 1'b1;
			
			end
		
		endcase
	
	end

	endtask
	
	// -------------------------------------------
	// Condition flags
	// -------------------------------------------
	task decode_condflag();
	
	begin
	
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
	
	endtask
	
	// -------------------------------------------
	// Reading program
	// -------------------------------------------
	
	initial begin
	
		$readmemb("C:\Users\wangw\Documents\FPGA\Vitis_Vivado\processor_design\processor_design.srcs\sources_1\new\inst_data.mem",inst_mem);
	
	end
	
	// Reading instructions one after another
	reg [2:0] count = 0;
	integer PC = 0;	// Program counter for instructions
	
	always@(posedge clk) begin
	
		if(sys_rst) begin
		
			count	<= 0;
			PC		<= 0;
		
		end
		else begin
		
			if(count < 4) begin
			
				count <= count + 1;
			
			end
			else begin
			
				count	<= 0;
				PC		<= PC + 1;
			
			end
		
		end
	
	end
	
	// Reading instructions
	always@(*) begin
	
		if(sys_rst == 1'b1)
		
			IR = 0;
			
		else begin
		
			IR = inst_mem[PC];
			decode_inst();
			decode_condflag();
		
		end
	
	end

endmodule