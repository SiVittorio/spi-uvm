`uvm_analysis_imp_decl(_in)
`uvm_analysis_imp_decl(_out)

class spi_scoreboard_base extends uvm_scoreboard;

    `uvm_component_utils(spi_scoreboard_base)

    uvm_analysis_imp_in#(spi_seq_item_base, spi_scoreboard_base) imp_in;
    uvm_analysis_imp_out#(spi_seq_item_base, spi_scoreboard_base) imp_out;

    int item_amount = 1;

    // spi_cov_wrapper cov_wrapper; // TODO coverage

    mailbox#(spi_seq_item_base) data_in;
    mailbox#(spi_seq_item_base) data_out;


    function new(string name = "", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    // Try `make SIM_OPTS=+UVM_VERBOSITY=UVM_DEBUG`.
    virtual function void write_in(spi_seq_item_base t);
        spi_seq_item_base t_in;
        $cast(t_in, t.clone());
        `uvm_info(get_name(), $sformatf("Got item: %s",
            t_in.convert2string()), UVM_DEBUG);
        void'(data_in.try_put(t_in));
    endfunction 

    virtual function void write_out(spi_seq_item_base t);
        spi_seq_item_base t_out;
        $cast(t_out, t.clone());
        `uvm_info(get_name(), $sformatf("Got item: %s",
            t_out.convert2string()), UVM_DEBUG);
        void'(data_out.try_put(t_out));
    endfunction

    virtual function void build_phase(uvm_phase phase);
        void'(uvm_resource_db#(int)::read_by_name(
            get_full_name(), "item_amount", item_amount));
        imp_in      = new("imp_in",  this);
        imp_out     = new("imp_out", this);
        data_in     = new();
        data_out    = new();
        // cov_wrapper = new(); // TODO coverage
    endfunction

    virtual task reset_phase(uvm_phase phase);
        spi_seq_item_base tmp;
        while(data_in.try_get(tmp)) ;
    endtask

    virtual task main_phase(uvm_phase phase);
        spi_seq_item_base t_in, t_out;
        forever begin
            data_in    .get(t_in);
            // cov_wrapper.sample(t_in, 1); // TODO coverage
            data_out   .get(t_out);
            // cov_wrapper.sample(t_in, 0); //TODO coverage
            do_check(t_in, t_out);
        end
    endtask

    virtual function void do_check(
        spi_seq_item_base t_in,
        spi_seq_item_base t_out
    );
        
    endfunction

endclass