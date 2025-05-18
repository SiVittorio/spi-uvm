class spi_master_env_base extends uvm_env;
    `uvm_component_utils(spi_master_env_base)
    
    function new(string name = "", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    spi_agent_base      agent;

    spi_scoreboard_base scb;

    // Configure agents and scoreboard
    virtual function void build_phase(uvm_phase phase);
        uvm_resource_db#(bit)::set(
            {get_full_name(), ".m_agent"}, "is_master", 1, this
        );
        uvm_resource_db#(uvm_active_passive_enum)::set(
            {get_full_name(), ".*_agent"}, "is_active", UVM_ACTIVE, this
        );
        agent = spi_agent_base     ::type_id::create("m_agent", this);
        scb   = spi_scoreboard_base::type_id::create("scb"  , this);
    endfunction

    // Connect monitors with scoreboards
    virtual function void connect_phase(uvm_phase phase);
        agent.mon.ap.connect(scb.imp_data);
    endfunction

endclass