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
    
    // Addresses for common regs
    localparam INSTR_REG_ADDR       = 8'h00;
    localparam BYTES_1_REG_ADDR     = 8'h01;
    localparam BYTES_2_REG_ADDR     = 8'h02;
    localparam BYTES_3_REG_ADDR     = 8'h03;
    localparam BYTES_4_REG_ADDR     = 8'h04;
    localparam BYTES_5_REG_ADDR     = 8'h05;
    localparam BYTES_CNT_REG_ADDR   = 8'h06;
    localparam DRIVE_REG_ADDR       = 8'h07;
    localparam ST_REG_ADDR          = 8'h08;

    function new(string name = "", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual task reset();
        vif.paddr_i   <= 8'h00;
        vif.psel_i    <= 1'b0;
        vif.penable_i <= 1'b0;
        vif.pwrite_i  <= 1'b0;
        vif.pwdata_i  <= 8'h00;
        vif.miso_i    <= 1'b1;
    endtask

    virtual task main_phase(uvm_phase phase);
        `uvm_info(get_name(), "Begin main", UVM_DEBUG);
        forever begin
            wait(vif.cs_o);

            seq_item_port.get_next_item(req);
            vif.instruction = req.instruction;
            vif.bytes_cnt = req.bytes_cnt;
            vif.is_write  = req.is_write;
            `uvm_info(get_name(), "Get item", UVM_DEBUG);
            write_data_by_apb(INSTR_REG_ADDR, req.instruction[0], req.is_write[0]);
            `uvm_info(get_name(), $sformatf("IS_WRITE %b", req.is_write[0]), UVM_MEDIUM);
            for (int i=0; i<req.bytes_cnt; ++i) begin
                write_data_by_apb(i+1, req.instruction[i+1], req.is_write[i+1]);
            end
            `uvm_info(get_name(), "After cycle", UVM_DEBUG);
            write_data_by_apb(BYTES_CNT_REG_ADDR, req.bytes_cnt, req.is_write[6]);
            write_data_by_apb(DRIVE_REG_ADDR, 8'hff, req.is_write[7]);
            unset_data();

            wait(vif.pready_o);

            vif.wait_for_posedge(2);
            seq_item_port.item_done();
        end
        `uvm_info(get_name(), "End main", UVM_DEBUG);
    endtask

    task write_data_by_apb(logic [7:0] addr, logic [7:0] data, bit is_write);
        vif.paddr_i   <= addr;
        vif.pwrite_i  <= 1;
        vif.psel_i    <= 1;
        vif.pwdata_i  <= data;
        vif.wait_for_posedge(1);
        vif.penable_i <= 1;
        vif.wait_for_posedge(1);
        vif.penable_i <= 0;
        vif.pwrite_i  <= 0;
    endtask

    virtual task unset_data();
        reset();
    endtask

endclass
