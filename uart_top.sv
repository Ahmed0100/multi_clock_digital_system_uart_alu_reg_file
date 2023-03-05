`include "uart_config.sv"
module uart_top (
    input [`WIDTH-1:0]     data_tx_in,
    input                  data_rx_in,
    input                  data_tx_valid_in,
    input                  clk_rx,
    input                  clk_tx,
    input                  par_en_in,
    input                  reset_n,
    input                  par_type_in,
    input  [4:0]           prescale_in,
    output  logic                    data_tx_valid_out,
    output  logic                    data_rx_valid_out,
    output  logic                    data_tx_out,
    output  logic   [`WIDTH-1:0]     data_rx_out
);

uart_tx uart_tx_inst (
    .data_valid_in(data_tx_valid_in),
    .clk(clk_tx),
    .par_en_in(par_en_in),
    .data_in(data_tx_in),
    .reset_n(reset_n),
    .par_type_in(par_type_in),
    .busy_out(data_tx_valid_out),
    .tx_out(data_tx_out)
);

uart_rx uart_rx_inst (
    .prescale_in(prescale_in),
    .rx_in(data_rx_in),
    .par_en_in(par_en_in),
    .par_type_in(par_type_in),
    .clk(clk_rx),
    .reset_n(reset_n),
    .data_out(data_rx_out),
    .data_valid_out(data_rx_valid_out)
);

endmodule