module spi_master(
    input clk_i,
    input aresetn_i,

    input start_i,           // do load, read or shift
    input load_i,            // load_i from data_i    to shift_reg
    input read_i,            // read_i from shift_reg to data_out_reg

    input  [7:0]  data_i,
    output [7:0]  data_o,

    // SPI interface
    input      miso_i,
    output     sclk_o,
    output reg mosi_o,
    output reg cs_o   );



    integer count; 

    reg [7:0]shift_reg;
    reg [7:0]data_out_reg;
  
    assign data_o = read_i ? data_out_reg : 8'h00;
  
    assign sclk_o = clk_i;
  
    always @(posedge sclk_o,negedge aresetn_i)
        if(!aresetn_i)
        begin
            shift_reg    <= 0;
            cs_o         <= 0;
            mosi_o       <= 0;
            data_out_reg <= 0;
        end
        else 
        if(start_i) begin 
            if(load_i) begin
                shift_reg <= data_i;
                count     <= 0;
            end
            else if(read_i)
                data_out_reg <= shift_reg;
            else if(count<8)begin
                shift_reg <= { miso_i, shift_reg[7:1] };
                mosi_o    <= shift_reg[0];
                count     <= count + 1;
            end
        end

endmodule