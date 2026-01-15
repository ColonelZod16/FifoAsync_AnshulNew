class runall_sequence extends uvm_sequence #(uvm_sequence_item);
  `uvm_object_utils(runall_sequence)

random_sequence random;
 sequencer sequencer_h;    //create a random sequencer_h
 uvm_component uvm_component_h;  //create a generic handle

  function new(string name = "runall_sequence");
    super.new(name);
    uvm_component_h = uvm_top.find("*.env_h.sequencer_h");  //find the existing sequencer defined in env.sv 
    $cast(sequencer_h, uvm_component_h);  //typecast the component_h which contains sequencer to the sequncer_h type which can now starting sending sequences
    random = random_sequence::type_id::create("random");   //create a random sequence object
  endfunction

  task body();
    random.start(sequencer_h);   //starts sending random sequences through the sequencer
  endtask
endclass
