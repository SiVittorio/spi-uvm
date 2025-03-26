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
  
    assign data_o = read_i ? data_out_reg : 8'dx;
  
    assign sclk_o = clk_i;
    
    // Internal logic block
    always @(posedge sclk_o,negedge aresetn_i)
        if(!aresetn_i)
        begin
            shift_reg    <= 8'd0;
        end
        else 
        begin
            if(start_i)
            begin 
                if(load_i)
                begin
                    shift_reg    <= data_i;
                    count        <= 0;
                end
                else if(count < 8)
                begin
                    shift_reg    <= { shift_reg[6:0], miso_i };
                    count        <= count + 1;
                end
            end
            else
                count <= 0;
        end
    
    // SPI-interface logic block
    always @(negedge clk_i)
    begin
        if(!aresetn_i)
        begin
            cs_o   <= 1'b1;
            mosi_o <= 1'bx;
        end
        else
        begin
            if (start_i)
            begin
                cs_o   <= 1'b0;
                mosi_o <= shift_reg[7];
            end
            else
            begin
                cs_o   <= 1'b1;
            end
        end
    end

    always @(read_i)
    begin
        data_out_reg = shift_reg;
    end

endmodule