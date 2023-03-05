module reset_synchronizer #(parameter NUM_OF_STAGES=3)
(
	input clk,
	input reset_n,
	output logic sync_reset_n_out
);

logic [NUM_OF_STAGES-1:0] ff;

always_ff @(posedge clk or negedge reset_n) begin : proc_sync_reset_n_out
	if(~reset_n) begin
		ff <= '0;
	end else begin
		ff <= {1'h1, ff[NUM_OF_STAGES-1:1]};
	end
end

assign sync_reset_n_out = ff[0];

endmodule : reset_synchronizer