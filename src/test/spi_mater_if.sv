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
    
endinterface //spi_master_if