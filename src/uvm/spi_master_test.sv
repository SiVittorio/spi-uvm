class spi_master_test extends uvm_test;
    `uvm_component_utils (spi_master_test)

    spi_master_env_base env;

    function new(string name = "", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        uvm_resource_db#(int)::set(
           "*", "item_amount", $urandom_range(100, 200), this
        );
        env = spi_master_env_base::type_id::create("env", this);
    endfunction

    virtual task main_phase(uvm_phase phase);
        spi_master_seq_base seq;
        phase.raise_objection(this);

        // Base sequence
        seq = spi_master_seq_base::type_id::create("seq");
        seq.start(env.agent.seqr);

        // I can create a different sequences
        // seq = spi_master_seq_another::type_id::create("seq_another");
        // seq.start(env.agent.seqr);
        
        phase.drop_objection(this);
    endtask
endclass //spi_master_test