module bit_synchronizer #(parameter NUM_OF_STAGE=3, WIDTH=1)
(
	input clk,
	input reset_n,
	input [WIDTH-1:0] async_data_in,
	output logic [WIDTH-1:0] sync_data_out
);

logic [NUM_OF_STAGE-2:0] reg_file [WIDTH-1:0];

integer i;
always_ff @(posedge clk or negedge reset_n) begin : proc_reg
	if(~reset_n) 
	begin
		for(i=0;i<WIDTH;i=i+1)
		begin
			reg_file[i] <= '0;
			sync_data_out <= '0; 
		end
	end else
	begin
		for(i=0;i<WIDTH;i=i+1)
		begin
			{reg_file[i],sync_data_out[i]} <= {async_data_in[i], reg_file[i]};
		end
	end
end
endmodule