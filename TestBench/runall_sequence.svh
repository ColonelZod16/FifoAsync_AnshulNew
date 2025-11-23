class runall_sequence extends uvm_sequence #(uvm_sequence_item);
  `uvm_object_utils(runall_sequence)

random_sequence random;
 sequencer sequencer_h;
 uvm_component uvm_component_h;

  function new(string name = "runall_sequence");
    super.new(name);
    uvm_component_h = uvm_top.find("*.env_h.sequencer_h");
    $cast(sequencer_h, uvm_component_h);
    random = random_sequence::type_id::create("random");
  endfunction

  task body();
    random.start(sequencer_h);
  endtask
endclass
