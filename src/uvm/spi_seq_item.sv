class spi_seq_item_base extends uvm_sequence_item;
    
    `uvm_object_utils(spi_seq_item_base)
    
    rand logic [7:0] data_i;
    rand logic       miso_i;

         logic       sclk_o;
         logic       cs_o  ;
         logic       mosi_o;


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
        this.data_i = that.data_i;
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
        str = {str, $sformatf("\ndata_i: %8b"   ,     data_i)};

        return str;
    endfunction

endclass