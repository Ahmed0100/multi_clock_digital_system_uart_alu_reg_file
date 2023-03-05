module uart_rx_fsm (
	input clk,    // Clock
	input reset_n,  // Asynchronous reset active low
	input [4:0] edge_cnt_in,
	input [3:0] bit_cnt_in,
	input rx_in,
	input par_en_in,
	input par_err_in,
	input stp_err_in,
	input strt_err_in,
	input [4:0] prescale_in,

	output logic data_sample_en_out,
	output logic deser_en_out,
	output logic data_valid_out,
	output logic stp_chk_en_out,
	output logic strt_chk_en_out,
	output logic par_chk_en_out,
	output logic counter_en_out
);

logic [2:0] current_state,next_state;

localparam [2:0] IDLE=3'b000,
START = 3'b001,
DATA = 3'b011,
DATA_AND_PARITY = 3'b010,
STOP = 3'b110;

always_ff @(posedge clk or negedge reset_n) begin : proc_current_state
	if(~reset_n) begin
		current_state <= IDLE;
	end else begin
		current_state <= next_state;
	end
end

always_comb begin : proc_next_state
	next_state = current_state;
	case(current_state)
		IDLE:
		begin
			if(rx_in == 0)
				next_state = START;
		end
		START: 
		begin
			if(bit_cnt_in == 4'd1 && !strt_err_in && par_en_in)
				next_state = DATA_AND_PARITY;
			else if(bit_cnt_in == 4'd1 && !strt_err_in && !par_en_in)
				next_state = DATA;
		end
		DATA_AND_PARITY:
		begin
			if(bit_cnt_in == 4'd10)
				next_state = STOP;
		end
		DATA:
		begin
			if(bit_cnt_in == 4'd9)
				next_state = STOP;
		end
		STOP:
		begin
			if(edge_cnt_in == (prescale_in-1) && rx_in == 0)
				next_state = START;
			else if(edge_cnt_in == (prescale_in-1) && rx_in == 1)
				next_state = IDLE;
		end
		default: next_state = IDLE;
	endcase // current_state
end

always_comb begin : proc_outputs
	data_sample_en_out = 0;
	deser_en_out = 0;
	data_valid_out = 0;
	stp_chk_en_out = 0;
	strt_chk_en_out = 0;
	par_chk_en_out = 0;
	counter_en_out = 0;

	case(current_state)
		START: 
		begin
			data_sample_en_out = 1'b1;
			counter_en_out = 1;
			if(edge_cnt_in > (prescale_in/2)+2)
				strt_chk_en_out = 1;
		end
		DATA_AND_PARITY:
		begin
			data_sample_en_out = 1;
			counter_en_out = 1;
			if(edge_cnt_in>(prescale_in/2)+2)
				par_chk_en_out = 1;
			if(edge_cnt_in == prescale_in-1 && bit_cnt_in<'d9)
				deser_en_out = 1;
		end
		DATA:
		begin
			data_sample_en_out = 1;
			counter_en_out = 1;
			if(edge_cnt_in == prescale_in-1)
				deser_en_out = 1;
		end
		STOP:
		begin
			data_sample_en_out = 1;
			counter_en_out = 1;
			if(edge_cnt_in == (prescale_in/2)+2)
			begin
				stp_chk_en_out = 1;
				if(!par_err_in && !stp_err_in)
					data_valid_out = 1;
			end
		end
	endcase
end

endmodule : uart_rx_fsm