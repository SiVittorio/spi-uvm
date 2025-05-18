class spi_master_seq_base extends uvm_sequence#(spi_seq_item_base);

    `uvm_object_utils(spi_master_seq_base)


    //   Contains:
    //   typedef spi_seq_item_base REQ;
    //   typedef spi_seq_item_base RSP;
    //   REQ req;
    //   RSP rsp;

    int item_amount = 1;

    function new(string name = "");
        super.new(name);
        configure();
    endfunction

    virtual function void configure();
        void'(uvm_resource_db#(int)::read_by_name(
            get_full_name(), "item_amount", item_amount));
    endfunction

    virtual task body();
        repeat(item_amount) begin
            req = REQ::type_id::create("req");
            start_item(req);
            randomize_req();
            finish_item(req);
        end
    endtask

    virtual function void randomize_req();
        if(!req.randomize()) `uvm_fatal(get_name(),
            $sformatf("Can't randomize %s", get_name()));
    endfunction

endclass