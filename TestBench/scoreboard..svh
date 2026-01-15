class scoreboard extends uvm_subscriber #(output_flow_transaction);
  `uvm_component_utils(scoreboard)

  uvm_tlm_analysis_fifo #(sequence_item) input_flow_f;

  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    input_flow_f = new ("input_flow_f", this);
  endfunction

  function output_flow_transaction expected_output_flow(sequence_item input_flow);    //converts the received input transaction to output transaction type by copying the input data to the "expected" object
    output_flow_transaction expected;
    expected = new("expected");
    expected.rdata = input_flow.wdata;
    return expected;
  endfunction

  virtual function void write(output_flow_transaction t);   //output monitor calls the ap.write() , ap is connected to tlm port of this scoreboard which extended by uvm_subscriber so this write() is called , the analysis export is wired to the write() function , so it gets the output transaction
    sequence_item input_flow;
    output_flow_transaction expected;

    input_flow_f.try_get(input_flow);    // the input monitor's ap is connected to the input_flow_f so we use try_get() to get the item.
    expected = expected_output_flow(input_flow);  //getting the expected data item from the input
    data_str = {                     input_flow.convert2string(), 
                " ==>  Actual "  , t.convert2string(),    
                  "/expected "     , expected.convert2string()};

    if (!expected.compare(t))
      `uvm_error("SCOREBOARD SELF CHECKER", {"FAIL: ", data_str})
    else
      `uvm_info ("SCOREBOARD SELF CHECKER", {"PASS: ", data_str}, UVM_LOW)   //checking if they are the same or not

  endfunction
endclass
