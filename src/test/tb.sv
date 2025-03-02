module tb;
    import uvm_pkg::*;

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
        .clk_i     ( clk_i          ),
        .aresetn_i ( aresetn_i      ),
        .start_i   ( dut_if.start_i ),
        .load_i    ( dut_if.load_i  ),
        .read_i    ( dut_if.read_i  ),
        .data_i    ( dut_if.data_i  ),
        .data_o    ( dut_if.data_o  ),
        .miso_i    ( dut_if.miso_i  ),
        .sclk_o    ( dut_if.sclk_o  ),
        .mosi_o    ( dut_if.mosi_o  ),
        .cs_o      ( dut_if.cs_o    )
    );


    
    initial begin
        uvm_resource_db#(virtual spi_master_if)::set(
            "uvm_test_top.env.*_agent.*", "vif", intf, null
        );
        run_test();
    end

endmodule