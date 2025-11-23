class scoreboard extends uvm_subscriber #(output_flow_transaction);
  `uvm_component_utils(scoreboard)

  uvm_tlm_analysis_fifo #(sequence_item) input_flow_f;

  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    input_flow_f = new ("input_flow_f", this);
  endfunction

  function output_flow_transaction expected_output_flow(sequence_item input_flow);
    output_flow_transaction expected;
    expected = new("expected");
    expected.rdata = input_flow.wdata;
    return expected;
  endfunction

  virtual function void write(output_flow_transaction t);
    sequence_item input_flow;
    output_flow_transaction expected;

    input_flow_f.try_get(input_flow);
    expected = expected_output_flow(input_flow);

    if (!expected.compare(t))
      `uvm_error("SCOREBOARD", "")
    else
      `uvm_info("SCOREBOARD", "", UVM_LOW)
  endfunction
endclass
