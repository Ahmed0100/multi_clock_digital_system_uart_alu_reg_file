`include "uart_config.sv"

module deserializer (
	input clk,    // Clock
	input reset_n,  // Asynchronous reset active low
	input des_en_in,
	input data_valid_in,
	input sampled_bit_in,

	output logic [`WIDTH-1:0] data_out
);

logic [`WIDTH-1:0] register;

always_ff @(posedge clk or negedge reset_n) begin : proc_register
	if(~reset_n) begin
		register <= 0;
	end 
	else if(des_en_in) 
	begin
		register <= {sampled_bit_in,register[`WIDTH-1:1]};
	end
end

assign data_out = (data_valid_in)? register : 'b0;

endmodule : deserializer