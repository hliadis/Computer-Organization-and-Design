
/*Arithmetic and logical unit: It creates a 32 bit signal depending on the op input*/
module ALU(out, zero, inA, inB,op);
	input [31:0] inA, inB;
	input [3:0] op;
	
	output zero;
	output reg [31:0] out;
	
	assign zero = (out == 0);
	
	always @ (*)
	begin
	
	case(op)
		4'b0000: out = inA & inB;
		4'b0001: out = inA | inB;
		4'b0010: out = inA + inB;
		4'b0110: out = inA - inB;
		4'b0111: out = (inA < inB)? 1 : 0;
		4'b1100: out = ~(inA | inB);
		default out = 32'bx;
	
	endcase
	end
endmodule

/*Where the program ,that cpu gonna execute, is stored*/
module InstructionMemory(addr, dout, ren);
	input[31:0] addr;
	input ren ;
	output reg [31:0] dout;
	reg [31:0] data[4095:0];
	
	always @(*)
	begin
	if(ren == 1)
		dout = data[addr[9:0]];
	end
	
endmodule

/*Get access to the registers of the cpu*/
module RegFile (clock, reset, raA, raB, wa, wen, wd, rdA, rdB);

	input clock, reset, wen;
	input [4:0] raA, raB, wa;
	input [31:0] wd;

	output [31:0] rdA, rdB;

	integer i;
	reg[31:0] data [31:0];

	assign rdA = data[raA];
	assign rdB = data[raB];

	always @(negedge clock)
	begin
	if(wen) 
		data[wa] = wd;	
	end

	always @(negedge reset)
	begin 
		for( i = 0 ; i < 32; i = i + 1)
			data[i] = 0;
	end

endmodule

/*Program counter: the pointer that points to the next address of the instruction memory*/
module PC(clock, reset, PC_new, PC_out);
	input clock , reset;
	input [31: 0] PC_new;
	output reg [31:0] PC_out;
	
	always @(negedge clock or negedge reset)
	begin 
		if(reset == 1'b0)
			PC_out  <= 0;
		else
			PC_out <= PC_new;
	end
endmodule

module adder(inA,new_addr);
		input [31:0] inA;
		output [31:0] new_addr;
		assign new_addr  = inA + 4;
		
endmodule

/*Control Unit: It generates signals depending on the inputs(opcode, func)*/
module FSM(func, opcode, MemtoReg, MemWrite, Branch, ALUSrc, RegDst, RegWrite, ALUControl, MemRead, Bne);
	input [5:0] func, opcode;
	output reg MemtoReg, MemWrite, Branch, ALUSrc, RegDst, RegWrite, MemRead, Bne;
	output reg [3:0] ALUControl;
	reg [1:0] ALUOp;
	
	always @ (opcode)
	begin
	
		case(opcode)
			6'b000000: 
			begin
				RegWrite = 1'b1; RegDst = 1'b1; ALUSrc = 1'b0; Branch = 1'b0; MemWrite = 1'b0; MemtoReg = 1'b0; ALUOp = 2'b10; MemRead = 1'b0; Bne = 1'b0;
			end
			
			6'b100011:
			begin
				RegWrite =1'b1; RegDst = 1'b0; ALUSrc = 1'b1; Branch = 1'b0; MemWrite = 1'b0; MemtoReg = 1'b1; ALUOp = 2'b00; MemRead = 1'b1; Bne = 1'b0;
			end
			
			6'b101011:
			begin
				RegWrite = 1'b0; RegDst = 1'bx; ALUSrc = 1'b1; Branch = 1'b0; MemWrite = 1'b1; MemtoReg = 1'bx; ALUOp = 2'b00; MemRead = 1'b0; Bne = 1'b0;
			end
			
			6'b000100:
			begin 
				RegWrite = 1'b0; RegDst = 1'bx; ALUSrc = 1'b0; Branch = 1'b1; MemWrite = 1'b0; MemtoReg = 1'bx; ALUOp = 2'b01; MemRead = 1'b0; Bne = 1'b0;
			end
			
			6'b001000:
			begin	
				RegWrite = 1'b1; RegDst = 1'b0; ALUSrc = 1'b1; Branch = 1'b0; MemWrite = 1'b0; MemtoReg = 1'b0; ALUOp = 2'b00; MemRead = 1'b0; Bne = 1'b0;
			end
			6'b000101:
			begin
				RegWrite = 1'b0; RegDst = 1'b0; ALUSrc = 1'b1; Branch = 1'b1; MemWrite = 1'b0; MemtoReg = 1'b0; ALUOp = 2'b01; MemRead = 1'b0; Bne = 1'b1;
			end
			default $display("ERROR:Wrong Opcode\n");
			
			endcase
		end
	
	always @(ALUOp or func)
	begin
		case(ALUOp)
			2'b00: ALUControl = 4'b0010;
			2'b01: ALUControl = 4'b0110;
			2'b10: case (func)
				6'b100000: ALUControl = 4'b0010;//add
				6'b100010: ALUControl = 4'b0110;//sub
				6'b100100: ALUControl = 4'b0000;//and
				6'b100101: ALUControl = 4'b0001;//or 
				6'b101010: ALUControl = 4'b0111;//slt
				default $display("ERROR:Wrong Func\n");
				endcase
			endcase
	end	
endmodule

/*Ram memory*/
module Memory (clock, reset,ren,wen ,addr, din, dout);
  input         ren, wen, clock, reset;
  input  [31:0] addr, din;
  output [31:0] dout;

  reg [31:0] data[4095:0];
  wire [31:0] dout;

  always @(ren or wen)   // It does not correspond to hardware. Just for error detection
    if (ren & wen)
      $display ("\nMemory ERROR (time %0d): ren and wen both active!\n", $time);

  always @(negedge ren or posedge wen) begin // It does not correspond to hardware. Just for error detection
    if (addr[31:10] != 0)
      $display("Memory WARNING (time %0d): address msbs are not zero\n", $time);
  end  

  assign dout = ((wen==1'b0) && (ren==1'b1)) ? data[addr[9:0]] : 32'bx;  
  
  always @(negedge clock or negedge reset)
   begin
    if ((wen == 1'b1) && (ren==1'b0))
        data[addr[9:0]] = din;
   end

endmodule

module mux5(A, B, sel, out);
	input [4:0] A, B;
	input sel;
	output reg [4:0] out;
	
	always @ (*)
	begin 
		case(sel)
		0: out = A;
		1: out = B;
		endcase
	end
endmodule

module sign_extension(in, exte);
	input [15:0] in;
	output [31:0] exte;
	
	assign exte = $signed(in);
endmodule

module mux32(A, B, sel, out);
	input [31:0] A, B;
	input sel;
	output reg [31:0] out;
	
	always @ (*)
	begin 
		case(sel)
		0: out = A;
		1: out = B;
		endcase
	end
endmodule

/*It helps the execution of branchtype assembly orders*/
module PCBranch(inA, inB, out);
input [31:0] inA, inB;
output reg [31:0] out;
reg [31:0] sup;

	always @ (inA or inB)
	begin		
		out = (inA << 2) + inB;
	end
endmodule

