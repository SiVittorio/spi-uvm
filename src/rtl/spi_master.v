module spi_master(

    // APB interface
    input       pclk_i,
    input       presetn_i,
    input [7:0] paddr_i,
    input       psel_i,
    input       penable_i,
    input       pwrite_i,
    input [7:0] pwdata_i,

    output      pready_o,
    output      prdata_o,


    // SPI interface
    input      miso_i,
    output     sclk_o,
    output reg mosi_o,
    output reg cs_o   );

    // Internal logic regs
    integer   bytes_reg_num;
    integer   spi_bit_count;
    integer   instr_byte_num;
    reg [7:0] shift_reg;

    // Common regs with APB access
    reg [7:0] instr;
    reg [7:0] bytes [0:4]; //TODO check correct
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

    assign sclk_o      = &drive ? pclk_i : 1'b1;
    assign pready_o    = ~&drive;


    // Write APB data logic
    always @(posedge pclk_i,negedge presetn_i)
    begin
        if(!presetn_i)
        begin
            instr     <= 8'h00;
            bytes_cnt <= 8'h00;
            drive     <= 8'h00;
            str       <= 8'h00;
            for (bytes_reg_num=0; bytes_reg_num<5; bytes_reg_num=bytes_reg_num+1)
                bytes[bytes_reg_num] <= 8'h00;
        end
        else
        begin
            if (psel_i && penable_i && pwrite_i && pready_o)
            begin
                case(paddr_i)
                    INSTR_REG_ADDR:     instr     <= pwdata_i;
                    BYTES_1_REG_ADDR:   bytes[0]  <= pwdata_i;
                    BYTES_2_REG_ADDR:   bytes[1]  <= pwdata_i;
                    BYTES_3_REG_ADDR:   bytes[2]  <= pwdata_i;
                    BYTES_4_REG_ADDR:   bytes[3]  <= pwdata_i;
                    BYTES_5_REG_ADDR:   bytes[4]  <= pwdata_i;
                    BYTES_CNT_REG_ADDR: bytes_cnt <= pwdata_i;
                    DRIVE_REG_ADDR:     drive     <= pwdata_i;
                endcase
            end
        end
    end

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
                if (instr_byte_num < bytes_cnt)
                begin
                    str <= 8'h01;
                    $display("Hi, instr: %d : %b", instr_byte_num - 1, bytes[instr_byte_num-1]);
                    case (instr_byte_num)
                        0: shift_reg <= instr;
                        1: shift_reg <= bytes[instr_byte_num-1];
                        2: shift_reg <= bytes[instr_byte_num-1];
                        3: shift_reg <= bytes[instr_byte_num-1];
                        4: shift_reg <= bytes[instr_byte_num-1];
                        5: shift_reg <= bytes[instr_byte_num-1];
                    endcase

                    if (spi_bit_count < 8)
                    begin
                        spi_bit_count <= spi_bit_count + 1;
                        shift_reg <= { shift_reg[6:0], miso_i };
                    end
                    else
                    begin
                        instr_byte_num <= instr_byte_num + 1;
                        spi_bit_count <= 0;
                    end
                end
                else
                begin
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
            mosi_o <= 1'bx;
        end
        else
        begin
            if (&drive)
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
