class input_flow_monitor extends uvm_component;
  `uvm_component_utils(input_flow_monitor)

  virtual async_fifo_bfm bfm;
  uvm_analysis_port #(sequence_item) ap;

  function new (string name, uvm_component parent);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);
    if(!uvm_config_db #(virtual async_fifo_bfm)::get(null, "*", "bfm", bfm))   //registers itself with BFM
      `uvm_fatal("DRIVER", "Failed to get BFM")
      ap = new("ap", this);   //creata an anaylsis port
  endfunction

  function void connect_phase(uvm_phase phase);
    bfm.input_flow_monitor_h = this;    //connects to BFM
  endfunction

  function void write_to_monitor(logic [FIFO_DATA_WIDTH-1:0] wdata);
    sequence_item push;    //BFM calls this function to write the data to the ap
    push = new("push");
    push.wdata = wdata;   //copying the data received through BFM.push() to the monitors data
    ap.write(push);   //Monitor now broadcasts this where ever required
  endfunction    //Monitors do not “receive broadcasts”.
//Monitors are the broadcasters.
//Consumers (scoreboard, coverage) receive the broadcast.
endclass
