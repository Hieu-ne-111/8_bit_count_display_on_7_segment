module part2(CLOCK_50, KEY0, SW, HEX3, HEX2, HEX1, HEX0);
	input wire CLOCK_50;      // Cần xung này để chạy mạch lọc nhiễu phím
	input wire KEY0;          // Nút nhấn làm xung kích đếm (Yêu cầu đề bài)
	input wire [0:0] SW;      // SW[0] dùng làm chân Reset bộ đếm
	output wire [7:0] HEX3, HEX2, HEX1, HEX0; // 4 màn hình LED 7 đoạn
	
	// 1. THANH GHI BỘ ĐẾM 16-BIT
	reg [15:0] count = 16'b0;
	
	//---------------------------------------------------------
	// 2. KHỐI LỌC NHIỄU NÚT NHẤN (DEBOUNCE CIRCUIT)
	// Tránh hiện tượng nhảy số lung tung và lỗi định thời của KEY0
	//---------------------------------------------------------
	reg [19:0] delay_counter = 20'b0; // Bộ chia tần tạo độ trễ khoảng 20ms
	reg clean_clk = 1'b1;
	reg key_reg0, key_reg1;
	
	always @(posedge CLOCK_50) begin
		// Lấy mẫu tín hiệu KEY0 liên tục theo xung 50MHz
		if (delay_counter == 20'd1_000_000) begin // 20ms độ trễ cơ học phím
			delay_counter <= 20'b0;
			clean_clk <= KEY0; // Cập nhật trạng thái phím đã được làm sạch
		end else begin
			delay_counter <= delay_counter + 1'b1;
		end
	end
	
	// Mạch bắt cạnh xuống (negedge) của nút nhấn đã được lọc nhiễu
	always @(posedge CLOCK_50) begin
		key_reg0 <= clean_clk;
		key_reg1 <= key_reg0;
	end
	// Đưa ra 1 xung duy nhất dài đúng 1 chu kỳ khi nhấn nút
	wire count_trigger = (!key_reg0 && key_reg1); 

	//---------------------------------------------------------
	// 3. MẠCH ĐẾM ĐỒNG BỘ 16-BIT (ĐÚNG YÊU CẦU ĐỀ BÀI)
	//---------------------------------------------------------
	always @(posedge CLOCK_50) begin
		if (SW[0]) begin
			count <= 16'b0; // Reset bộ đếm về 0
		end
		else if (count_trigger) begin
			count <= count + 1'b1; // Biểu thức Q <= Q + 1 chuẩn theo đề bài
		end
	end
	
	//---------------------------------------------------------
	// 4. CHUYỂN ĐỔI BINARY 16-BIT SANG BCD (DOUBLE-DABBLE)
	// Vì đếm 16-bit tối đa lên tới 65535 (Cần 5 chữ số BCD)
	//---------------------------------------------------------
	reg [35:0] BCD;
	integer i;
	always @(*) begin
		BCD = {20'b0, count};
		for(i = 0; i < 16; i = i + 1) begin
			if (BCD[19:16] >= 5) BCD[19:16] = BCD[19:16] + 4'd3;
			if (BCD[23:20] >= 5) BCD[23:20] = BCD[23:20] + 4'd3;
			if (BCD[27:24] >= 5) BCD[27:24] = BCD[27:24] + 4'd3;
			if (BCD[31:28] >= 5) BCD[31:28] = BCD[31:28] + 4'd3;
			if (BCD[35:32] >= 5) BCD[35:32] = BCD[35:32] + 4'd3; 
			
			BCD = BCD << 1;
		end
	end
	
	//---------------------------------------------------------
	// 5. GIẢI MÃ LED 7 ĐOẠN (DECODER FUNCTION)
	//---------------------------------------------------------
	function [7:0] binary_to_hex;
		input [3:0] num;
		case(num)
			4'd0: binary_to_hex = 8'b11000000;
			4'd1: binary_to_hex = 8'b11111001;
			4'd2: binary_to_hex = 8'b10100100;
			4'd3: binary_to_hex = 8'b10110000;
			4'd4: binary_to_hex = 8'b10011001;
			4'd5: binary_to_hex = 8'b10010010;
			4'd6: binary_to_hex = 8'b10000010;
			4'd7: binary_to_hex = 8'b11111000;
			4'd8: binary_to_hex = 8'b10000000;
			4'd9: binary_to_hex = 8'b10010000;
			default: binary_to_hex = 8'b11111111;
		endcase
	endfunction
	
	// Hiển thị ra 4 bộ LED HEX3-0 (Từ hàng nghìn đến hàng đơn vị)
	assign HEX0 = binary_to_hex(BCD[19:16]); // Đơn vị
	assign HEX1 = binary_to_hex(BCD[23:20]); // Chục
	assign HEX2 = binary_to_hex(BCD[27:24]); // Trăm
	assign HEX3 = binary_to_hex(BCD[31:28]); // Nghìn

endmodule