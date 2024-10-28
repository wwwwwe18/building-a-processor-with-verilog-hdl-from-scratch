//*****************************************************
// Project		: Adding FSM
// File			: section5_ex2_fsm_design
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
	
	// Reading instructions one after another
	reg [2:0] count = 0;
	integer PC = 0;	// Program counter for instructions
	
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
	
		$readmemb("inst_data.mem",inst_mem);
	
	end
	
	// -------------------------------------------
	// FSM states
	// -------------------------------------------
	// idle				: check rest state
	// fetch_inst		: load instruction from program memory
	// dec_exec_inst	: execute instruction + update condition flag
	// next_inst		: next instruction to be fetched
	
	parameter idle = 0, fetch_inst = 1, dec_exec_inst = 2, next_inst = 3, sense_halt = 4, delay_next_inst = 5;
	reg [2:0] state = idle, next_state = idle;
	
	// -------------------------------------------
	// FSM
	// -------------------------------------------
	// 2-process methodology
	
	// Reset decoder (sequential process)
	always@(posedge clk) begin
	
		if(sys_rst)
		
			state <= idle;
			
		else
		
			state <= next_state;
	
	end
	
	// Next state decoder + output decoder (combinational process)
	always@(*) begin
	
		case(state)
		
			// idle: initialize variables
			idle: begin
			
				IR			= 32'h0;
				PC			= 0;
				next_state	= fetch_inst;
			
			end
			
			// fetch_inst: load instruction from program memory
			fetch_inst: begin
			
				IR			= inst_mem[PC];
				next_state	= dec_exec_inst;
			
			end
			
			// dec_exec_inst: execute instruction and update condition flags
			dec_exec_inst: begin
			
				decode_inst();
				decode_condflag();
				next_state	= delay_next_inst;
			
			end
			
			// delay_next_inst: delay between instruction
			delay_next_inst: begin
			
				if(count < 4)
				
					next_state	= delay_next_inst;
					
				else
			
					next_state	= next_inst;
			
			end
			
			// next_inst: predict next instruction address
			next_inst: begin
			
				next_state	= sense_halt;
				
				if(jmp_flag == 1'b1)
				
					PC	= `isrc;
					
				else
				
					PC	= PC + 1;
			
			end
			
			// sense_halt: check status of halt
			sense_halt: begin
			
				if(stop == 1'b0)
				
					next_state	= fetch_inst;
					
				else if(sys_rst == 1'b1)	// Apply reset to exit halt state
				
					next_state	= idle;
					
				else
			
					next_state	= sense_halt;
			
			end
			
			default: next_state = idle;
		
		endcase
	
	end
	
	// Count update (sequential process)
	always@(posedge clk) begin
	
		case(state)
		
			idle: begin
			
				count <= 0;
			
			end
			
			fetch_inst: begin
			
				count <= 0;
			
			end
			
			dec_exec_inst: begin
			
				count <= 0;
			
			end
			
			delay_next_inst: begin
			
				count <= count + 1;
			
			end
			
			next_inst: begin
			
				count <= 0;
			
			end
			
			sense_halt: begin
			
				count <= 0;
			
			end
			
			default: count <= 0;
		
		endcase
	
	end

endmodule