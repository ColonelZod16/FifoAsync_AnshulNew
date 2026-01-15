class coverage extends uvm_subscriber #(sequence_item);
  `uvm_component_utils(coverage)

  logic [FIFO_DATA_WIDTH-1:0] wdata;

  covergroup wdata_cov;
    write_data: coverpoint wdata {
      bins zeros = {'h00};
      bins others = {['h01:'hFE]};
      bins ones = {'hFF};
    }
  endgroup    //connected to input monitor's ap port by analysis export so write(() is called automatically to check for coverage

  function new (string name, uvm_component parent);
    super.new(name, parent);
    wdata_cov = new();
  endfunction

  function void write(sequence_item t);
    wdata = t.wdata;   //Coverage sampling is triggered when a valid transaction occurs; since the BFM already synchronizes to the correct simulation time, calling sample() immediately inside the subscriber’s write() method is correct and race-free.”
    wdata_cov.sample();
  endfunction
endclass
