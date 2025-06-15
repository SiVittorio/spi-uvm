`uvm_analysis_imp_decl(_data)

class spi_scoreboard_base extends uvm_scoreboard;

    `uvm_component_utils(spi_scoreboard_base)

    uvm_analysis_imp_data#(spi_seq_item_base, spi_scoreboard_base) imp_data;

    int item_amount = 1;

    // spi_cov_wrapper cov_wrapper; // TODO coverage

    mailbox#(spi_seq_item_base) data;

    // Vars for check
    logic [7:0] data_rx      [0:5];
    logic [7:0] current_intr [0:5];
    logic [7:0] current_bytes_cnt;
    logic       cs_unset     = 1;
    int         byte_count   = 0;
    int         bit_count    = 0;

    // DUT regs
    logic [7:0] dut_regs [0:8];

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
    endfunction

    virtual task reset_phase(uvm_phase phase);
        spi_seq_item_base tmp;
        while(data.try_get(tmp));
        foreach (dut_regs[i]) begin
            dut_regs[i] = 0;
        end
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
        foreach (t_data.is_write[i]) begin
            case (i)
                6: dut_regs[i] = t_data.is_write[i] ? t_data.bytes_cnt : dut_regs[i];
                default: dut_regs[i] = t_data.is_write[i] ? t_data.instruction[i] : dut_regs[i];
            endcase
        end
        // if (!cs_unset && t_data.cs_o)
        // begin
        //     `uvm_error({get_name(),": BAD"}, $sformatf(
        //             "Controller was load, but CS is unactive!"
        //         ));
        // end
        // else
        // begin
        //     `uvm_info({get_name(),": GOOD"}, $sformatf(
        //             "Controller was load, and CS is active!"
        //         ), UVM_DEBUG);
        // end
        if (cs_unset && !t_data.cs_o)
        begin
            cs_unset = ~cs_unset;
            byte_count = 0;
            bit_count  = 0;
            data_rx = { 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0 };

            current_intr = t_data.instruction;
            current_bytes_cnt = t_data.bytes_cnt;
            `uvm_info(get_name(), $sformatf("Starting transmission"), UVM_MEDIUM);
        end

        if (bit_count == 8)
        begin
            bit_count = 0;
            byte_count++;
        end

        if (!cs_unset && t_data.cs_o)
        begin
            `uvm_info(get_name(), $sformatf("COMPARE"), UVM_MEDIUM);
            for (int i=0; i<current_bytes_cnt+1; ++i)
            begin
                if (current_intr[i] !== data_rx[i])
                    `uvm_error({get_name(),": BAD"}, $sformatf("DUT: %2h\tSCRB: %2h", data_rx[i], current_intr[i]));
                `uvm_info(get_name(), $sformatf("DUT: %2h\tSCRB: %2h", data_rx[i], current_intr[i]), UVM_MEDIUM);
            end
            cs_unset = 1;
        end

        if (!cs_unset)
        begin
            data_rx[byte_count] = {data_rx[byte_count][6:0], t_data.mosi_o};
            bit_count++;
        end

        // if (bit_count == 8 && !cs_unset)
        // begin
        //     if (data_rx !== t_data.data_i)
        //     begin
        //         `uvm_error({get_name(),": BAD"}, $sformatf(
        //             "data_tx (%8b) was receive as %8b", t_data.data_i, data_rx
        //         ));
        //     end
        //     else
        //     begin
        //         `uvm_info({get_name(),": GOOD"}, $sformatf(
        //             "data_tx (%8b) was receive as %8b", t_data.data_i, data_rx
        //         ), UVM_DEBUG);
        //     end

        //     cs_unset    = 1;
        // end
        // else if (bit_count == 8 && cs_unset)
        // begin
        //     if (!t_data.cs_o)
        //     begin
        //         `uvm_error({get_name(),": BAD"}, $sformatf(
        //             "Transmission ends, but CS is active!"
        //         ));
        //     end
        //     else
        //     begin
        //         `uvm_info({get_name(),": GOOD"}, $sformatf(
        //             "Transmission ends, and CS is unactive"
        //         ), UVM_DEBUG);
        //     end

        //     bit_count = 0;
        // end

        // if (t_data.cs_o && (t_data.mosi_o !== 1'bx || t_data.sclk_o !== 1'b1))
        // begin
        //     `uvm_error({get_name(),": BAD"}, $sformatf(
        //             "CS is unactive => mosi is %1b (expected x) and sclk is %1b (expected 1)", t_data.mosi_o, t_data.sclk_o
        //         ));
        // end
        // else
        // begin
        //     `uvm_info({get_name(),": GOOD"}, $sformatf(
        //             "CS is unactive => mosi is %1b and sclk is %1b", t_data.mosi_o, t_data.sclk_o
        //         ), UVM_DEBUG);
        // end
    endfunction

endclass
