//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    13:20:32 11/21/2021 
// Design Name: 
// Module Name:    RGMIIulator_top 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps
module MIIcore_tb;

reg	clk				= 0;
reg	mii_en			= 0;
reg	mii_clk			= 0;
reg	[0:3] mii_d		= 4'b0000;
reg reset;
wire rdy;
wire [7:0]d;

localparam dst = 48'h54_ff_01_21_23_24;
localparam src = 48'h12_34_56_78_9a_bc;
localparam type =16'h1234;
localparam data = "Twas' on the good ship Venus...";
localparam crc = 32'hfb029064; //we can ignore this

integer i, j;
reg [7:0]c;

task verify (input [7:0] [0:16] str, input [7:0] a, input [7:0] b);
	if (a != b) begin
		$display("***fail @ %d: %s   exp: %b, got: %b", $time, str, b, a);
		#500
		$finish;
	end
endtask

initial begin
	$dumpfile("MIIcore.vcd");
	$dumpvars(0, MIIcore_tb);
	#0	reset = 0;
	#5	reset = 1;
	#20	reset = 0;
	#5;
	//start of packet
	mii_en = 1;
	//preamble
	for (i=0; i<7; i=i+1) begin
		mii_d = 4'b1010;
		#40;
		mii_d = 4'b1010;
		#40;
	end
	//start of frame delimeter
	mii_d = 4'b1010;
	#40;
	mii_d = 4'b1011;

	//dst
	#40 mii_d = {dst[40],dst[41],dst[42],dst[43]};
	#40 mii_d = {dst[44],dst[45],dst[46],dst[47]};
	#40 mii_d = {dst[32],dst[33],dst[34],dst[35]};
	#40 mii_d = {dst[36],dst[37],dst[38],dst[39]};
	#40 mii_d = {dst[24],dst[25],dst[26],dst[27]};
	#40 mii_d = {dst[28],dst[29],dst[30],dst[31]};
	#40 mii_d = {dst[16],dst[17],dst[18],dst[19]};
	#40 mii_d = {dst[20],dst[21],dst[22],dst[23]};
	#40 mii_d = {dst[8],dst[9],dst[10],dst[11]};
	#40 mii_d = {dst[12],dst[13],dst[14],dst[15]};
	#40 mii_d = {dst[0],dst[1],dst[2],dst[3]};
	#40 mii_d = {dst[4],dst[5],dst[6],dst[7]};
	//src
	#40 mii_d = {src[40],src[41],src[42],src[43]};
	#40 mii_d = {src[44],src[45],src[46],src[47]};
	#40 mii_d = {src[32],src[33],src[34],src[35]};
	#40 mii_d = {src[36],src[37],src[38],src[39]};
	#40 mii_d = {src[24],src[25],src[26],src[27]};
	#40 mii_d = {src[28],src[29],src[30],src[31]};
	#40 mii_d = {src[16],src[17],src[18],src[19]};
	#40 mii_d = {src[20],src[21],src[22],src[23]};
	#40 mii_d = {src[8],src[9],src[10],src[11]};
	#40 mii_d = {src[12],src[13],src[14],src[15]};
	#40 mii_d = {src[0],src[1],src[2],src[3]};
	#40 mii_d = {src[4],src[5],src[6],src[7]};
	//type
	#40 mii_d = {type[8],type[9],type[10],type[11]};
	#40 mii_d = {type[12],type[13],type[14],type[15]};
	#40 mii_d = {type[0],type[1],type[2],type[3]};
	#40 mii_d = {type[4],type[5],type[6],type[7]};
	//payload
	for (i=0; i<32; i=i+1) begin
		c = data[i];
		#40 mii_d = {c[0],c[1],c[2],c[3]};
		#40 mii_d = {c[4],c[5],c[6],c[7]};
	end
	//crc
	#40 mii_d = {crc[24],crc[25],crc[26],crc[27]};
	#40 mii_d = {crc[28],crc[29],crc[30],crc[31]};
	#40 mii_d = {crc[16],crc[17],crc[18],crc[19]};
	#40 mii_d = {crc[20],crc[21],crc[22],crc[23]};
	#40 mii_d = {crc[8],crc[9],crc[10],crc[11]};
	#40 mii_d = {crc[12],crc[13],crc[14],crc[15]};
	#40 mii_d = {crc[0],crc[1],crc[2],crc[3]};
	#40 mii_d = {crc[4],crc[5],crc[6],crc[7]};
	//end of packet
	mii_en = 0;
	//we're done
	#50000	$finish;
end

initial begin
	$display("begin");
	for (j=0; j<7; j=j+1) begin
		while (!rdy) #1;
		verify("preamble", d, 8'b10101010);
		while (rdy) #1;
	end
	while (!rdy) #1;
	verify("SOF", d, 8'b10111010);
	while (rdy) #1;
	while (!rdy) #1;
	verify("1st octet", d, {dst[44],dst[45],dst[46],dst[47],dst[40],dst[41],dst[42],dst[43]});
	while (rdy) #1;
	while (!rdy) #1;
	verify("2nd octet", d, {dst[36],dst[37],dst[38],dst[39],dst[32],dst[33],dst[34],dst[35]});
	while (rdy) #1;
	while (!rdy) #1;
	verify("3rd octet", d, {dst[28],dst[29],dst[30],dst[31],dst[24],dst[25],dst[26],dst[27]});
	while (rdy) #1;
	while (!rdy) #1;
	verify("4th octet", d, {dst[20],dst[21],dst[22],dst[23],dst[16],dst[17],dst[18],dst[19]});
	while (rdy) #1;
	while (!rdy) #1;
	verify("5th octet", d, {dst[12],dst[13],dst[14],dst[15],dst[8],dst[9],dst[10],dst[11]});
	while (rdy) #1;
	while (!rdy) #1;
	verify("6th octet", d, {dst[4],dst[5],dst[6],dst[7],dst[0],dst[1],dst[2],dst[3]});
	while (rdy) #1;
end

always #10 clk = !clk;
always #20 mii_clk = !mii_clk;


MIIcore UUT (
	.reset(reset),
	.rdy(rdy),
	.d(d),
	.mii_clk(mii_clk),
	.mii_en(mii_en),
	.mii_d(mii_d));

endmodule
