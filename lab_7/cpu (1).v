/***********************************************************************************************/
/*********************************  MIPS 5-stage pipeline implementation ***********************/
/***********************************************************************************************/

module cpu(input clock, input reset);
 reg [31:0] PC;
 wire PC_write_wire, IFID_write_wire;  
 reg [31:0] IFID_PCplus4;
 reg [31:0] IFID_instr;
 reg [31:0] IDEX_rdA, IDEX_rdB, IDEX_signExtend, IDEX_PCplus4;
 reg [4:0]  IDEX_instr_rt, IDEX_instr_rs, IDEX_instr_rd,IDEX_instr_shmat;                            
 reg        IDEX_RegDst, IDEX_ALUSrc, IDEX_SllSrc;
 reg [1:0]  IDEX_ALUcntrl;
 reg        IDEX_Branch, IDEX_MemRead, IDEX_MemWrite; 
 reg        IDEX_MemToReg, IDEX_RegWrite, IDEX_Bne;                
 reg [4:0]  EXMEM_RegWriteAddr, EXMEM_instr_rd; 
 reg [31:0] EXMEM_ALUOut, EXMEM_PCBranch;
 reg        EXMEM_Zero, EXMEM_Bne;
 reg [31:0] EXMEM_MemWriteData;
 reg        EXMEM_Branch, EXMEM_MemRead, EXMEM_MemWrite, EXMEM_RegWrite, EXMEM_MemToReg;
 reg [31:0] MEMWB_DMemOut;
 reg [4:0]  MEMWB_RegWriteAddr, MEMWB_instr_rd; 
 reg [31:0] MEMWB_ALUOut;
 reg        MEMWB_MemToReg, MEMWB_RegWrite;               
 wire [31:0] instr, ALUInA, ALUInB, ALUOut, rdA, rdB, signExtend, DMemOut, wRegData;
 wire Zero, RegDst, MemRead, MemWrite, MemToReg, ALUSrc, RegWrite, Branch, SllSrc, Jump;
 wire [5:0] opcode, func;
 wire [4:0] instr_rs, instr_rt, instr_rd, instr_shmat,RegWriteAddr;
 wire [3:0] ALUOp;
 wire [1:0] ALUcntrl;
 wire [15:0] imm;
 wire [1:0] bypassA, bypassB; 
 wire [31:0] forward_b,forward_a;
 wire[31:0] IFID_instr4, PCjump;
 wire bubble_ifid, bubble_idex, bubble_exmem;
 wire  EXMEM_PCSrc;
 wire Bne;
