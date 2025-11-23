class random_sequence extends uvm_sequence #(sequence_item);
  `uvm_object_utils(random_sequence)

  sequence_item fifo_push;

  function new(string name = "random_sequence");
    super.new(name);
  endfunction

  integer i = 0;
  task body();
    repeat (TEST_NUM_ITER) begin
      fifo_push = sequence_item::type_id::create("fifo_push");
      start_item(fifo_push);
      assert(fifo_push.randomize());
      finish_item(fifo_push);
      i++;
    end
  endtask
endclass
