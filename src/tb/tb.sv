module tb;
    import uvm_pkg::*;
    import spi_dv_pkg::*;
    `include "uvm_macros.svh"

    parameter CLK_PERIOD = 10;
    
    logic clk_i;
    logic aresetn_i;

    // Clk gen
    initial begin
        clk_i <= 0;
        forever begin
            #(CLK_PERIOD/2) clk_i = ~clk_i;
        end
    end

    // Reset gen
    initial begin
        aresetn_i <= 0;
        repeat(10) @(posedge clk_i);
        aresetn_i <= 1;
    end

    // Init dut interface
    spi_master_if dut_if (clk_i, aresetn_i);

    // Init dut
    spi_master    DUT (
        .pclk_i     ( clk_i             ),
        .presetn_i  ( aresetn_i         ),
        .paddr_i    ( dut_if.paddr_i    ),
        .psel_i     ( dut_if.psel_i     ),
        .penable_i  ( dut_if.penable_i  ),
        .pwrite_i   ( dut_if.pwrite_i   ),
        .pwdata_i   ( dut_if.pwdata_i   ),
        .pready_o   ( dut_if.pready_o   ),
        .prdata_o   ( dut_if.prdata_o   ),
        .miso_i     ( dut_if.miso_i     ),
        .sclk_o     ( dut_if.sclk_o     ),
        .mosi_o     ( dut_if.mosi_o     ),
        .cs_o       ( dut_if.cs_o       )
    );



    initial begin
        uvm_resource_db#(virtual spi_master_if)::set(
            "uvm_test_top.env.*_agent.*", "vif", dut_if, null
        );
        run_test();
    end

endmodule