/***************** Instruction Fetch Unit (IF)  ****************/

 always @(posedge clock or negedge reset)
  begin 
    if (reset == 1'b0)     
       PC <= -1;     
    else if (PC == -1)
       PC <= 0;
    else if((1'b1 != PC_write_wire)) 
    begin
	   if((EXMEM_PCSrc != 1'b1) && (Jump != 1'b1))
	   PC <= PC + 4;
	   
	   else if((EXMEM_PCSrc == 1'b1) && (Jump != 1'b1))
	   PC <= EXMEM_PCBranch;
	   
	   else if((Jump == 1'b1) && (EXMEM_PCSrc == 1'b1))
	   PC <= EXMEM_PCBranch;
	   
	   else if((Jump == 1'b1) && (EXMEM_PCSrc != 1'b1))
	   PC <= PCjump;
	   
	end
	   
	   
  end
  assign IFID_instr4 = IFID_instr << 2;
  assign PCjump = {IFID_PCplus4[31:28],IFID_instr4[27:0]} ;
  // IFID pipeline register
 always @(posedge clock or negedge reset)
  begin 
    if (reset == 1'b0)     
      begin
       IFID_PCplus4 <= 32'b0;    
       IFID_instr <= 32'b0;
    end 
	
    else if(1'b1 != IFID_write_wire) 
      begin
	    if((bubble_ifid != 1) && (Jump != 1)) 
        begin
			IFID_PCplus4 <= PC + 32'd4;
			IFID_instr <= instr;
		end
		
		else
		begin	
			IFID_PCplus4 <= 32'b0;    
			IFID_instr <= 32'b0;
		end
    end
	
	
  end
  
// Instruction memory 1KB
Memory cpu_IMem(clock, reset, 1'b1, 1'b0, PC>>2, 32'b0, instr);
  
  
  
  
  
/***************** Instruction Decode Unit (ID)  ****************/
assign opcode = IFID_instr[31:26];
assign func = IFID_instr[5:0];
assign instr_rs = IFID_instr[25:21];
assign instr_rt = IFID_instr[20:16];
assign instr_rd = IFID_instr[15:11];
assign instr_shmat = IFID_instr[10:6];
assign imm = IFID_instr[15:0];
assign signExtend = {{16{imm[15]}}, imm};

// Register file
RegFile cpu_regs(clock, reset, instr_rs, instr_rt, MEMWB_RegWriteAddr, MEMWB_RegWrite, wRegData, rdA, rdB);

  // IDEX pipeline register
 always @(posedge clock or negedge reset)
  begin 
    if (reset == 1'b0)
      begin
       IDEX_rdA <= 32'b0;    
       IDEX_rdB <= 32'b0;
       IDEX_signExtend <= 32'b0;
       IDEX_instr_rd <= 5'b0;
       IDEX_instr_rs <= 5'b0;
       IDEX_instr_rt <= 5'b0;
	   IDEX_instr_shmat <= 5'b0;
       IDEX_RegDst <= 1'b0;
       IDEX_ALUcntrl <= 2'b0;
       IDEX_ALUSrc <= 1'b0;
       IDEX_Branch <= 1'b0;
       IDEX_MemRead <= 1'b0;
       IDEX_MemWrite <= 1'b0;
       IDEX_MemToReg <= 1'b0;                  
       IDEX_RegWrite <= 1'b0;
	   IDEX_SllSrc <= 1'b0;
	   IDEX_Bne <= 1'b0;
	   IDEX_PCplus4 <= 32'b0;
    end 
	
    else if(1'b1 != bubble_idex)
      begin
       IDEX_rdA <= rdA;
       IDEX_rdB <= rdB;
       IDEX_signExtend <= signExtend;
       IDEX_instr_rd <= instr_rd;
       IDEX_instr_rs <= instr_rs;
       IDEX_instr_rt <= instr_rt;
	   IDEX_instr_shmat <= instr_shmat;
       IDEX_RegDst <= RegDst;
       IDEX_ALUcntrl <= ALUcntrl;
       IDEX_ALUSrc <= ALUSrc;
       IDEX_Branch <= Branch;
       IDEX_MemRead <= MemRead;
       IDEX_MemWrite <= MemWrite;
       IDEX_MemToReg <= MemToReg;                  
       IDEX_RegWrite <= RegWrite;
	   IDEX_SllSrc <= SllSrc;
	   IDEX_Bne <= Bne;
	   IDEX_PCplus4 <= IFID_PCplus4;	 
	end
	else if(bubble_idex == 1)
	begin   
	   IDEX_rdA <= 32'b0;    
       IDEX_rdB <= 32'b0;
       IDEX_signExtend <= 32'b0;
       IDEX_instr_rd <= 5'b0;
       IDEX_instr_rs <= 5'b0;
       IDEX_instr_rt <= 5'b0;
	   IDEX_instr_shmat <= 5'b0;
       IDEX_RegDst <= 1'b0;
       IDEX_ALUcntrl <= 2'b0;
       IDEX_ALUSrc <= 1'b0;
       IDEX_Branch <= 1'b0;
       IDEX_MemRead <= 1'b0;
       IDEX_MemWrite <= 1'b0;
       IDEX_MemToReg <= 1'b0;                  
       IDEX_RegWrite <= 1'b0;
	   IDEX_SllSrc <= 1'b0;
	   IDEX_PCplus4 <= 32'b0;
	   IDEX_Bne <= 1'b0;
	end	
  end

// Main Control Unit 
control_main control_main (RegDst,
                  Branch,
                  MemRead,
                  MemWrite,
                  MemToReg,
                  ALUSrc,
                  RegWrite,
				  SllSrc,
				  Jump,
                  ALUcntrl,
				  Bne,
                  opcode, func);
                  
// Instantiation of Control Unit that generates stalls goes here

hazard_unit HazardUnit(instr_rs, instr_rt, IDEX_MemRead, IDEX_instr_rt,EXMEM_PCSrc, PC_write_wire, IFID_write_wire ,bubble_ifid ,bubble_idex, bubble_exmem);


                           
/***************** Execution Unit (EX)  ****************/
/*                 
assign ALUInA = IDEX_rdA;
                 
assign ALUInB = (IDEX_ALUSrc == 1'b0) ? IDEX_rdB : IDEX_signExtend;
*/
//  ALU
ALU  #(32) cpu_alu(ALUOut, Zero, ALUInA, ALUInB, ALUOp);

assign RegWriteAddr = (IDEX_RegDst==1'b0) ? IDEX_instr_rt : IDEX_instr_rd;

 // EXMEM pipeline register
 always @(posedge clock or negedge reset)
  begin 
    if (reset == 1'b0 || bubble_exmem == 1'b1)     
      begin
       EXMEM_ALUOut <= 32'b0;    
       EXMEM_RegWriteAddr <= 5'b0;
       EXMEM_MemWriteData <= 32'b0;
       EXMEM_Zero <= 1'b0;
       EXMEM_Branch <= 1'b0;
       EXMEM_MemRead <= 1'b0;
       EXMEM_MemWrite <= 1'b0;
       EXMEM_MemToReg <= 1'b0;                  
       EXMEM_RegWrite <= 1'b0;
	   EXMEM_PCBranch <= 32'b0;
	   EXMEM_Bne <= 1'b0;	
	  end 
    else 
      begin
       EXMEM_ALUOut <= ALUOut;    
       EXMEM_RegWriteAddr <= RegWriteAddr;
       EXMEM_MemWriteData <= forward_b;
       EXMEM_Zero <= Zero;
       EXMEM_Branch <= IDEX_Branch;
       EXMEM_MemRead <= IDEX_MemRead;
       EXMEM_MemWrite <= IDEX_MemWrite;
       EXMEM_MemToReg <= IDEX_MemToReg;                  
       EXMEM_RegWrite <= IDEX_RegWrite;
	   EXMEM_Bne <= IDEX_Bne;
       EXMEM_PCBranch <= (IDEX_signExtend << 2) + IDEX_PCplus4;
	  end
  end
  
  assign EXMEM_PCSrc = ((EXMEM_Branch & EXMEM_Zero) | (EXMEM_Bne & (~EXMEM_Zero)));
  // ALU control
  control_alu control_alu(ALUOp, IDEX_ALUcntrl, IDEX_signExtend[5:0]);
   assign ALUInA = (IDEX_SllSrc == 1'b0) ? forward_a : IDEX_instr_shmat;
   // Instantiation of control logic for Forwarding goes here
  
control_bypass_ex forward_unit (bypassA, bypassB, IDEX_instr_rs,  IDEX_instr_rt, EXMEM_RegWriteAddr, MEMWB_RegWriteAddr, EXMEM_RegWrite, MEMWB_RegWrite);
 assign forward_a = 
		   (bypassA == 2'b00) ? IDEX_rdA :
		   (bypassA == 2'b01) ? wRegData :
		   (bypassA == 2'b10) ? EXMEM_ALUOut :
		   'bx;
		   
 assign forward_b = 
		   (bypassB == 2'b00) ? IDEX_rdB :
		   (bypassB == 2'b01) ? wRegData :
		   (bypassB == 2'b10) ? EXMEM_ALUOut :
		   'bx; 
		   
 assign ALUInB = (IDEX_ALUSrc == 1'b0) ? forward_b : IDEX_signExtend; 
/***************** Memory Unit (MEM)  ****************/  

// Data memory 1KB
Memory cpu_DMem(clock, reset, EXMEM_MemRead, EXMEM_MemWrite, EXMEM_ALUOut, EXMEM_MemWriteData, DMemOut);

// MEMWB pipeline register
 always @(posedge clock or negedge reset)
  begin 
    if (reset == 1'b0)     
      begin
       MEMWB_DMemOut <= 32'b0;    
       MEMWB_ALUOut <= 32'b0;
       MEMWB_RegWriteAddr <= 5'b0;
       MEMWB_MemToReg <= 1'b0;                  
       MEMWB_RegWrite <= 1'b0;
      end 
    else 
      begin
       MEMWB_DMemOut <= DMemOut;
       MEMWB_ALUOut <= EXMEM_ALUOut;
       MEMWB_RegWriteAddr <= EXMEM_RegWriteAddr;
       MEMWB_MemToReg <= EXMEM_MemToReg;                  
       MEMWB_RegWrite <= EXMEM_RegWrite;
      end
  end

  
  
  

/***************** WriteBack Unit (WB)  ****************/  
assign wRegData = (MEMWB_MemToReg == 1'b0) ? MEMWB_ALUOut : MEMWB_DMemOut;


endmodule
