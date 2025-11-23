class coverage extends uvm_subscriber #(sequence_item);
  `uvm_component_utils(coverage)

  logic [FIFO_DATA_WIDTH-1:0] wdata;

  covergroup wdata_cov;
    write_data: coverpoint wdata {
      bins zeros = {'h00};
      bins others = {['h01:'hFE]};
      bins ones = {'hFF};
    }
  endgroup

  function new (string name, uvm_component parent);
    super.new(name, parent);
    wdata_cov = new();
  endfunction

  function void write(sequence_item t);
    wdata = t.wdata;
    wdata_cov.sample();
  endfunction
endclass
