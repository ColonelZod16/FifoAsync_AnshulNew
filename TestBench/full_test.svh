class full_test extends async_fifo_base_test;
  `uvm_component_utils(full_test)

  runall_sequence runall_seq;

  function new (string name, uvm_component parent);
    super.new(name,parent);
  endfunction

  task run_phase(uvm_phase phase);
    runall_seq = new("runall_seq");
    phase.raise_objection(this);
    runall_seq.start(null);   //calls the body of the runall_sequence
    phase.drop_objection(this);
  endtask
endclass
