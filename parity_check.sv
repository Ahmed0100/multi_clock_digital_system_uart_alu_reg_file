module parity_check #(parameter WIDTH=9)
(	
    input sampled_bit_in,
	input clk,
	input reset_n,
	input par_type_in,
	input par_chk_en_in,
	output logic par_err_out
);
logic [WIDTH-1:0] register;

always_ff @(posedge clk or negedge reset_n) begin : proc_register
	if(~reset_n) begin
		register <= 0;
	end else begin
		register <= {register,sampled_bit_in};
	end
end
always_comb begin : proc_par_err_out
	par_err_out = 0;
	if(par_chk_en_in)
	begin
		if(!par_type_in)
			if(^register[WIDTH-1:1] == register[0])
				par_err_out = 0;
			else
				par_err_out = 1;
		else if(par_type_in)
			if(~^register[WIDTH-1:1] == register[0])
				par_err_out = 0;
			else
				par_err_out = 1;
		else
			par_err_out = 0;
	end
	else
		par_err_out = 0;
end

endmodule : parity_check