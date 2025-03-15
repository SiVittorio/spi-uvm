interface spi_master_if(
    input logic clk_i,
    input logic aresetn_i
);


  // DUT interface
  logic        start_i;
  logic        load_i;
  logic        read_i;

  logic [7:0]  data_i;
  logic [7:0]  data_o;

  logic        miso_i;
  logic        sclk_o;
  logic        mosi_o;
  logic        cs_o;

  task wait_for_clks(int num);
      repeat(num) @(posedge clk_i);
  endtask

  task wait_for_reset();
      wait(!aresetn_i);
  endtask

  task wait_for_unreset();
      wait(aresetn_i);
  endtask
    
endinterface //spi_master_if