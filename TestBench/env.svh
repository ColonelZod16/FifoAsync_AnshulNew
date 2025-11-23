class env extends uvm_env;
  `uvm_component_utils(env)

  sequencer           sequencer_h;
  coverage            coverage_h;
  scoreboard          scoreboard_h;
  driver              driver_h;
  input_flow_monitor  input_flow_monitor_h;
  output_flow_monitor output_flow_monitor_h;

  function new (string name, uvm_component parent);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);
    sequencer_h              = new("sequencer_h", this);
    driver_h                 = driver::type_id::create("driver_h", this);
    input_flow_monitor_h     = input_flow_monitor::type_id::create("input_flow_monitor_h", this);
    output_flow_monitor_h    = output_flow_monitor::type_id::create("output_flow_monitor", this);
    coverage_h               = coverage::type_id::create("coverage_h", this);
    scoreboard_h             = scoreboard::type_id::create("scoreboard", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    driver_h.seq_item_port.connect(sequencer_h.seq_item_export);
    input_flow_monitor_h.ap.connect(coverage_h.analysis_export);
    input_flow_monitor_h.ap.connect(scoreboard_h.input_flow_f.analysis_export);
    output_flow_monitor_h.ap.connect(scoreboard_h.analysis_export);
  endfunction
endclass
