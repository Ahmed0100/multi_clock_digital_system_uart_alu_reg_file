module sys_control_tx #(parameter WIDTH=8, ADDR=4)
(
    input clk,
    input reset_n,
    input uart_rf_send_in,
    input [WIDTH-1:0] uart_rf_send_data_in,
    input uart_alu_send_in,
    input [2*WIDTH-1:0] uart_alu_send_data_in,
    input uart_tx_busy_in,
    output logic [WIDTH-1:0] uart_tx_data_out,
    output logic uart_tx_data_valid_out
);

localparam [2:0] IDLE=0,
UART_RF_SEND_S = 1,
UART_ALU_0_SEND_S = 2,
WAIT_UART_BUSY= 3,
UART_ALU_1_SEND_S = 4;

logic [2:0] current_state, next_state;

always_ff @(posedge clk or negedge reset_n) begin : proc_current_state
    if(~reset_n) begin
        current_state <= IDLE;
    end else begin
        current_state <= next_state;
    end
end

always_comb begin : proc_next_state
    next_state = current_state;
    case (current_state)
        IDLE:
        begin
            if(uart_rf_send_in)
                next_state = UART_RF_SEND_S;
            else if(uart_alu_send_in)
                next_state = UART_ALU_0_SEND_S;
        end
        
        UART_RF_SEND_S:
        begin
            if(uart_tx_busy_in)
                next_state = IDLE;
        end

        UART_ALU_0_SEND_S: 
        begin
            if(uart_tx_busy_in)
                next_state = WAIT_UART_BUSY;
        end
        
        WAIT_UART_BUSY: 
        begin
            if(!uart_tx_busy_in)
                next_state = UART_ALU_1_SEND_S;
        end
        
        UART_ALU_1_SEND_S: 
        begin
            if(uart_tx_busy_in)
                next_state = IDLE;
        end
        default: next_state = IDLE;
    endcase
end

always_comb begin : proc_outputs
    uart_tx_data_out = 'b0;
    uart_tx_data_valid_out = 0;
    case(current_state)
            IDLE: 
            begin
                uart_tx_data_valid_out = 0;
                uart_tx_data_out = 'b0;
            end
            UART_RF_SEND_S: 
            begin
                uart_tx_data_valid_out = 1'b1;
                uart_tx_data_out = uart_rf_send_data_in;
            end
            UART_ALU_0_SEND_S: 
            begin
                uart_tx_data_out = uart_alu_send_data_in[WIDTH-1:0];
                uart_tx_data_valid_out = 1;
            end
            WAIT_UART_BUSY:
            begin
                uart_tx_data_out = 'b0;
                uart_tx_data_valid_out = 0;
            end
            UART_ALU_1_SEND_S: 
            begin
                uart_tx_data_out = uart_alu_send_data_in[2*WIDTH-1:WIDTH];
                uart_tx_data_valid_out = 1;
            end
    endcase
end
endmodule