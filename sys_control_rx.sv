module sys_control_rx #(parameter WIDTH=8, ADDR=4)
(
    input clk,
    input reset_n,
    input [WIDTH-1:0] uart_rx_data_in,
    input uart_rx_data_valid_in,
    input [WIDTH-1:0] rf_rd_data_in,
    input rf_rd_data_valid_in,
    input [WIDTH*2-1:0] alu_data_in,
    input alu_data_valid_in,

    output logic alu_en_out,
    output logic [3:0] alu_fun_out,

    output logic clk_gate_en_out,
    output logic clk_div_en_out,

    output logic rf_wr_en_out,
    output logic rf_rd_en_out,
    output logic [ADDR-1:0] rf_addr_out,
    output logic [WIDTH-1:0] rf_wr_data_out,

    output logic uart_rf_send_out,
    output logic uart_alu_send_out,
    output logic [WIDTH-1:0] uart_rf_send_data_out,
    output logic [WIDTH*2-1:0] uart_alu_send_data_out
);

localparam [3:0] IDLE = 4'd0,
WRITE_CMD_S = 4'd1,
WRITE_ADDR_S = 4'd2,
WRITE_DATA_S = 4'd3,
READ_CMD_S = 4'd4,
READ_ADDR_S = 4'd5,
READ_WAIT_S = 4'd6,
ALU_WP_OPA_S = 4'd7,
ALU_WP_OPB_S = 4'd8,
ALU_OP_FUN_S = 4'd9,
ALU_WAIT_O_S = 4'd10;

localparam [7:0] RF_WRITE_CMD= 8'haa,
RF_READ_CMD = 8'hbb, 
ALU_W_OP_CMD= 8'hcc,
ALU_WN_OP_CMD = 8'hdd;

logic [3:0] current_state, next_state;

logic [7:0] rf_addr_reg;
logic rf_addr_en, rf_rd_store, alu_data_store;

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
            if(uart_rx_data_valid_in)
            begin
                case(uart_rx_data_in)
                    RF_WRITE_CMD:
                        next_state = WRITE_ADDR_S;
                    RF_READ_CMD:
                        next_state = READ_ADDR_S;
                    ALU_W_OP_CMD:
                        next_state = ALU_WP_OPA_S;
                    ALU_WN_OP_CMD:
                        next_state = ALU_OP_FUN_S;
                    default:
                        next_state = IDLE;
                endcase
            end
            else
                next_state = IDLE;
        end
        WRITE_ADDR_S: 
        begin
            if(uart_rx_data_valid_in)
            begin
                next_state = WRITE_DATA_S;
            end
            else
                next_state = WRITE_ADDR_S;
        end
        WRITE_DATA_S: 
        begin
            if(uart_rx_data_valid_in)
                next_state = IDLE;
            else
                next_state = WRITE_DATA_S;
        end
        READ_ADDR_S: 
        begin
            if(uart_rx_data_valid_in)
                next_state = READ_WAIT_S;
            else
                next_state = READ_ADDR_S;
        end
        READ_WAIT_S:
        begin
            if(rf_rd_data_valid_in)
                next_state = IDLE;
            else
                next_state = READ_WAIT_S;
        end

        ALU_WP_OPA_S: 
        begin
            if(uart_rx_data_valid_in)
                next_state = ALU_WP_OPB_S;
            else
                next_state = ALU_WP_OPA_S;
        end

        ALU_WP_OPB_S:
        begin
            if(uart_rx_data_valid_in)
                next_state = ALU_OP_FUN_S;
            else
                next_state = ALU_WP_OPB_S;
        end

        ALU_OP_FUN_S: 
        begin
            if(uart_rx_data_valid_in)
                next_state = ALU_WAIT_O_S;
            else
                next_state = ALU_OP_FUN_S;
        end

        ALU_WAIT_O_S: 
        begin
            if(alu_data_valid_in)
                next_state = IDLE;
            else
                next_state = ALU_WAIT_O_S;
        end
        default:
            next_state = IDLE;
    endcase // current_state
