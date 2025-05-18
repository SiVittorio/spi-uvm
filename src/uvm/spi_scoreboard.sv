`uvm_analysis_imp_decl(_data)

class spi_scoreboard_base extends uvm_scoreboard;

    `uvm_component_utils(spi_scoreboard_base)

    uvm_analysis_imp_data#(spi_seq_item_base, spi_scoreboard_base) imp_data;

    int item_amount = 1;

    // spi_cov_wrapper cov_wrapper; // TODO coverage

    mailbox#(spi_seq_item_base) data;

    // Vars for check
    logic [7:0] data_rx      = 8'hxx;
    logic       is_first_tx  = 1;
    int         count        = 0;


    function new(string name = "", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    // Try `make SIM_OPTS=+UVM_VERBOSITY=UVM_DEBUG`.
    virtual function void write_data(spi_seq_item_base t);
        spi_seq_item_base t_data;
        $cast(t_data, t.clone());
        `uvm_info(get_name(), $sformatf("Got item: %s",
            t_data.convert2string()), UVM_DEBUG);
        void'(data.try_put(t_data));
    endfunction 

    virtual function void build_phase(uvm_phase phase);
        void'(uvm_resource_db#(int)::read_by_name(
            get_full_name(), "item_amount", item_amount));
        imp_data      = new("imp_data",  this);
        data     = new();
        // cov_wrapper = new(); // TODO coverage
    endfunction

    virtual task reset_phase(uvm_phase phase);
        spi_seq_item_base tmp;
        while(data.try_get(tmp)) ;
    endtask

    virtual task main_phase(uvm_phase phase);
        spi_seq_item_base t_data;
        forever begin
            data    .get(t_data);
            do_check(t_data);
        end
    endtask

    virtual function void do_check(
        spi_seq_item_base t_data
    );
        if (~is_first_tx && t_data.cs_o)
        begin
            `uvm_error({get_name(),": BAD"}, $sformatf(
                    "Controller was load, but CS is unactive!"
                ));
        end
        else
        begin
            `uvm_info({get_name(),": GOOD"}, $sformatf(
                    "Controller was load, and CS is active!"
                ), UVM_DEBUG);
        end

        if (is_first_tx)
        begin
            is_first_tx = ~is_first_tx;
            `uvm_info(get_name(), $sformatf("Starting transmission for %8b", t_data.data_i), UVM_MEDIUM);
        end
        else 
        begin
            data_rx = {data_rx[6:0], t_data.mosi_o};
            count++;
        end

        if (count == 8)
        begin
            if (data_rx != t_data.data_i)
            begin
                `uvm_error({get_name(),": BAD"}, $sformatf(
                    "data_tx (%8b) was receive as %8b", t_data.data_i, data_rx
                ));
            end
            else
            begin
                `uvm_info({get_name(),": GOOD"}, $sformatf(
                    "data_tx (%8b) was receive as %8b", t_data.data_i, data_rx
                ), UVM_DEBUG);
            end

            if (~t_data.cs_o)
            begin
                `uvm_error({get_name(),": BAD"}, $sformatf(
                    "Transmission ends, but CS is active!"
                ));
            end
            else
            begin
                `uvm_info({get_name(),": GOOD"}, $sformatf(
                    "Transmission ends, and CS is unactive"
                ), UVM_DEBUG);
            end

            count       = 0;
            is_first_tx = 1;
        end

        if (t_data.cs_o && (t_data.mosi_o != 1'bx || t_data.sclk_o != 1'b1))
        begin
            `uvm_error({get_name(),": BAD"}, $sformatf(
                    "CS is unactive => mosi is %1b (expected x) and sclk is %1b (expected 1)", t_data.mosi_o, t_data.sclk_o
                ));
        end
        else
        begin
            `uvm_info({get_name(),": GOOD"}, $sformatf(
                    "CS is unactive => mosi is %1b and sclk is %1b", t_data.mosi_o, t_data.sclk_o
                ), UVM_DEBUG);
        end
    endfunction

endclass