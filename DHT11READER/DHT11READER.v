module DHT11READER(
	input  clk,
	input rst_n,
	inout dht11,
	output reg [31:0] data_valid,
	output reg [7:0] LED 
);


reg [7:0] temp_integer = 8'd0;

reg [2:0] cur_state;

reg [2:0] next_state;

reg [4:0] clk_cnt;
reg clk_1m;
reg [20:0] us_cnt;
reg us_cnt_clr;

reg [39:0] data_temp;
reg step;
reg [5:0] data_cnt;

reg dht11_buffer;
reg dht11_d0;
reg dht11_d1;


wire dht11_pos;
 
wire dht11_neg;


assign dht11 = dht11_buffer; 
assign dht11_pos = ~dht11_d1 & dht11_d0;
assign dht11_neg = dht11_d1 & ~dht11_d0;



always @(posedge clk or negedge rst_n) begin

if (!rst_n)

	begin
		clk_cnt <= 5'd0;
		clk_1m <= 1'b0;
	end
	
else if (clk_cnt <5'd24)

	clk_cnt <= clk_cnt + 1'b1;
	
else 

	begin

		clk_cnt <= 5'd0;
		clk_1m <= ~ clk_1m;

	end
	
end


always @(posedge clk_1m or negedge rst_n) begin

	if (!rst_n) 
		begin
			dht11_d0 <= 1'b1;
			dht11_d1 <= 1'b1;
		end
		
	else 
		begin
			dht11_d0 <= dht11;
			dht11_d1 <= dht11_d0;
		end
end

always @(posedge clk_1m or negedge rst_n) begin

	if (!rst_n)
		us_cnt <= 21'd0;
	else if (us_cnt_clr)
		us_cnt <= 21'd0;
	else
		us_cnt <= us_cnt + 1'b1;
end



always @(posedge clk_1m or negedge rst_n) begin

if (!rst_n)
	cur_state <= 3'd0;
else
	cur_state <= next_state;
end



always @(posedge clk_1m or negedge rst_n) begin

if(!rst_n)

	begin
		next_state <= 3'd0;
		data_temp <= 40'd0;
		step <= 1'b0;
		us_cnt_clr <= 1'b0;
		data_cnt <= 6'd0;
		dht11_buffer <= 1'bz;
	end
	
else
	begin
		case (cur_state)
		
		3'd0: 
		begin
		
			if(us_cnt < 1000_000)
			
				begin
					dht11_buffer <= 1'bz;
					us_cnt_clr <= 1'b0;
				end
				
			else
				begin
				
					next_state <= 3'd1;
					us_cnt_clr <= 1'b1;
				end
		end

	3'd1:
	begin
	
		if(us_cnt <20000) 
			begin
			
				dht11_buffer <= 1'b0;
				us_cnt_clr <= 1'b0;
			end
			
		else 
			begin
			dht11_buffer <= 1'bz;
			next_state <= 3'd2;
			us_cnt_clr <= 1'b1;
		end
		
	end


	3'd2:
	begin
		if (us_cnt <20) 
			begin
				us_cnt_clr <= 1'b0;
				if(dht11_neg)
					begin
						next_state <= 3'd3;
						us_cnt_clr <= 1'b1;
					end
			end
			
		else
		
			next_state <= 3'd6;
	end
	

	3'd3:
	begin
	
		if(dht11_pos)
			next_state <= 3'd4;
	end


	3'd4:

	begin

		if(dht11_neg) 
		
			begin
				next_state <= 3'd5;
				us_cnt_clr <= 1'b1;
		end
		
		else 
			begin
				data_cnt <= 6'd0;
				data_temp <= 40'd0;
				step <= 1'b0;
			end
	end
	

	3'd5: 
	
		begin

			case(step)
			
				0: 
					begin
					
						if(dht11_pos) 
							
							begin
								step <= 1'b1;
								us_cnt_clr <= 1'b1;
							end
							
						else
							us_cnt_clr <= 1'b0;
					end
					
				1:
					begin
						if(dht11_neg) 
						
							begin
							
								data_cnt <= data_cnt + 1'b1;

								
								if(us_cnt <60)
								
									data_temp <= {data_temp[38:0],1'b0};
									
								else
								
									data_temp <= {data_temp[38:0],1'b1};
									step <= 1'b0;
									us_cnt_clr <= 1'b1;
							end
							
						else
						
							us_cnt_clr <= 1'b0;
					end
			endcase
			
			if(data_cnt == 40) 
				begin
                next_state <= 3'd6;
					 
					 
					 /*Data format
					 
					 8-digit humidity integer data+
					 8-digit humidity decimal data+
					 8-digit temperature integer data+
					 8-digit temperature decimal data+
					 8bit checksum. 

					 */
					 
                if(data_temp[7:0] == data_temp[39:32] + data_temp[31:24] + data_temp[23:16] + data_temp[15:8])
                    data_valid <= data_temp[39:8];
						  
					
						  LED = data_temp[23:16];

						  
				end
	end 
		
   3'd6:
	
		begin
            if(us_cnt <2000_000)
                us_cnt_clr <= 1'b0;
            else begin
                next_state <= 3'd1;      
                us_cnt_clr <= 1'b1;
            end
        end
        default:;
    endcase
	end 
end		


endmodule