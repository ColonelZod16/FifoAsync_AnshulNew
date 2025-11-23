interface async_fifo_bfm;
  import async_fifo_pkg::*;

  bit winc;
  bit wclk;
  bit wrst_n;
  bit rinc;
  bit rclk;
  bit rrst_n;
  logic [FIFO_DATA_WIDTH-1:0] wdata;

  wire [FIFO_DATA_WIDTH-1:0] rdata;
  wire wfull;
  wire rempty;

  bit rdDone;
  bit wrDone;
  integer wr_cmds;
  integer rd_cmds;

  task reset_rdwr();
    winc = 1'b0;
    wdata = '0;
    wrst_n = 1'b0;
    rinc = 1'b0;
    rrst_n = 1'b0;
    repeat(5) @(posedge wclk);
    wrst_n = 1'b1;
    repeat(1) @(posedge rclk);
    #2 rrst_n = 1'b1;
    repeat(2) @(posedge rclk);
  endtask

  task push(input bit [FIFO_DATA_WIDTH-1:0] data, input bit last);
    @ (negedge wclk);
    while (wfull) begin
      winc  = 0;
      wdata = 0;
      @ (negedge wclk);
    end
    winc  = 1;
    wdata = data;

    if (last) begin
      @ (negedge wclk);
      winc  = 0;
      wdata = 0;
      repeat (10) @ (posedge wclk);
      wrDone = 1;
    end
  endtask

  task pop(input bit last);
    @ (posedge rclk);
    while (rempty) begin
      rinc = 0;
      @ (posedge rclk);
    end
    rinc = 1;

    if (last) begin
      @ (posedge rclk);
      rinc = 0;
      repeat (10) @ (posedge rclk);
      rdDone = 1;
    end
  endtask

  task wait_4_rdwr_done();
    while (!wrDone) @(posedge wclk);
    while (!rdDone) @(posedge rclk);
  endtask

  input_flow_monitor input_flow_monitor_h;
  initial begin
    forever begin
      @ (posedge wclk iff winc);
      if (input_flow_monitor_h != null)
        input_flow_monitor_h.write_to_monitor(wdata);
    end
  end

  output_flow_monitor output_flow_monitor_h;
  initial begin
    forever begin
      @ (negedge rclk iff rinc);
      if (output_flow_monitor_h != null)
        output_flow_monitor_h.write_to_monitor(rdata);
    end
  end

  initial begin
    wclk = 0;
    rclk = 0;
    fork
      forever #10ns wclk = ~wclk;
      forever #35ns rclk = ~rclk;
    join
  end
endinterface
