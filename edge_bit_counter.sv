module edge_bit_counter (
	input clk,    // Clock
	input reset_n,  // Asynchronous reset active low
	input [4:0] prescale_in,
	input data_valid_in,
	input en_counter_in,

	output logic [3:0] bit_cnt_out,
	output logic [4:0] edge_cnt_out
);

always_ff @(posedge clk or negedge reset_n) begin : proc_cnt
	if(~reset_n) begin
		bit_cnt_out <= 0;
		edge_cnt_out <= 0;
	end 
	else if(data_valid_in) 
	begin
		bit_cnt_out <= 0;
		edge_cnt_out <= 0;
	end
	else if(en_counter_in)
	begin
		edge_cnt_out <= edge_cnt_out + 1;
		if(edge_cnt_out == prescale_in -1)
		begin
			edge_cnt_out <= 'b0;
			bit_cnt_out <= bit_cnt_out + 1;
		end
	end
end

endmodule : edge_bit_counter