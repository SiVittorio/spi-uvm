interface spi_master_if(
    input logic clk_i,
    input logic aresetn_i
);

    // APB signals to DUT
    logic [7:0] paddr_i;
    logic       psel_i;
    logic       penable_i;
    logic       pwrite_i;
    logic [7:0] pwdata_i;

    logic       pready_o;
    logic       prdata_o;

    // Data from DUT
    logic       miso_i;
    logic       sclk_o;
    logic       mosi_o;
    logic       cs_o;

  task wait_for_posedge(int num);
      repeat(num) @(posedge clk_i);
  endtask

  task wait_for_negedge(int num);
      repeat(num) @(negedge clk_i);
  endtask

  task wait_for_reset();
      wait(!aresetn_i);
  endtask

  task wait_for_unreset();
      wait(aresetn_i);
  endtask
    
endinterface //spi_master_if
