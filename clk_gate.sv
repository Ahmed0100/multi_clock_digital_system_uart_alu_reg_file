module clk_gate(
	input clk_en_in,
	input clk,
	output gated_clk_out
);

reg latch_out;

always @(*)
begin
	if(!clk)
		latch_out = clk_en_in;
end

assign gated_clk_out = clk && latch_out;

endmodule : clk_gate