module part3(CLK_50, HEX0, KEY0);
	input wire CLK_50;
	output wire [7:0] HEX0;
	input wire KEY0;
	
	// Cấu hình LED 7 đoạn (Active Low)
	localparam [7:0] _0 = 8'b11000000;
	localparam [7:0] _1 = 8'b11111001;
	localparam [7:0] _2 = 8'b10100100;
	localparam [7:0] _3 = 8'b10110000;
	localparam [7:0] _4 = 8'b10011001;
	localparam [7:0] _5 = 8'b10010010;
	localparam [7:0] _6 = 8'b10000010;
	localparam [7:0] _7 = 8'b11111000;
	localparam [7:0] _8 = 8'b10000000;
	localparam [7:0] _9 = 8'b10010000;
	
	function [7:0] BCD;
		input [3:0] Sel;
		case(Sel)
			4'd0: BCD = _0;
			4'd1: BCD = _1;
			4'd2: BCD = _2;
			4'd3: BCD = _3;
			4'd4: BCD = _4;
			4'd5: BCD = _5;
			4'd6: BCD = _6;
			4'd7: BCD = _7;
			4'd8: BCD = _8;
			4'd9: BCD = _9;
			default: BCD = 8'b11111111;
		endcase
	endfunction
	

	reg [25:0] delay_count = 26'b0;
	reg latch = 1'b0;
	always @(posedge CLK_50) begin
		if(delay_count >= 49999998) begin
			delay_count <= 0;
			latch<= 1'b1;
		end else begin
			latch <= 1'b0;
			delay_count <= delay_count+1;
		end
	end
	
	reg [7:0] X;
	reg [3:0] count = 4'b0;
	always @(posedge CLK_50 or negedge KEY0) begin
		if(!KEY0) begin 
			X <= 8'b11111111;
			count <= 4'd0;
		end else begin
			if(latch)	begin  count <= count +1;  end
			if(count >= 10)  count <= 4'd0;	
			if(delay_count >= 25000000) X = BCD(count);
			else X = 8'b11111111;
		end

	end
	assign HEX0 = X;
	
endmodule