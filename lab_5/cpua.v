/*Creating the connections based on one-cycle mips (datagram, control unit) blueprints*/
module cpua(clock , reset);
	input clock, reset;
	wire[31:0]pc_new, pc_im;
	wire[31:0]instr;
	wire[31:0]wd_alu, rdA_alu, rdB_alu; 
	wire zero;
	wire MemtoReg, MemWrite, Branch, ALUSrc, RegDst, RegWrite,  MemRead, Bne;
	wire[3:0]ALUControl;
	wire [31:0] dout_mux1_1, mux1_out;
	wire [4:0] mux2_out;
	wire[31:0] sign_out;
	wire[31:0] PCBranch_out;
	wire[31:0] mux3_out;
	wire mux3_sel;
	wire[31:0] mux4_out;
	wire andout;
	wire orout;
	
	PC pc(clock, reset, mux3_out, pc_im);
	
	adder add(pc_im, pc_new);
	
	InstructionMemory im(pc_im >> 2, instr, reset);
	
	RegFile rf(clock, reset, instr[25:21], instr[20:16], mux2_out, RegWrite, mux1_out, rdA_alu, rdB_alu);
	
	FSM fsm(instr[5:0], instr[31:26],  MemtoReg, MemWrite, Branch, ALUSrc, RegDst, RegWrite, ALUControl, MemRead, Bne);
	
	ALU alu(wd_alu, zero, rdA_alu, mux4_out, ALUControl);
	
	Memory mem(clock, reset, MemRead, MemWrite, wd_alu, rdB_alu, dout_mux1_1);
	
	mux32 mux1(wd_alu, dout_mux1_1, MemtoReg, mux1_out);
	
	mux5 mux2(instr[20:16], instr[15:11], RegDst, mux2_out);
	
	sign_extension se( instr[15:0], sign_out);
	
	PCBranch pcb(sign_out, pc_new, PCBranch_out);

	assign mux3_sel = zero & Branch; 
	
	mux32 mux3(pc_new,PCBranch_out, orout,mux3_out);
	
	mux32 mux4(rdB_alu, sign_out, ALUSrc, mux4_out);
	
	assign andout = (~zero) & Bne;
	assign orout = andout |  mux3_sel;
	
endmodule
