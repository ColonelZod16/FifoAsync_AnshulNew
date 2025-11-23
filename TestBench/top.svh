module top;
  import uvm_pkg::*;
  import async_fifo_pkg::*;
  `include "uvm_macros.svh"

  async_fifo_bfm bfm();

  async_fifo #(FIFO_DATA_WIDTH, FIFO_MEM_ADDR_WIDTH) DUT
    (.winc(bfm.winc),
     .wclk(bfm.wclk),
     .wrst_n(bfm.wrst_n),
     .rinc(bfm.rinc),
     .rclk(bfm.rclk),
     .rrst_n(bfm.rrst_n),
     .wdata(bfm.wdata),
     .rdata(bfm.rdata),
     .wfull(bfm.wfull),
     .rempty(bfm.rempty));

  initial begin
    uvm_config_db #(virtual async_fifo_bfm)::set(null, "*", "bfm", bfm);
    run_test("full_test");
  end

  initial begin
    $dumpfile("async_fifo.vcd");
    $dumpvars();
  end
endmodule
