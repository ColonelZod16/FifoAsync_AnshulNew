class output_flow_monitor extends uvm_component;
  `uvm_component_utils(output_flow_monitor)

  virtual async_fifo_bfm bfm;
  uvm_analysis_port #(output_flow_transaction) ap;

  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    if(!uvm_config_db #(virtual async_fifo_bfm)::get(null, "*","bfm", bfm))
      `uvm_fatal("DRIVER", "Failed to get BFM");
    ap = new("ap", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    bfm.output_flow_monitor_h = this;
  endfunction

  function void write_to_monitor(logic [FIFO_DATA_WIDTH-1:0] rdata);
    output_flow_transaction t;
    t = new("output_flow_t");
    t.rdata = rdata;
    ap.write(t);
  endfunction
endclass
