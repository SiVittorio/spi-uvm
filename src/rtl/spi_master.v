module spi_master(
    input clk_i,
    input aresetn_i,

    input  start_i,           // do load, read or shift
    input  load_i,            // load_i from data_i to shift_reg

    input  [7:0]  data_i,

    // SPI interface
    input      miso_i,
    output     sclk_o,
    output reg mosi_o,
    output reg cs_o   );


    integer count;

    reg [7:0]shift_reg;
    reg is_in_progress;
    assign sclk_o      = is_in_progress ? clk_i : 1'b1;

    // Internal logic block
    always @(posedge clk_i,negedge aresetn_i)
    begin
        if(!aresetn_i)
        begin
            count          <= 0;
            shift_reg      <= 8'd0;
            is_in_progress <= 1'b0;
        end
        else
        begin
            if(start_i)
            begin
                if(load_i)
                begin
                    shift_reg      <= data_i;
                    count          <= 0;
                    is_in_progress <= 1'b1;
                end
                else if(count < 8)
                begin
                    shift_reg      <= { shift_reg[6:0], miso_i };
                    count          <= count + 1;
                    is_in_progress <= count != 7;
                end
            end
            else
            begin
                is_in_progress <= 1'b0;
                count          <= 0;
            end
        end
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
            if (is_in_progress)
            begin
                cs_o   <= 1'b0;
                mosi_o <= shift_reg[7];
            end
            else
            begin
                cs_o   <= 1'b1;
                mosi_o <= 1'bx;
            end
        end
    end

endmodule
