import uvm_pkg::*;
`include "uvm_macros.svh"

interface my_interface(input bit clk);
    logic reset;
    logic [4:0] cout;
    logic c1, c2, c3, c4, c5;
    modport DRIVER (
        output reset,
        input clk, cout, c1, c2, c3, c4, c5
    );
    modport MONITOR (
        input reset, clk, cout, c1, c2, c3, c4, c5
    );
endinterface

class my_transaction extends uvm_sequence_item;
    rand bit reset_val;
    logic [4:0] observed_cout;

    `uvm_object_utils_begin(my_transaction)
        `uvm_field_int(reset_val, UVM_ALL_ON)
        `uvm_field_int(observed_cout, UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name = "my_transaction");
        super.new(name);
    endfunction

    function string convert2string();
        return $sformatf("Reset=%0d, Cout=%0d (c1=%0d, c2=%0d, c3=%0d, c4=%0d, c5=%0d)",
            reset_val, observed_cout, observed_cout[0], observed_cout[1], observed_cout[2], observed_cout[3], observed_cout[4]);
    endfunction
endclass

class my_sequence extends uvm_sequence#(my_transaction);
    `uvm_object_utils(my_sequence)

    function new(string name = "my_sequence");
        super.new(name);
    endfunction

    virtual task body();
        my_transaction req;
        `uvm_info("SEQ", "Starting sequence body", UVM_HIGH)
        `uvm_info("SEQ", "Starting RESET_HIGH phase (5 cycles)", UVM_HIGH)
        repeat(5) begin
            req = my_transaction::type_id::create("req");
            start_item(req);
            req.reset_val = 1;
            finish_item(req);
           // `uvm_info("SEQ", $sformatf("SENT: %s", req.convert2string()), UVM_LOW)
        end
        `uvm_info("SEQ", "Starting RESET_LOW phase (64 cycles)", UVM_HIGH)
        repeat(64) begin
            req = my_transaction::type_id::create("req");
            start_item(req);
            req.reset_val = 0;
            finish_item(req);
          // `uvm_info("SEQ", $sformatf("SENT: %s", req.convert2string()), UVM_LOW) //only sends reset at this point cuz there is no output yet for this transaction
        end
    endtask
endclass

class my_driver extends uvm_driver#(my_transaction);
    `uvm_component_utils(my_driver)
    virtual my_interface.DRIVER vif;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual my_interface.DRIVER)::get(this, "", "vif", vif))
            `uvm_fatal("DRV", "Virtual interface not set")
        if (vif == null)
            `uvm_fatal("DRV", "Virtual interface is null")
        `uvm_info("DRV", "Driver build phase completed", UVM_HIGH)
    endfunction

    task run_phase(uvm_phase phase);
        my_transaction req;
       // `uvm_info("DRV", "Driver: Initializing reset", UVM_HIGH)
        vif.reset <= 1'b1;
        @(posedge vif.clk);
        vif.reset <= 1'b0;
        @(posedge vif.clk);
        //`uvm_info("DRV", "Driver: Entering main loop", UVM_HIGH)
        forever begin
            seq_item_port.get_next_item(req);
          //  `uvm_info("DRV", "Driver: Got transaction", UVM_HIGH)
            vif.reset <= req.reset_val;
          //  `uvm_info("DRV", $sformatf("Driver: Set Reset=%0d", req.reset_val), UVM_LOW)
            @(posedge vif.clk);
            seq_item_port.item_done();
          //  `uvm_info("DRV", $sformatf("Driver: Completed: %s", req.convert2string()), UVM_LOW)
        end
    endtask
endclass

class my_monitor extends uvm_monitor;
    `uvm_component_utils(my_monitor)
    virtual my_interface.MONITOR vif;
    uvm_analysis_port#(my_transaction) ap;
    bit header_printed = 0;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        ap = new("ap", this);
        if (!uvm_config_db#(virtual my_interface.MONITOR)::get(this, "", "vif", vif))
            `uvm_fatal("MON", "Virtual interface not set")
        if (vif == null)
            `uvm_fatal("MON", "Virtual interface is null")
        `uvm_info("MON", "Monitor build phase completed", UVM_LOW)
    endfunction

    task run_phase(uvm_phase phase);
        my_transaction mon_trans;
        `uvm_info("MON", "Monitor: Waiting for reset deassertion", UVM_HIGH)
        wait(vif.reset == 1'b0);
        `uvm_info("MON", "Monitor: Reset deasserted, starting observation", UVM_HIGH)
        if (!header_printed) begin
            $display("--------------------------------------------------------------------------------");
            $display("| %-10s | %-5s | %-5s | %-2s | %-2s | %-2s | %-2s | %-2s |", 
                     "Time (ns)", "Reset", "Cout", "C1", "C2", "C3", "C4", "C5");
            $display("--------------------------------------------------------------------------------");
            header_printed = 1;
        end
        forever begin
            @(posedge vif.clk);
            mon_trans = my_transaction::type_id::create("mon_trans");
            mon_trans.reset_val = vif.reset;
            mon_trans.observed_cout = vif.cout;
            $display("| %-10d | %-5d | %-5d | %-2d | %-2d | %-2d | %-2d | %-2d |", 
                     $time, vif.reset, vif.cout, vif.c5, vif.c4, vif.c3, vif.c2, vif.c1);
            ap.write(mon_trans);
        end
    endtask
endclass

class my_agent extends uvm_agent;
    `uvm_component_utils(my_agent)
    my_driver m_driver;
    uvm_sequencer#(my_transaction) m_sequencer;
    my_monitor m_monitor;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        m_driver = my_driver::type_id::create("m_driver", this);
        m_sequencer = uvm_sequencer#(my_transaction)::type_id::create("m_sequencer", this);
        m_monitor = my_monitor::type_id::create("m_monitor", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        m_driver.seq_item_port.connect(m_sequencer.seq_item_export);
    endfunction
endclass

class my_env extends uvm_env;
    `uvm_component_utils(my_env)
    my_agent m_agent;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        m_agent = my_agent::type_id::create("m_agent", this);
    endfunction
endclass

class my_test extends uvm_test;
    `uvm_component_utils(my_test)
    my_env m_env;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        m_env = my_env::type_id::create("m_env", this);
        uvm_top.set_report_verbosity_level(UVM_NONE);
    endfunction

    task run_phase(uvm_phase phase);
        my_sequence seq;
        `uvm_info("TEST", "Test: Starting run phase", UVM_HIGH)
        phase.raise_objection(this);
        seq = my_sequence::type_id::create("seq");
        seq.start(m_env.m_agent.m_sequencer);
        phase.drop_objection(this);
        `uvm_info("TEST", "Test: Run phase completed", UVM_HIGH)
    endtask
endclass

module top_tb;
    logic clk;
    my_interface dut_if(.clk(clk));

    bit5Counter DUT (
        .clk(dut_if.clk),
        .reset(dut_if.reset),
        .cout(dut_if.cout),
        .c1(dut_if.c1),
        .c2(dut_if.c2),
        .c3(dut_if.c3),
        .c4(dut_if.c4),
        .c5(dut_if.c5)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        uvm_config_db#(virtual my_interface.DRIVER)::set(null, "uvm_test_top.m_env.m_agent.m_driver", "vif", dut_if);
        uvm_config_db#(virtual my_interface.MONITOR)::set(null, "uvm_test_top.m_env.m_agent.m_monitor", "vif", dut_if);
        run_test("my_test");
    end

    initial begin
        #2000ns;
        $finish;
    end
endmodule
