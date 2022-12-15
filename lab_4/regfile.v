// Register File. Read ports: address raA, data rdA
//                            address raB, data rdB
//                Write port: address wa, data wd, enable wen.
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
		data[wa] <= wd;
end

always @(reset)
begin 
	for( i = 0 ; i < 32; i = i + 1)
		data[i] = 0;
end

endmodule

