class driver extends uvm_driver #(sequence_item);
  `uvm_component_utils(driver)

  virtual async_fifo_bfm bfm;    ///virtual because it gets the handle to an existing interface instance , enables loose coupling between TB and DUT

  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    if(!uvm_config_db #(virtual async_fifo_bfm)::get(null, "*", "bfm", bfm))   //fetches the interface from config db defined in top module
      `uvm_fatal("DRIVER", "Failed to get BFM")
  endfunction

  task push();
    sequence_item push;    
    integer i = 0;
    forever begin 
      if (i < TEST_FLOW_LENGTH-2) begin   //checking for the last item to send the last signal as well so bfm can handle that case as well
        seq_item_port.get_next_item(push);   //blocking call to get the next item from sequence
        bfm.push(push.wdata, 1'b0);
        seq_item_port.item_done();
      end else begin
        seq_item_port.get_next_item(push);
        bfm.push(push.wdata, 1'b1);   //last signal and last item sent
        seq_item_port.item_done();
      end
      i++;
      if (i > TEST_FLOW_LENGTH-1) i = 0; //restarting the burst counter
    end
  endtask
                                                                         //To add another pop driver, I would create a separate read sequencer and driver, connect them via TLM ports, and let both drivers share the same virtual FIFO interface.
  task pop();
    integer i = 0;
    forever begin
      if (i < TEST_FLOW_LENGTH-2)
        bfm.pop(1'b0);   //similar logic here
      else
        bfm.pop(1'b1);   //last signal
      i++;
      if (i > TEST_FLOW_LENGTH-1) i = 0;   //restarting the read counter
    end
  endtask

  task run_phase(uvm_phase phase);
    bfm.reset_rdwr();   //resetting the FIFO to a known state
    fork
      push();       
      pop();
    join_none
  endtask
endclass
