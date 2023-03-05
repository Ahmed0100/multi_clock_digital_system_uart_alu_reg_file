`include "uart_config.sv"
module uart_rx
(
    input   wire    [4:0]           prescale_in,
    input   wire                    rx_in,
    input   wire                    par_en_in,
    input   wire                    par_type_in,
    input   wire                    clk,
    input   wire                    reset_n,
    output  wire     [`WIDTH-1:0]   data_out,
    output  wire                    data_valid_out
);

wire    [4:0]    edge_cnt;
wire    [3:0]    bit_count;
        
wire    par_err,
        strt_err,
        stp_err,
        data_sample_en,
        deser_en,
        stp_chk_en,
        strt_chk_en,
        par_chk_en,
        counter_en,
        sampled_bit;

uart_rx_fsm uart_rx_fsm_inst(
    .edge_cnt_in(edge_cnt),
    .bit_cnt_in(bit_count),
    .rx_in(rx_in),
    .par_en_in(par_en_in),
    .par_err_in(par_err),
    .strt_err_in(strt_err),
    .stp_err_in(stp_err),
    .prescale_in(prescale_in),
    .clk(clk),
    .reset_n(reset_n),

    .data_sample_en_out(data_sample_en),
    .deser_en_out(deser_en),
    .data_valid_out(data_valid_out),
    .stp_chk_en_out(stp_chk_en),
    .strt_chk_en_out(strt_chk_en),
    .par_chk_en_out(par_chk_en),
    .counter_en_out(counter_en)
);

data_sampling data_sampling_inst(
    .data_in(rx_in),
    .prescale_in(prescale_in),
    .edge_cnt_in(edge_cnt),
    .data_sample_en_in(data_sample_en),
    .clk(clk),
    .reset_n(reset_n),
    .sampled_bit_out(sampled_bit)
);

edge_bit_counter edge_bit_counter_inst(
    .prescale_in(prescale_in),
    .en_counter_in(counter_en),
    .data_valid_in(data_valid_out),

    .clk(clk),
    .reset_n(reset_n),
    .bit_cnt_out(bit_count),
    .edge_cnt_out(edge_cnt)
);

deserializer deserializer_inst(
    .sampled_bit_in(sampled_bit),
    .data_valid_in(data_valid_out),
    .des_en_in(deser_en),
    .clk(clk),
    .reset_n(reset_n),
    .data_out(data_out)
);

parity_check parity_check_inst(
    .sampled_bit_in(sampled_bit),
    .par_type_in(par_type_in),
    .clk(clk),
    .reset_n(reset_n),
    .par_chk_en_in(par_chk_en),

    .par_err_out(par_err)
);

strt_check strt_check_inst(
    .sampled_bit_in(sampled_bit),
    .strt_chk_en_in(strt_chk_en),
    .strt_err_out(strt_err)
);

stp_check stop_check_inst
(   
    .sampled_bit_in(sampled_bit),
    .stp_chk_en_in(stp_chk_en),
    .stp_err_out(stp_err)
);   

endmodule