module alu #( parameter DATA_IN_WIDTH = 8,
           DATA_OUT_WIDTH = DATA_IN_WIDTH*2
)
(
  input wire [DATA_IN_WIDTH-1:0] data_a_in, 
  input wire [DATA_IN_WIDTH-1:0] data_b_in,
  input wire                  en_in,
  input wire [3:0]            alu_func_in,
  input wire                  clk,
  input wire                  reset_n,  
  output reg [DATA_OUT_WIDTH-1:0]  data_out,
  output reg                  data_valid_out  
);
  
//internal_signals  
reg [DATA_OUT_WIDTH-1:0] alu_out_comp;
reg                 alu_out_comp_valid;
  
  
always @(posedge clk or negedge reset_n)
begin
     if(!reset_n)
     begin
          data_out   <= 'b0 ;
          data_valid_out <= 1'b0 ;	
     end
     else 
     begin  
          data_out   <= alu_out_comp ;
          data_valid_out <= alu_out_comp_valid ;
     end	
end  
  
always @(*)
 begin
   alu_out_comp_valid = 1'b0 ;
   alu_out_comp   = 1'b0 ;
   if(en_in)
    begin
          alu_out_comp_valid = 1'b1;
          case (alu_func_in) 
          4'b0000: begin
               alu_out_comp = data_a_in+data_b_in;
          end
          4'b0001: begin
               alu_out_comp = data_a_in-data_b_in;
          end
          4'b0010: begin
               alu_out_comp = data_a_in*data_b_in;
          end
          4'b0011: begin
               alu_out_comp = data_a_in/data_b_in;
          end
          4'b0100: begin
               alu_out_comp = data_a_in & data_b_in;
          end
          4'b0101: begin
               alu_out_comp = data_a_in | data_b_in;
          end
          4'b0110: begin
               alu_out_comp = ~(data_a_in & data_b_in);
          end
          4'b0111: begin
               alu_out_comp = ~ (data_a_in | data_b_in);
          end     
          4'b1000: begin
               alu_out_comp =  (data_a_in ^ data_b_in);
          end
          4'b1001: begin
               alu_out_comp = ~ (data_a_in ^ data_b_in);
          end           
          4'b1010: begin
          if (data_a_in==data_b_in)
               alu_out_comp = 'b1;
          else
               alu_out_comp = 'b0;
          end
          4'b1011: begin
          if (data_a_in>data_b_in)
               alu_out_comp = 'b10;
          else
               alu_out_comp = 'b0;
          end 
          4'b1100: begin
          if (data_a_in<data_b_in)
               alu_out_comp = 'b11;
          else
               alu_out_comp = 'b0;
          end     
          4'b1101: begin
               alu_out_comp = data_a_in>>1;
          end
          4'b1110: begin 
               alu_out_comp = data_a_in<<1;
          end
          default: begin
               alu_out_comp = 'b0;
          end
          endcase
     end
     else
     begin
          alu_out_comp_valid = 1'b0 ;
     end   
end
endmodule