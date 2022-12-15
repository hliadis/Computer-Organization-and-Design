module ALU(out, zero, inA, inB,op);
	input [31:0] inA, inB;
	input [3:0] op;
	
	output zero;
	output reg [31:0] out;
	
	assign zero = (out == 0);
	
	always @(*)
	begin
	case(op)
		0: out <= inA & inB;
		1: out <= inA | inB;
		2: out <= inA + inB;
		6: out <= inA - inB;
		7: out <= (inA < inB)? 1 : 0;
		12: out <= ~(inA | inB);
		default out <= 0 ;
	endcase
	end
	
endmodule
	
