`include "constants.h"

/************** Main control in ID pipe stage  *************/
module control_main(output reg RegDst,
                output reg Branch,  
                output reg MemRead,
                output reg MemWrite,  
                output reg MemToReg,  
                output reg ALUSrc,  
                output reg RegWrite,
				output reg Sllcntrl,	
                output reg [1:0] ALUcntrl,  
                input [5:0] opcode, input [5:0] func);

  always @(*) 
   begin
     case (opcode)
      `R_FORMAT: 
          begin 
            RegDst = 1'b1;
            MemRead = 1'b0;
            MemWrite = 1'b0;
            MemToReg = 1'b0;
            ALUSrc = 1'b0;
            RegWrite = 1'b1;
            Branch = 1'b0;         
            ALUcntrl  = 2'b10;
			if(func == 6'b000000)
				Sllcntrl = 1;// R 
			else 
				Sllcntrl = 0;
          end
       `LW :   
           begin 
            RegDst = 1'b0;
            MemRead = 1'b1;
            MemWrite = 1'b0;
            MemToReg = 1'b1;
            ALUSrc = 1'b1;
            RegWrite = 1'b1;
            Branch = 1'b0;
            ALUcntrl  = 2'b00; // add
			Sllcntrl = 0;
		   end
        `SW :   
           begin 
            RegDst = 1'b0;
            MemRead = 1'b0;
            MemWrite = 1'b1;
            MemToReg = 1'b0;
            ALUSrc = 1'b1;
            RegWrite = 1'b0;
            Branch = 1'b0;
            ALUcntrl  = 2'b00; // add
			Sllcntrl = 0;
		   end
       `BEQ:  
           begin 
            RegDst = 1'b0;
            MemRead = 1'b0;
            MemWrite = 1'b0;
            MemToReg = 1'b0;
            ALUSrc = 1'b0;
            RegWrite = 1'b0;
            Branch = 1'b1;
            ALUcntrl = 2'b01; // sub
			Sllcntrl = 0;
		   end
		6'b001000:
			begin 
			RegDst = 1'b0;
            MemRead = 1'b0;
            MemWrite = 1'b0;
            MemToReg = 1'b0;
            ALUSrc = 1'b1;
            RegWrite = 1'b1;
            Branch = 1'b0;
            ALUcntrl = 2'b00; 
			Sllcntrl = 0; //andi
			end
       default:
           begin
            RegDst = 1'b0;
            MemRead = 1'b0;
            MemWrite = 1'b0;
            MemToReg = 1'b0;
            ALUSrc = 1'b0;
            RegWrite = 1'b0;
            ALUcntrl = 2'b00;
			Sllcntrl = 0;	
         end
      endcase
    end // always
endmodule


/**************** Module for Bypass Detection in EX pipe stage goes here  *********/
 module  control_bypass_ex(output reg [1:0] bypassA,
                       output reg [1:0] bypassB,
                       input [4:0] idex_rs,
                       input [4:0] idex_rt,
                       input [4:0] exmem_rd,
                       input [4:0] memwb_rd,
                       input       exmem_regwrite,
                       input       memwb_regwrite);
    always @(*)
	begin
	
    if((memwb_regwrite == 1) && (memwb_rd != 0) &&  
	(memwb_rd == idex_rs) && (exmem_rd != idex_rs || (exmem_regwrite == 0)))
		bypassA = 1;
	else if((exmem_regwrite == 1) && (exmem_rd != 0) && (exmem_rd == idex_rs))
		bypassA = 2;
	else 
		bypassA = 0;
		
	if((memwb_regwrite == 1) && (memwb_rd != 0) &&  
	(memwb_rd == idex_rt) && (exmem_rd != idex_rt || (exmem_regwrite == 0)))
		bypassB = 1;
	else if((exmem_regwrite == 1) && (exmem_rd != 0) && (exmem_rd == idex_rt)) 	
		bypassB = 2;
	else
		bypassB = 0;
	end
	
endmodule          
//module forward_unit(IDEX_instr_rt, IDEX_instr_rs, EXMEM_RegWrite, EXMEM_RegWriteAddr, 
//MEMWB_RegWrite, MEMWB_RegWriteAddr, EXMEM_ALUOut, wRegData, IDEX_rdA, IDEX_rdB, alu_inA, alu_inB);

//input [31:0] EXMEM_ALUOut, wRegData, IDEX_rdA, IDEX_rdB;
//input [4:0] IDEX_instr_rt, IDEX_instr_rs, EXMEM_RegWriteAddr,MEMWB_RegWriteAddr;
//input  EXMEM_RegWrite, MEMWB_RegWrite;
//output reg[31:0] alu_inA, alu_inB;
//reg[1:0] ForwardA, ForwardB;

//always @ (*)
//begin
		//ForwardA = 0;
		//ForwardB = 0;
		
	//if((MEMWB_RegWrite == 1) && (MEMWB_RegWriteAddr != 0) &&  
	//(MEMWB_RegWriteAddr == IDEX_instr_rs) && (EXMEM_RegWriteAddr != IDEX_instr_rs || (EXMEM_RegWrite == 0)))
		//ForwardA = 1;
		
	//if((MEMWB_RegWrite == 1) && (MEMWB_RegWriteAddr != 0) &&  
	//(MEMWB_RegWriteAddr == IDEX_instr_rt) && (EXMEM_RegWriteAddr != IDEX_instr_rt || (EXMEM_RegWrite == 0)))
		//ForwardB = 1;

	//if((EXMEM_RegWrite == 1) && (EXMEM_RegWriteAddr != 0) && (EXMEM_RegWriteAddr == IDEX_instr_rs))
		//ForwardA = 2;
		
	//if((EXMEM_RegWrite == 1) && (EXMEM_RegWriteAddr != 0) && (EXMEM_RegWriteAddr == IDEX_instr_rt))
		//ForwardB = 2;

	//case(ForwardA)
		//0: alu_inA = IDEX_rdA;
		//1: alu_inA = wRegData;
		//2: alu_inA = EXMEM_ALUOut;
	//endcase	
	
	//case(ForwardB)
		//0: alu_inB = IDEX_rdB;
		//1: alu_inB = wRegData;
		//2: alu_inB = EXMEM_ALUOut;
	//endcase
//end
//endmodule                       

/**************** Module for Stall Detection in ID pipe stage goes here  *********/
module hazard_unit(ifid_rs, ifid_rt, idex_memread, idex_rt, pc_write, ifid_write , idex_write);
	
	input [4:0] ifid_rs, ifid_rt, idex_rt;
	input idex_memread;
	output reg pc_write, ifid_write, idex_write;
	
	always @(*)
	begin
	if((idex_memread == 1'b1 ) && ((idex_rt == ifid_rs ) || (idex_rt == ifid_rt)))
	begin	
		pc_write = 1'b1;
		ifid_write = 1'b1;
		idex_write = 1'b1;
	end	
	else
	begin
		pc_write = 1'b0;
		ifid_write = 1'b0;
		idex_write = 1'b0;
	end
	end
endmodule	

/************** control for ALU control in EX pipe stage  *************/
module control_alu(output reg [3:0] ALUOp,                  
               input [1:0] ALUcntrl,
               input [5:0] func);

  always @(ALUcntrl or func)  
    begin
      case (ALUcntrl)
        2'b10: 
           begin
             case (func)
              6'b100000: ALUOp  = 4'b0010; // add
              6'b100010: ALUOp = 4'b0110; // sub
              6'b100100: ALUOp = 4'b0000; // and
              6'b100101: ALUOp = 4'b0001; // or
              6'b100111: ALUOp = 4'b1100; // nor
              6'b101010: ALUOp = 4'b0111; // slt
			  6'b000000: ALUOp = 4'b1111;//sll
			  6'b000100: ALUOp = 4'b1111;//sllv 
              default: ALUOp = 4'b0000;       
             endcase 
          end   
        2'b00: 
              ALUOp  = 4'b0010; // add
        2'b01: 
              ALUOp = 4'b0110; // sub
        default:
              ALUOp = 4'b0000;
     endcase
    end
endmodule
