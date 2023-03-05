module mux_2_1 
(
	input data_0_in,
	input data_1_in,
	input sel_in,
	output logic data_out
);

assign data_out = (sel_in)? data_1_in: data_0_in;

endmodule : mux_2_1