virtual class spi_driver_base extends uvm_driver#(spi_seq_item_base);
    
    `uvm_component_utils(spi_driver_base)
    
    virtual spi_master_if vif;

    int max_delay = 10;

    function new(string name = "", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        if(!uvm_resource_db#(virtual spi_master_if)::read_by_name(
            get_full_name(), "vif", vif)) begin
            `uvm_fatal(get_name(), "Can't get spi_master_if!");
        end
        void'(uvm_resource_db#(int)::read_by_name(
            get_full_name(), "max_delay", max_delay));
    endfunction

    virtual task reset_phase(uvm_phase phase);
        phase.raise_objection(this);
        vif.wait_for_reset();
        reset();
        vif.wait_for_unreset();
        phase.drop_objection(this);
    endtask

    pure virtual task reset();

endclass

class spi_driver_master extends spi_driver_base;
    
    `uvm_component_utils(spi_driver_master)
    
    function new(string name = "", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    // TODO configure reset for spi
    virtual task reset();
        vif.start_i <= 1'b0;
        vif.load_i  <= 1'b0;
        vif.read_i  <= 1'b0;
    endtask

    virtual task main_phase(uvm_phase phase);
        forever begin
            seq_item_port.get_next_item(req);

            $display("Start set data!");
            set_data();
            $display("End set data!");
            
            vif.wait_for_clks(10);
            unset_data();
            seq_item_port.item_done();
        end
    endtask

    // TODO add set data
    virtual task set_data();
        vif.start_i <= 1'b1;
        vif.load_i  <= 1'b1;
        vif.data_i  <= 8'd170; // 1010_1010
    endtask

    virtual task unset_data();
        reset();
    endtask

endclass