class output_flow_transaction extends uvm_transaction;

  logic [FIFO_DATA_WIDTH-1:0] rdata;

  function new(string name = "");
    super.new(name);
  endfunction

  function void do_copy(uvm_object rhs);
    output_flow_transaction t;
    super.do_copy(rhs);
    $cast(t, rhs);
    rdata = t.rdata;
  endfunction

  function string convert2string();
    return $sformatf("rdata: %2h", rdata);
  endfunction

  function bit do_compare(uvm_object rhs, uvm_comparer comparer);
    output_flow_transaction t;
    bit same = super.do_compare(rhs, comparer);
    $cast(t, rhs);
    return (rdata == t.rdata) && same;
  endfunction
endclass
