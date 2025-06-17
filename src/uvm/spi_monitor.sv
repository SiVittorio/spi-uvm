virtual class spi_monitor_base extends uvm_monitor;
    
    `uvm_component_utils(spi_monitor_base)

    virtual spi_master_if vif;

    typedef spi_seq_item_base REQ;
    REQ req;

    uvm_analysis_port#(REQ) ap;

    function new(string name = "", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        if(!uvm_resource_db#(virtual spi_master_if)::read_by_name(
            get_full_name(), "vif", vif)) begin
            `uvm_fatal(get_name(), "Can't get spi_if!");
        end
        ap = new("ap", this);
    endfunction

    virtual task reset_phase(uvm_phase phase);
        phase.raise_objection(this);
        vif.wait_for_reset();
        vif.wait_for_unreset();
        phase.drop_objection(this);
    endtask

    virtual task main_phase(uvm_phase phase);
        forever begin
            wait_for_handshake();
            get_data();
        end
    endtask

    pure virtual task wait_for_handshake();

    virtual task get_data();
        req = REQ::type_id::create("req");

        req.instruction = vif.instruction;
        req.bytes_cnt   = vif.bytes_cnt;
        req.is_write    = vif.is_write;
        req.paddr_i     = vif.paddr_i;
        req.psel_i      = vif.psel_i;
        req.penable_i   = vif.penable_i;
        req.pwrite_i    = vif.pwrite_i;
        req.pwdata_i    = vif.pwdata_i;
        req.pready_o    = vif.pready_o;
        req.prdata_o    = vif.prdata_o;

        req.miso_i      = vif.miso_i;
        req.sclk_o      = vif.sclk_o;
        req.cs_o        = vif.cs_o  ;
        req.mosi_o      = vif.mosi_o;
        // `uvm_info(get_name(), $sformatf("Got item: %s", req.convert2string()), UVM_DEBUG);
        ap.write(req);
    endtask
endclass 

class spi_monitor_master extends spi_monitor_base;

    `uvm_component_utils(spi_monitor_master)
    
    function new(string name = "", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual task wait_for_handshake();
        vif.wait_for_posedge(1);
    endtask

endclass
