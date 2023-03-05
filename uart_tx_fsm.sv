`include "uart_config.sv"

module uart_tx_fsm
(
	input clk,
	input reset_n,
	input data_valid_in,
	input par_en_in,
	input ser_done_in,

	output logic ser_en_out,
	output logic busy_out,
	output logic [1:0] mux_sel_out
);

localparam IDLE =3'd0,
	START=3'd1,
	DATA=3'd2,
	PARITY=3'd3,
	STOP=3'd4;

logic [2:0] next_state, current_state;

always_ff @(posedge clk or negedge reset_n) begin : proc_current_state
	if(~reset_n) begin
		current_state <= IDLE;
	end else begin
		current_state <= next_state;
	end
end

always_comb begin : proc_next_state
	case(current_state)
		IDLE:
		begin
			if(data_valid_in)
				next_state = START;
			else
				next_state = IDLE;
		end
		START:
		begin
			next_state = DATA;
		end
		DATA:
		begin
			if(!ser_done_in)
				next_state = DATA;
			else if(par_en_in)
				next_state = PARITY;
			else
				next_state = STOP;
		end
		PARITY:
		begin
			next_state = STOP;
		end
		STOP:
		begin
			if(data_valid_in)
				next_state = START;
			else
				next_state= IDLE;
		end
		default: next_state = IDLE;
	endcase // current_state
end

assign ser_en_out = current_state == DATA;

always_comb begin : proc_mux_sel_out
	case(current_state)
		IDLE: mux_sel_out = 0;
		START: mux_sel_out = 1;
		DATA: mux_sel_out = 2;
		PARITY: mux_sel_out = 3;
		default: mux_sel_out = 0;
	endcase
end

always_ff @(posedge clk or negedge reset_n) begin : proc_busy_out
	if(~reset_n) begin
		busy_out <= 0;
	end else if(current_state == IDLE && next_state == START) begin
		busy_out <= 1;
	end
	else if(current_state == STOP && next_state == IDLE) begin
		busy_out <= 0;
	end
end

endmodule : uart_tx_fsm