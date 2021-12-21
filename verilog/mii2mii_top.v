`timescale 1ns / 1ps
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

module mii2mii (
	input		clk,
	input		SW0,
	output 		[7:0] LED,
	// mii in
	input		miiI_clk,
	input		miiI_en,
	input		[3:0] miiI_d,
	// mii out
	input		miiO_clk,
	output reg	miiO_en,
	output reg	[3:0] miiO_d
);

`ifdef __ICARUS__
wire reset = 0;
`endif
reg [3:0] fifo [0:127];
reg [7:0] inptr = 0;
reg [7:0] outptr = 0;

assign reset = ~SW0;
assign LED = {miiO_en};

always @(posedge clk) begin
	if (reset) begin
		inptr <= 0;
		outptr <= 0;
	end else begin
	end
end

always @(posedge miiI_clk) begin
	if (miiI_en) begin
		fifo[inptr] <= miiI_d;
		inptr <= inptr + 1'd1;
	end
end // always

always @(posedge miiO_clk) begin
	if (inptr != outptr) begin
		miiO_d <= fifo[outptr];
		outptr <= outptr + 1'd1;
		miiO_en <= 1'd1;
	end else begin
		miiO_en <= 0;
	end
end // always
endmodule
