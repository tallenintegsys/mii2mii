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
module RGMIIulator_tb;
reg		clk				= 0;
reg		SW0				= 0;
reg		uart_rx_serial;
wire	uart_tx_serial;
wire	[7:0]LED		= 8'b00000000;
reg		miiI_en			= 0;
reg		miiI_clk		= 0;
reg		[0:3] miiI_d	= 4'b0000;
reg		miiO_clk		= 0;
wire	miiO_en;
wire	[0:3] miiO_d;

localparam dst = 48'h54_ff_01_21_23_24;
localparam src = 48'h12_34_56_78_9a_bc;
localparam type =16'h1234;
localparam data = "Twas' on the good ship Venus...";
localparam crc = 32'hfb029064; //we can ignore this

integer i;
reg [7:0]c;
integer step = 0;

task chk (input integer s, input [3:0] value);
	begin
		if (step == s) begin
			if (miiO_d != value) begin
				$display("step: %d got: %b", step, miiO_d);
				$finish;
			end
		end
	end
endtask

initial begin
	$dumpfile("MIIulatorTop.vcd");
	$dumpvars(0, RGMIIulator_tb);
	#0	SW0 = 0; // reset
	#5	SW0 = 1; // reset
	#20	SW0 = 0; // reset
	#5;
	//start of packet
	miiI_en = 1;
	//preamble
	for (i=0; i<7; i=i+1) begin
		$display("i %d", i);
		miiI_d = 4'b1010;
		#40;
		miiI_d = 4'b1010;
		#40;
	end
	//start of frame delimeter
	miiI_d = 4'b1010;
	#40;
	miiI_d = 4'b1011;
	//dst
	#40 miiI_d = {dst[40],dst[41],dst[42],dst[43]};
	#40 miiI_d = {dst[44],dst[45],dst[46],dst[47]};
	#40 miiI_d = {dst[32],dst[33],dst[34],dst[35]};
	#40 miiI_d = {dst[36],dst[37],dst[38],dst[39]};
	#40 miiI_d = {dst[24],dst[25],dst[26],dst[27]};
	#40 miiI_d = {dst[28],dst[29],dst[30],dst[31]};
	#40 miiI_d = {dst[16],dst[17],dst[18],dst[19]};
	#40 miiI_d = {dst[20],dst[21],dst[22],dst[23]};
	#40 miiI_d = {dst[8],dst[9],dst[10],dst[11]};
	#40 miiI_d = {dst[12],dst[13],dst[14],dst[15]};
	#40 miiI_d = {dst[0],dst[1],dst[2],dst[3]};
	#40 miiI_d = {dst[4],dst[5],dst[6],dst[7]};
	//src
	#40 miiI_d = {src[40],src[41],src[42],src[43]};
	#41 miiI_d = {src[44],src[45],src[46],src[47]};
	#40 miiI_d = {src[32],src[33],src[34],src[35]};
	#40 miiI_d = {src[36],src[37],src[38],src[39]};
	#40 miiI_d = {src[24],src[25],src[26],src[27]};
	#40 miiI_d = {src[28],src[29],src[30],src[31]};
	#40 miiI_d = {src[16],src[17],src[18],src[19]};
	#40 miiI_d = {src[20],src[21],src[22],src[23]};
	#40 miiI_d = {src[8],src[9],src[10],src[11]};
	#40 miiI_d = {src[12],src[13],src[14],src[15]};
	#40 miiI_d = {src[0],src[1],src[2],src[3]};
	#40 miiI_d = {src[4],src[5],src[6],src[7]};
	//type
	#40 miiI_d = {type[8],type[9],type[10],type[11]};
	#40 miiI_d = {type[12],type[13],type[14],type[15]};
	#40 miiI_d = {type[0],type[1],type[2],type[3]};
	#40 miiI_d = {type[4],type[5],type[6],type[7]};
	//payload
	for (i=30*8; i; i=i-8) begin
		c = {data[i+7],data[i+6],data[i+5],data[i+4],data[i+3],data[i+2],data[i+1],data[i+0]};
		#40 miiI_d = {c[0],c[1],c[2],c[3]};
		#40 miiI_d = {c[4],c[5],c[6],c[7]};
	end
	//crc
	#40 miiI_d = {crc[24],crc[25],crc[26],crc[27]};
	#40 miiI_d = {crc[28],crc[29],crc[30],crc[31]};
	#40 miiI_d = {crc[16],crc[17],crc[18],crc[19]};
	#40 miiI_d = {crc[20],crc[21],crc[22],crc[23]};
	#40 miiI_d = {crc[8],crc[9],crc[10],crc[11]};
	#40 miiI_d = {crc[12],crc[13],crc[14],crc[15]};
	#40 miiI_d = {crc[0],crc[1],crc[2],crc[3]};
	#40 miiI_d = {crc[4],crc[5],crc[6],crc[7]};
	//end of packet
	miiI_en = 0;
	//we're done
	#5000000	$finish;
end

always #10 clk = !clk;
always #20 miiI_clk = !miiI_clk;
always #22 miiO_clk = !miiO_clk;

always @(posedge miiO_clk) begin
	if (miiO_en) begin
		if (step < 17) begin
			if (miiO_d != 4'b1010) begin
				$display("step: %d got: %b", step, miiO_d);
				$finish;
			end
		end
		//sof
		chk(17, 4'b1011);
		//dst
		chk(18, {dst[40],dst[41],dst[42],dst[43]});
		chk(19, {dst[44],dst[45],dst[46],dst[47]});
		chk(20, {dst[32],dst[33],dst[34],dst[35]});
		chk(21, {dst[36],dst[37],dst[38],dst[39]});
		chk(22, {dst[24],dst[25],dst[26],dst[27]});
		chk(23, {dst[28],dst[29],dst[30],dst[31]});
		chk(24, {dst[16],dst[17],dst[18],dst[19]});
		chk(25, {dst[20],dst[21],dst[22],dst[23]});
		chk(26, {dst[8],dst[9],dst[10],dst[11]});
		chk(27, {dst[12],dst[13],dst[14],dst[15]});
		chk(28, {dst[0],dst[1],dst[2],dst[3]});
		chk(29, {dst[4],dst[5],dst[6],dst[7]});
		//src
		chk(30, {src[40],src[41],src[42],src[43]});
		chk(31, {src[44],src[45],src[46],src[47]});
		chk(32, {src[32],src[33],src[34],src[35]});
		chk(33, {src[36],src[37],src[38],src[39]});
		chk(34, {src[24],src[25],src[26],src[27]});
		chk(35, {src[28],src[29],src[30],src[31]});
		chk(36, {src[16],src[17],src[18],src[19]});
		chk(37, {src[20],src[21],src[22],src[23]});
		chk(38, {src[8],src[9],src[10],src[11]});
		chk(39, {src[12],src[13],src[14],src[15]});
		chk(40, {src[0],src[1],src[2],src[3]});
		chk(41, {src[4],src[5],src[6],src[7]});
		//type
		chk(42, {type[8],type[9],type[10],type[11]});
		chk(43, {type[12],type[13],type[14],type[15]});
		chk(44, {type[0],type[1],type[2],type[3]});
		chk(45, {type[4],type[5],type[6],type[7]});
		//payload
		//good enough already!
	end
	step <= step + 1;
end // always

mii2mii uut(
	.clk(clk),
	.SW0(SW0),
	.LED(LED),

	.miiI_clk(miiI_clk),
	.miiI_en(miiI_en),
	.miiI_d(miiI_d),

	.miiO_clk(miiO_clk),
	.miiO_en(miiO_en),
	.miiO_d(miiO_d)
);
endmodule
