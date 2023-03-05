module sys_control #(parameter WIDTH=8, ADDR=4)
(
    input clk,
    input reset_n,
    input [WIDTH-1:0] rf_rd_data_in,
    input rf_rd_data_valid_in,
    input [2*WIDTH-1:0] alu_data_in,
    input alu_data_valid_in,
    input [WIDTH-1:0] uart_rx_data_in,
    input uart_rx_data_valid_in,
    input uart_tx_busy_in,

    output rf_wr_en_out,
    output rf_rd_en_out,
    output [ADDR-1:0] rf_addr_out,
    output [WIDTH-1:0] rf_wr_data_out,
    output alu_en_out,
    output [3:0] alu_fun_out,
    output clk_gate_en_out,
    output clk_div_en_out,
    output uart_tx_data_valid_out,
    output [WIDTH-1:0] uart_tx_data_out
);

logic [2*WIDTH-1:0] uart_alu_send_data;
logic [WIDTH-1:0] uart_rf_send_data;


sys_control_rx sys_control_rx_inst
(
    .clk(clk),
    .reset_n(reset_n),
    .uart_rx_data_in(uart_rx_data_in),
    .uart_rx_data_valid_in(uart_rx_data_valid_in),
    .rf_rd_data_in(rf_rd_data_in),
    .rf_rd_data_valid_in(rf_rd_data_valid_in),
    .alu_data_in(alu_data_in),
    .alu_data_valid_in(alu_data_valid_in),

    .alu_en_out(alu_en_out),
    .alu_fun_out(alu_fun_out),

    .clk_gate_en_out(clk_gate_en_out),
    .clk_div_en_out(clk_div_en_out),

    .rf_wr_en_out(rf_wr_en_out),
    .rf_rd_en_out(rf_rd_en_out),
    .rf_addr_out(rf_addr_out),
    .rf_wr_data_out(rf_wr_data_out),

    .uart_rf_send_out(uart_rf_send),
    .uart_alu_send_out(uart_alu_send),
    .uart_rf_send_data_out(uart_rf_send_data),
    .uart_alu_send_data_out(uart_alu_send_data)
);

sys_control_tx sys_control_tx_inst
(
    .clk(clk),
    .reset_n(reset_n),
    .uart_rf_send_in(uart_rf_send),
    .uart_rf_send_data_in(uart_rf_send_data),
    .uart_alu_send_in(uart_alu_send),
    .uart_alu_send_data_in(uart_alu_send_data),
    .uart_tx_busy_in(uart_tx_busy_in),

    .uart_tx_data_out(uart_tx_data_out),
    .uart_tx_data_valid_out(uart_tx_data_valid_out)
);

endmodule