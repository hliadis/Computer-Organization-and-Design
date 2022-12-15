// Define top-level testbench
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Top level has no inputs or outputs
// It only needs to instantiate CPU, Drive the inputs to CPU (clock, reset)
// and monitor the outputs. This is what all testbenches do


`timescale 1ns/1ps
`define clock_period 5

module cpu_tb;

reg clock, reset;    // Clock and reset signals
reg [4:0] raA, raB, wa;
reg wen;
reg [31:0] wd;
wire [31:0] rdA, rdB;
integer i, j;
wire [31:0]inA, inB;
reg [3:0]op;
wire zero;
wire [31:0]out;


ALU test(out, zero, inA, inB, op);
RegFile regs(clock, reset, raA, raB, wa, wen, wd, rdA , rdB);

initial begin
	#(4.25*(`clock_period));
	op = 4'd0;
		
	for(j = 0 ; j < 13; j = j + 1)
	begin
		#10;
      		op = op + 4'd1;
       			
	end

end

assign inA = rdA;
assign inB = rdB;

// Instantiate regfile module


initial begin  // Ta statements apo ayto to begin mexri to "end" einai seiriaka
      
  // Initialize the module 
   clock = 1'b0;       
   reset = 1'b0;  // Apply reset for a few cycles
   #(4.25*(`clock_period)) reset = 1'b1;
for(i = 0; i < 32 ; i = i + 1)
  $display("Register %d : %x", i, regs.regs[i]); 
   
   // Force initialization of the Register File
   for (i = 0; i < 32; i = i+1)
   begin
      regs.regs[i] = i;   // Note that always R0 = 0 in MIPS
      $display("Register %d : %x", i, regs.regs[i]); 
   end
  // Now apply some inputs. 
  // You can and you should extend this part of the code with extra inputs
raA = 32'h2; raB = 32'h1d; 
#(2*(`clock_period))
$display("rdA  : %x", rdA); 
$display("rdB  : %x", rdB); 
   raA = 32'h1; raB = 32'h13; 
#(2*(`clock_period))  
$display("rdA  : %x", rdA); 
$display("rdB  : %x", rdB); 
   raA = 32'hA; raB = 32'h1F; 
#(2*(`clock_period))
$display("rdA  : %x", rdA); 
$display("rdB  : %x", rdB); 
   wa = 32'h0B; wd = 32'hAA; wen = 1'b1;
#10
 $display("wa reg %x : %x", wa, regs.regs[wa]);
wa = 32'h02; wd = 32'hff; wen = 1'b1;
#10
 $display("wa reg %x: %x", wa, regs.regs[wa]);
end 

// Generate clock by inverting the signal every half of clock period
always 
   #((`clock_period) / 2) clock = ~clock;  
   
endmodule
