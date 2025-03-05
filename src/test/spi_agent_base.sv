class spi_agent_base extends uvm_agent;
    
    `uvm_component_utils(spi_agent_base)
    
    // Driver, monitor, sequencer
    spi_driver_base  drv;
    spi_monitor_base mon;
    spi_seqr_base seqr;

    bit is_master = 0;

    function new(string name = "", uvm_component parent = null)
        super.new(name, parent);
    endfunction

    // Load active and master values from database.
    // Create components
    virtual function void build_phase(uvm_phase phase);
        if(!uvm_resource_db#(uvm_active_passive_enum)::read_by_name(
            get_full_name(), "is_active", is_active)) 
            begin
                `uvm_fatal(get_name(), "Can't get is_active!");
            end
        if(!uvm_resource_db#(bit)::read_by_name(
            get_full_name(), "is_master", is_master)) 
            begin
                `uvm_fatal(get_name(), "Can't get is_master!");
            end
        create_components();
    endfunction

    // Create components, is_master flag affects on driver and monitor type
    virtual function void create_components();
        if( get_is_active() ) begin
            if( is_master ) drv = spi_driver_master::type_id::create("m_drv", this);
            else drv = spi_driver_slave::type_id::create("s_drv", this);
            seqr = spi_seqr_base::type_id::create("seqr", this);  
        end
        if( is_master ) mon = spi_monitor_master::type_id::create("m_mon", this);
        else mon = spi_monitor_slave::type_id::create("s_mon", this);
    endfunction

    // Connect sequencer if agent is active
    virtual function void connect_phase(uvm_phase phase);
        if( get_is_active() )
            drv.seq_item_port.connect(seqr.seq_item_export);
    endfunction

endclass