`include "uart_config.sv"

module system_top_tb();

parameter REF_CLK_PER = 20;
parameter UART_RX_CLK_PER = 100;
parameter DATA_WIDTH = 8;
parameter WR_NUM_OF_FRAMES= 3;
parameter RD_NUM_OF_FRAMES = 2;
parameter ALU_WP_NUM_OF_FRAMES = 4;
parameter ALU_NP_NUM_OF_FRAMES = 2;

logic reset_n,ref_clk, uart_clk, uart_rx=1,uart_tx;

logic   [WR_NUM_OF_FRAMES*11-1:0]       wr_cmd     = 'b10_01110111_0_10_00000101_0_10_10101010_0 ;
logic   [RD_NUM_OF_FRAMES*11-1:0]       rd_cmd     = 'b11_00000010_0_10_10111011_0    ;
logic   [ALU_WP_NUM_OF_FRAMES*11-1:0]   alu_wp_cmd = 'b11_00000001_0_10_00000011_0_10_00000101_0_10_11001100_0 ;
logic   [ALU_NP_NUM_OF_FRAMES*11-1:0]   alu_np_cmd = 'b11_00000001_0_10_11011101_0 ;

logic tx_clk_tb;
logic data_stim_en;
logic [5:0] count = 0;
initial
begin
	uart_clk = 0;
	ref_clk = 0;
	tx_clk_tb = 0;
	reset_n = 1;
	#5 reset_n = 0;
	#5 reset_n = 1;
	#20 data_stim_en = 1;
	#400000
	$stop;
end

always_ff @(posedge dut_inst.clk_divider_inst.div_clk_out) begin : proc_uart_rx
	if(data_stim_en && count < 6'd44) begin
		uart_rx = alu_wp_cmd[count];
		count = count + 1;
	end else begin
		uart_rx = 1;
	end
end

always #(REF_CLK_PER/2) ref_clk = ~ref_clk;
always #(UART_RX_CLK_PER/2) uart_clk = ~uart_clk;

system_top dut_inst(
	.ref_clk(ref_clk),
	.uart_clk(uart_clk),
	.reset_n(reset_n),
	.rx_in(uart_rx),
	.tx_out(uart_tx)
);

endmodule : system_top_tb