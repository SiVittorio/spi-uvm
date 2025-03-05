class spi_seq_item_base extends uvm_sequence_item;
    
    `uvm_component_utils(spi_seq_item_base)
    
    // TODO write logic fields here, some fields must be random

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
        // TODO copy data here
    endfunction

    virtual function string convert2string();
        string str;
        // str = {str, $sformatf("\n<some field>: %8h", <some field>)};}
    endfunction

endclass