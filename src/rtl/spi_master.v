module spi_master(

    // APB interface
    input       pclk_i,
    input       presetn_i,
    input [7:0] paddr_i,
    input       psel_i,
    input       penable_i,
    input       pwrite_i,
    input [7:0] pwdata_i,

    output            pready_o,
    output reg [7:0]  prdata_o,


    // SPI interface
    input      miso_i,
    output     sclk_o,
    output reg mosi_o,
    output reg cs_o   );

    // Internal logic regs
    reg [2:0]   spi_bit_count;
    reg [2:0]   instr_byte_num;
    reg [7:0]   shift_reg;
    reg [2:0]   bytes_reset_count;

    // Common regs with APB access
    reg [7:0] instr;
    reg [7:0] bytes [0:4];
    reg [7:0] bytes_cnt;
    reg [7:0] drive;
    reg [7:0] str;

    // Addresses for common regs
    localparam INSTR_REG_ADDR       = 8'h00;
    localparam BYTES_1_REG_ADDR     = 8'h01;
    localparam BYTES_2_REG_ADDR     = 8'h02;
    localparam BYTES_3_REG_ADDR     = 8'h03;
    localparam BYTES_4_REG_ADDR     = 8'h04;
    localparam BYTES_5_REG_ADDR     = 8'h05;
    localparam BYTES_CNT_REG_ADDR   = 8'h06;
    localparam DRIVE_REG_ADDR       = 8'h07;
    localparam ST_REG_ADDR          = 8'h08;

    assign sclk_o      = &drive && str[0] && instr_byte_num <= bytes_cnt+1 ? pclk_i : 1'b1;
    assign pready_o    = 1;


    // Write APB data logic
    always @(posedge pclk_i,negedge presetn_i)
    begin
        if(!presetn_i)
        begin
            instr     <= 8'h00;
            bytes_cnt <= 8'h00;
            drive     <= 8'h00;
            str       <= 8'h00;
            for (bytes_reset_count=0; bytes_reset_count<5; bytes_reset_count = bytes_reset_count+1) begin
                bytes[bytes_reset_count] <= 8'h00;
            end
        end
        else
        begin
            if (psel_i && penable_i && pwrite_i && pready_o && ~&drive && ~str[0])
            begin
                case(paddr_i)
                    INSTR_REG_ADDR:     instr     <= pwdata_i;
                    BYTES_1_REG_ADDR:   bytes[0]  <= pwdata_i;
                    BYTES_2_REG_ADDR:   bytes[1]  <= pwdata_i;
                    BYTES_3_REG_ADDR:   bytes[2]  <= pwdata_i;
                    BYTES_4_REG_ADDR:   bytes[3]  <= pwdata_i;
                    BYTES_5_REG_ADDR:   bytes[4]  <= pwdata_i;
                    BYTES_CNT_REG_ADDR: bytes_cnt <= pwdata_i < 8'h06 ? pwdata_i : 8'h00;
                    DRIVE_REG_ADDR:     drive     <= pwdata_i;
                endcase
            end
        end
    end

    // Read APB data logic
    always @(posedge pclk_i,negedge presetn_i)
    begin
        if(!presetn_i)
        begin
            prdata_o <= 8'h00;
        end
        else
        begin
            if (psel_i && penable_i && !pwrite_i && pready_o)
            begin
                case(paddr_i)
                    INSTR_REG_ADDR:     prdata_o <= instr    ;
                    BYTES_1_REG_ADDR:   prdata_o <= bytes[0] ;
                    BYTES_2_REG_ADDR:   prdata_o <= bytes[1] ;
                    BYTES_3_REG_ADDR:   prdata_o <= bytes[2] ;
                    BYTES_4_REG_ADDR:   prdata_o <= bytes[3] ;
                    BYTES_5_REG_ADDR:   prdata_o <= bytes[4] ;
                    BYTES_CNT_REG_ADDR: prdata_o <= bytes_cnt;
                    DRIVE_REG_ADDR:     prdata_o <= drive    ;
                    ST_REG_ADDR:        prdata_o <= str      ;
                endcase
            end
        end
    end

    // // APB PREADY logic
    // always @(posedge pclk_i,negedge presetn_i)
    // begin
    //     if(!presetn_i)
    //     begin
    //         pready_o <= 1'b0;
    //     end
    //     else
    //     begin
    //         if (psel_i && penable_i && !pwrite_i && pready_o)
    //         begin
    //             pready_o <= 1'b1;
    //         end
    //         else if (psel_i && penable_i && pwrite_i && pready_o && ~&drive && ~str[0])
    //         begin
    //             pready_o <= 1'b1;
    //         end
    //         else
    //         begin
    //             pready_o <= 1'b0;
    //         end
    //     end
    // end

    always @(posedge pclk_i,negedge presetn_i)
    begin
        if(!presetn_i)
        begin
            shift_reg <= 8'h00;
            instr_byte_num <= 0;
            spi_bit_count <= 0;
            str <= 8'h00;
        end
        else
        begin
            if (&drive)
            begin
                str <= 8'h01;
                if (instr_byte_num === 0)
                begin
                    shift_reg <= instr;
                    instr_byte_num = instr_byte_num + 1;
                end
                else if (instr_byte_num <= bytes_cnt+1)
                begin
                    if (spi_bit_count < 7)
                    begin
                        spi_bit_count <= spi_bit_count + 1;
                        shift_reg <= { shift_reg[6:0], miso_i };
                    end
                    else
                    begin
                        if (instr_byte_num > 1)
                            bytes[instr_byte_num -2] <= { shift_reg[6:0], miso_i };
                        shift_reg <= bytes[instr_byte_num-1];
                        instr_byte_num <= instr_byte_num + 1;
                        spi_bit_count <= 0;
                    end
                end
                else
                begin
                    $display("Bytes:\n1: %b\n2: %b\n3: %b\n4: %b\n5: %b", bytes[0],bytes[1],bytes[2],bytes[3],bytes[4],bytes[5]);
                    str <= 8'h00;
                    instr_byte_num <= 0;
                    drive <= 8'h00;
                end
            end
        end
    end

    // SPI-interface logic block
    always @(negedge pclk_i)
    begin
        if(!presetn_i)
        begin
            cs_o   <= 1'b1;
            mosi_o <= 1'b1;
        end
        else
        begin
            if (&drive && str[0] && instr_byte_num <= bytes_cnt+1)
            begin
                cs_o   <= 1'b0;
                mosi_o <= shift_reg[7];
            end
            else
            begin
                cs_o   <= 1'b1;
                mosi_o <= 1'b1;
            end
        end
    end

endmodule
