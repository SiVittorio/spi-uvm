class spi_seq_item_base extends uvm_sequence_item;
    
    `uvm_component_utils(spi_seq_item_base)
    
    rand logic [7:0] data_i;
    rand logic       miso_i;

         logic       cs_o  ;
         logic       mosi_o;
         logic [7:0] data_o;


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
        this.cs_o   = that.cs_o  ;
        this.mosi_o = that.mosi_o;
        this.data_o = that.data_o;
    endfunction

    virtual function string convert2string();
        string str;

        str = {str, $sformatf("\ndata_i: %8h", data_i)};
        str = {str, $sformatf("\nmiso_i: %8h", miso_i)};
        str = {str, $sformatf("\ncs_o: %8h",   cs_o)};
        str = {str, $sformatf("\nmosi_o: %8h", mosi_o)};
        str = {str, $sformatf("\ndata_o: %8h", data_o)};

        return str;
    endfunction

endclass