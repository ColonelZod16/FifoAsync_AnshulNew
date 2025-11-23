class sequence_item extends uvm_sequence_item;
  `uvm_object_utils(sequence_item)

  rand logic [FIFO_DATA_WIDTH-1:0] wdata;

  constraint data { wdata dist {8'h00:=1, [8'h01:8'hFE]:=1, 8'hFF:=1}; }

  function new(string name = "");
    super.new(name);
  endfunction

  function bit do_compare(uvm_object rhs, uvm_comparer comparer);
    sequence_item t;
    if (!$cast(t, rhs)) return 0;
    return (t.wdata == wdata);
  endfunction

  function void do_copy(uvm_object rhs);
    sequence_item t;
    super.do_copy(rhs);
    $cast(t, rhs);
    wdata = t.wdata;
  endfunction

  function string convert2string();
    return $sformatf("wdata: %2h", wdata);
  endfunction
endclass
