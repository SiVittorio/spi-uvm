class spi_seq_item_base extends uvm_sequence_item;
    
    `uvm_object_utils(spi_seq_item_base)
    
    // Data to test
    logic [7:0] instruction [0:4];
    logic [7:0] bytes_cnt;
    rand logic [7:0] miso_all [0:4];

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


    function new(string name = "");
        super.new(name);
    endfunction

    virtual function void do_copy(uvm_object rhs);
        spi_seq_item_base that;
        if( !$cast(that, rhs) ) begin
            `uvm_fatal(get_name(),
                $sformatf("rhs is not 'spi_seq_item_base' type"));
        end
        super.do_copy(that);
        this.instruction = that.instruction;
        this.bytes_cnt = that.bytes_cnt;
        this.miso_all = that.miso_all;

        this.paddr_i = that.paddr_i;
        this.psel_i = that.psel_i;
        this.penable_i = that.penable_i;
        this.pwrite_i = that.pwrite_i;
        this.pwdata_i = that.pwdata_i;
        this.pready_o = that.pready_o;
        this.prdata_o = that.prdata_o;

        this.miso_i = that.miso_i;
        this.sclk_o = that.sclk_o;
        this.cs_o   = that.cs_o  ;
        this.mosi_o = that.mosi_o;
    endfunction

    virtual function string convert2string();
        string str;

        str = {str, $sformatf("\nmiso_i: %7s%1b", " ",miso_i)};
        str = {str, $sformatf("\nmosi_o: %7s%1b", " ",mosi_o)};
        str = {str, $sformatf("\nsclk_o: %7s%1b", " ",sclk_o)};
        str = {str, $sformatf("\ncs_o:   %7s%1b", " ",cs_o  )};
        // str = {str, $sformatf("\ndata_i: %8b"   ,     data_i)};

        return str;
    endfunction

endclass
