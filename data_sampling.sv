module data_sampling (
	input clk,    // Clock
	input reset_n,  // Asynchronous reset active low
	input [4:0] prescale_in,
	input [4:0] edge_cnt_in,
	input data_sample_en_in,
	input data_in,

	output logic sampled_bit_out
);

logic [2:0] register;

always_ff @(posedge clk or negedge reset_n) begin : proc_register
	if(~reset_n) begin
		register <= 0;
	end else if(data_sample_en_in) begin
		if(edge_cnt_in == ((prescale_in/2)-1))
			register[0] <= data_in;
		else if(edge_cnt_in == ((prescale_in/2)))
			register[1] <= data_in;
		else if(edge_cnt_in == ((prescale_in/2)+1))
			register[2] <= data_in;
	end
end

assign sampled_bit_out = ((register[2] & (register[1] | register [0])) | (register[0] & register[1]));

endmodule : data_sampling