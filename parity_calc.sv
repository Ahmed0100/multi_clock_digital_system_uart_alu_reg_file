`include "uart_config.sv"

module parity_calc(
	input clk,
	input reset_n,
	input [`WIDTH-1:0] data_in,
	input par_type_in,
	input data_valid_in,
	output logic par_bit_out
);

always_ff @(posedge clk or negedge reset_n) begin : proc_par_bit_out
	if(~reset_n)
	begin
		par_bit_out <= 0;
	end 
	else if(par_type_in == `EVEN_PARITY_CONFIG && data_valid_in)
	begin
		par_bit_out <= ^data_in;
	end
	else if(par_type_in == `ODD_PARITY_CONFIG && data_valid_in)
		par_bit_out <= ~(^data_in);
end
endmodule