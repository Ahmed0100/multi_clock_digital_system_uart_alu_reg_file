module reg_file #(parameter WIDTH=8, DEPTH=16, ADDR=4)
(
	input clk,
	input reset_n,
	input wr_en_in,
	input rd_en_in,
	input [ADDR-1:0] addr_in,
	input [WIDTH-1:0] wr_data_in,

	output logic [WIDTH-1:0] rd_data_out,
	output logic rd_data_valid_out,
	output logic [WIDTH-1:0] reg_0_out,
	output logic [WIDTH-1:0] reg_1_out,
	output logic [WIDTH-1:0] reg_2_out,
	output logic [WIDTH-1:0] reg_3_out
);

integer i;
reg [WIDTH-1:0] mem [DEPTH-1:0];

always_ff @(posedge clk or negedge reset_n) begin : proc_mem
	if(~reset_n) 
	begin
		rd_data_out <= 'b0;
		rd_data_valid_out <= 'b0;
		for(i=0;i<DEPTH;i=i+1)
		begin
			if(i==2)
				mem[i] <= 'b001000_01;
			else if(i==3)
				mem[i] <= 'b0000_1000;
			else
				mem[i] <= 'b0;
		end
	end 
	else if(wr_en_in && !rd_en_in)
	begin
		mem[addr_in] <= wr_data_in;		
	end
	else if(rd_en_in && !wr_en_in)
	begin
		rd_data_out <= mem[addr_in];
		rd_data_valid_out <= 1;
	end
	else
	begin
		rd_data_valid_out <= 0;
	end
end

assign reg_0_out = mem[0];
assign reg_1_out = mem[1];
assign reg_2_out = mem[2];
assign reg_3_out = mem[3];

endmodule : reg_file