end

always_comb begin : proc_outputs
    alu_en_out = 0;
    alu_fun_out = 0;
    clk_gate_en_out = 0;
    clk_div_en_out = 1;
    rf_wr_en_out = 0;
    rf_rd_en_out = 0;
    rf_addr_out = 0;
    rf_addr_en = 0;
    uart_rf_send_out = 0;
    uart_alu_send_out = 0;
    rf_rd_store = 0;
    alu_data_store = 0;

    case(current_state)
        IDLE:
        begin
        end
        WRITE_ADDR_S: 
        begin
            if(uart_rx_data_valid_in)
                rf_addr_en = '1;
            else
                rf_addr_en = '0;
        end
        WRITE_DATA_S: 
        begin
            if(uart_rx_data_valid_in)
            begin
                rf_wr_en_out = 1;
                rf_addr_out = rf_addr_reg;
                rf_wr_data_out = uart_rx_data_in;
            end
            else
            begin
                rf_wr_en_out = 0;
                rf_addr_out = rf_addr_reg;
                rf_wr_data_out = uart_rx_data_in;               
            end
        end
        READ_ADDR_S:
        begin
            if(uart_rx_data_valid_in)
            begin
                rf_addr_en = 1;
            end
            else
                rf_addr_en = 0;
        end
        READ_WAIT_S: 
        begin
            rf_rd_en_out = 1;
            rf_addr_out = rf_addr_reg;

            if(rf_rd_data_valid_in)
            begin
                uart_rf_send_out = 1;
                rf_rd_store = 1;
            end
            else
            begin
                uart_rf_send_out = 0;
                rf_rd_store = 0;
            end
        end
        ALU_WP_OPA_S: 
        begin
            if(uart_rx_data_valid_in)
            begin
                rf_wr_en_out = 1;
                rf_wr_data_out = uart_rx_data_in;
                rf_addr_out = 'b00;
            end
            else
            begin
                rf_wr_en_out = 'b0;
                rf_wr_data_out = uart_rx_data_in;
                rf_addr_out = 'b00;
            end 
        end
        ALU_WP_OPB_S: 
        begin
            if(uart_rx_data_valid_in)
            begin
                rf_wr_en_out = 1;
                rf_wr_data_out = uart_rx_data_in;
                rf_addr_out = 'b01;
            end
            else
            begin
                rf_wr_en_out = 'b0;
                rf_wr_data_out = uart_rx_data_in;
                rf_addr_out = 'b01;
            end 
        end
        ALU_OP_FUN_S: 
        begin
            clk_gate_en_out = 1;
            if (uart_rx_data_valid_in)
            begin
                alu_en_out = 1;
                alu_fun_out = uart_rx_data_in;
            end
            else
            begin
                alu_en_out = 0;
                alu_fun_out = uart_rx_data_in;
            end
        end
        ALU_WAIT_O_S: 
        begin
            clk_gate_en_out = 1;
            if(alu_data_valid_in)
            begin
                uart_alu_send_out = 1;
                alu_data_store = 'b1;
            end
            else
            begin
                uart_alu_send_out = 0;
                alu_data_store = 'b0;
            end
        end
    endcase
end

always_ff @(posedge clk or negedge reset_n) begin : proc_rf_addr
    if(~reset_n) begin
        rf_addr_reg <= 'b0;
    end else if(rf_addr_en) begin
        rf_addr_reg <= uart_rx_data_in;
    end
end

always_ff @(posedge clk or negedge reset_n) begin : proc_rf_rd_store
    if(~reset_n) begin
        uart_rf_send_data_out <= 'b0;
    end else if(rf_rd_store) begin
        uart_rf_send_data_out <= rf_rd_data_in;
    end
end

always_ff @(posedge clk or negedge reset_n) begin : proc_alu_rd_store
    if(~reset_n) begin
        uart_alu_send_data_out <= 'b0;
    end else if(alu_data_store) begin
        uart_alu_send_data_out <= alu_data_in;
    end
end

endmodule