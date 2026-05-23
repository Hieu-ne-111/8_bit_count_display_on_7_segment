module part1(SW, KEY0, HEX1, HEX2, HEX0);
	input wire [1:0]SW;
	input wire KEY0;
	output wire [7:0] HEX1, HEX2, HEX0;
	
	// Parameter
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
	
	
	
	// Set up
	reg [7:0] count = 8'b00000000;
	wire enable, CLK, rst;
	assign enable = SW[0];
	assign CLK = KEY0;
	assign rst = SW[1];
	
	always @(posedge CLK or posedge rst) begin
		if(rst)
			count = 8'b00000000;
		else begin 
			count[0] <= count[0] ^ enable;
			count[1] <= count[1] ^ count[0] & enable;
			count[2] <= count[2] ^ count[1] & count[0] & enable;
			count[3] <= count[3] ^ count[2] & count[1] & count[0] & enable;
			count[4] <= count[4] ^ count[3] & count[2] & count[1] & count[0] & enable;
			count[5] <= count[5] ^ count[4] & count[3] & count[2] & count[1] & count[0] & enable;
			count[6] <= count[6] ^ count[5] & count[4] & count[3] & count[2] & count[1] & count[0] & enable;
			count[7] <= count[7] ^ count[6] & count[5] & count[4] & count[3] & count[2] & count[1] & count[0] & enable;
		end
	end
	
	// Xu ly BCD
	reg[19:0] BCD;
	integer i;
	always @(*) begin
	BCD = {12'b0, count};
		for(i = 0; i <= 7; i = i+1) begin: change_bit_to_decimal
		if(BCD[19:16] >=5) BCD[19:16] = BCD[19:16] + 4'd3;
		if(BCD[15:12] >=5) BCD[15:12] = BCD[15:12] + 4'd3;
		if(BCD[11:8]  >=5) BCD[11:8]  = BCD[11:8]  + 4'd3;
		BCD = BCD << 1;
	end
	end
	
	function [7:0] binary_to_decimal;
		input [3:0] Selection;
		case(Selection)
		4'd0: binary_to_decimal = _0;
		4'd1: binary_to_decimal = _1;
		4'd2: binary_to_decimal = _2;
		4'd3: binary_to_decimal = _3;
		4'd4: binary_to_decimal = _4;
		4'd5: binary_to_decimal = _5;
		4'd6: binary_to_decimal = _6;
		4'd7: binary_to_decimal = _7;
		4'd8: binary_to_decimal = _8;
		4'd9: binary_to_decimal = _9;
		default: binary_to_decimal = 8'b11111111;
		endcase
	endfunction
	
	assign HEX0 = binary_to_decimal(BCD[11:8]);	// units
	assign HEX1 = binary_to_decimal(BCD[15:12]); // tens
	assign HEX2 = binary_to_decimal(BCD[19:16]); // hunderous

	
endmodule 