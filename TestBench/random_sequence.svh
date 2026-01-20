class random_sequence extends uvm_sequence #(sequence_item);
  `uvm_object_utils(random_sequence)

  sequence_item fifo_push;

  function new(string name = "random_sequence");
    super.new(name);
  endfunction

  integer i = 0;    
  task body();
    repeat (TEST_NUM_ITER) begin
      fifo_push = sequence_item::type_id::create("fifo_push");   //creates random transaction items which are sent to the sequencer
      start_item(fifo_push);   //tells the sequencer that its readyu to send item . can be blocked if sequencer already sending an item
      assert(fifo_push.randomize());  //randomizing the data
      finish_item(fifo_push);  //passing to the driver , can block the driver until transfer is complete.
      i++;
    end
  endtask
endclass
