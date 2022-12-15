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
				output reg Jump,	
                output reg [1:0] ALUcntrl,
				output reg Bne,	
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
			Jump = 0;
			Bne = 1'b0;
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
			Jump = 0;
			Bne = 1'b0;
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
			Jump = 0;
			Bne = 1'b0;
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
			Jump = 0;
			Bne = 1'b0;
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
			Jump = 0;
			Bne = 1'b0;
			end
		6'b000010:
			begin 
			RegDst = 0;
            MemRead = 1'b0;
            MemWrite = 1'b0;
            MemToReg = 0;
            ALUSrc = 0;
            RegWrite = 1'b0;
            Branch = 0;
            ALUcntrl = 2'b00; 
			Sllcntrl = 0; //jump
			Jump = 1;
			Bne = 1'b0;
			end
		6'b000101:
			begin
				RegWrite = 1'b0; 
				RegDst = 1'b0; 
				ALUSrc = 1'b1; 
				Branch = 1'b1; 
				MemWrite = 1'b0; 
				MemToReg = 1'b0; 
				ALUcntrl = 2'b01; 
				MemRead = 1'b0; 
				Bne = 1'b1;
				Jump = 0;
				Sllcntrl = 0;
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
			Jump = 0;
			Bne = 1'b0;	
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
                       

/**************** Module for Stall Detection in ID pipe stage goes here  *********/
module hazard_unit(ifid_rs, ifid_rt, idex_memread, idex_rt, PCSrc,pc_write, ifid_write ,bubble_ifid ,bubble_idex, bubble_exmem);
	
	input [4:0] ifid_rs, ifid_rt, idex_rt;
	input idex_memread, PCSrc;
	output reg pc_write, ifid_write, bubble_idex, bubble_exmem, bubble_ifid;
	
	always @(*)
	begin
	if((idex_memread == 1'b1 ) && ((idex_rt == ifid_rs ) || (idex_rt == ifid_rt)))
	begin	
		pc_write = 1'b1;
		ifid_write = 1'b1;
		bubble_idex = 1'b1;
	end	
	else
	begin
		pc_write = 1'b0;
		ifid_write = 1'b0;
		bubble_idex = 1'b0;
	end
	
	if(PCSrc == 1'b1)
	begin 
		bubble_idex = 1'b1;
		bubble_exmem = 1'b1;
		bubble_ifid = 1'b1;
	end
	else
	begin
	    bubble_idex = 1'b0;
		bubble_exmem = 1'b0;
		bubble_ifid = 1'b0;
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
			  6'b100110: ALUOp = 4'b1000;//xor
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
