module mux(
	input [1:0] mux_sel_in,
	input data_in,
	input par_bit_in,
	output logic tx_out
);

always_comb begin : proc_tx_out
	case(mux_sel_in)
		0: tx_out = 1'b1;
		1: tx_out = 1'b0;
		2: tx_out = data_in;
		3: tx_out = par_bit_in;
	endcase // mux_sel_in
end
endmodule