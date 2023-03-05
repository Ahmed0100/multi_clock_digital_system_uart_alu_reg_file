module serializer
(
	input clk,
	input reset_n,
	input [7:0] data_in,
	input ser_en_in,
	input data_valid_in,
	input busy_in,

	output logic ser_done_out,
	output logic data_out
);

logic [2:0] counter;
logic [7:0] int_reg;

always_ff @(posedge clk or negedge reset_n) begin : proc_int_reg
	if(~reset_n) begin
		int_reg <= 0;
	end else if(data_valid_in && !busy_in) begin
		int_reg <= data_in;
	end
	else if(ser_en_in)
		int_reg <= int_reg >> 1;
end

always_ff @(posedge clk or negedge reset_n) begin : proc_counter
	if(~reset_n) begin
		counter <= 0;
	end else if(ser_done_out) begin
		counter <= 0;
	end
	else if(ser_en_in)
		counter <= counter + 1;
end

assign ser_done_out = (counter == 7);
assign ser_data = int_reg[0];

endmodule