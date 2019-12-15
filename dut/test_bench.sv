`timescale 1ns / 1ns
module test_bench;
  //declare ports 
  logic clk, rst;
  //iclude parameter file
  `include "x2p_parameter.h"
  //ports declaration
  //AXI protocol
  //logic                     aclk;
  //logic                     aresetn;
  // Address write chanel
  logic                    awvalid;
  logic [31:0]             awaddr;
  logic [2:0]              awsize;
  logic [7:0]              awlen;
  logic [1:0]              awburst;
  logic [7:0]              awid;
  logic [2:0]              awprot;
  logic                    awready;
  // address read chanel
  logic                    arvalid;
  logic [31:0]             araddr;
  logic [2:0]              arsize;
  logic [7:0]              arlen;
  logic [1:0]              arburst;
  logic [7:0]              arid;
  logic [2:0]              arprot;
  logic                    arready;
  //write data chanel
  logic                    wvalid;
  logic [31:0]             wdata;
  logic [3:0]              wstrb;
  logic                    wlast;
  logic                    wready;
  //read data chanel
  logic                    rready;
  logic                    rvalid;
  logic [1:0]              rresp;
  logic                    rlast;
  logic [7:0]              rid;
  logic [31:0]             rdata;
  //write data chanel
  logic                    bready;
  logic                    bvalid;
  logic [1:0]              bresp;
  logic [7:0]              bid;
  //APB protocol
  //logic                     pclk;
  //logic                     preset_n;
  logic [SLAVE_NUM:0]       pready;
  logic [SLAVE_NUM:0][31:0] prdata;
  logic [SLAVE_NUM:0]       pslverr;
  logic [31:0]              paddr;
  logic [31:0]              pwdata;
  logic [SLAVE_NUM:0]       psel;
  logic                     penable;
  logic [2:0]               pprot;
  logic [3:0]               pstrb;
  logic                     pwrite;


  //integer cnt_err = 0;
  //DUT instance
  //sys_sig signal  (.clk(clk),
  //                 .rst(rst)
//		  );
  initial begin
    clk = 0;
    forever 
    #50 clk = ~clk;
  end
  initial begin
    rst     = 1;
    #20 rst = 0;
    #50 rst = 1;
  end

  
  x2p dut_x2p (.aclk(clk),
               .aresetn(rst),
			   .awvalid(awvalid),
			   .awaddr(awaddr),
			   .awsize(awsize),
			   .awlen(awlen),
			   .awburst(awburst),
			   .awid(awid),
			   .awprot(awprot),
			   .awready(awready),
			   //address read chanel
			   .arvalid(arvalid),
			   .araddr(araddr),
			   .arsize(arsize),
			   .arlen(arlen),
			   .arburst(arburst),
			   .arid(arid),
			   .arprot(arprot),
			   .arready(arready),
			   //write data chanel
			   .wvalid(wvalid),
			   .wdata(wdata),
			   .wstrb(wstrb),
			   .wlast(wlast),
			   .wready(wready),
			   //read data chanel
			   .rready(rready),
			   .rvalid(rvalid),
			   .rresp(rresp),
			   .rlast(rlast),
			   .rid(rid),
			   .rdata(rdata),
			   //write respond chanel
			   .bready(bready),
			   .bvalid(bvalid),
			   .bresp(bresp),
			   .bid(bid),
			   //APB Protocol
			   .pclk(clk),
			   .preset_n(rst),
			   .pready(pready),
			   .prdata(prdata),
			   .pslverr(pslverr),
			   .paddr(paddr),
			   .pwdata(pwdata),
			   .psel(psel),
			   .penable(penable),
			   .pprot(pprot),
			   .pstrb(pstrb),
			   .pwrite(pwrite)
               );
  x2p_register register(.pclk(clk),
                            .preset_n(rst),
							.psel(psel[0]),
							.penable(penable),
							.pready(pready[0]),
							.paddr(paddr),
							.pwrite(pwrite),
							.pwdata(pwdata),
							.pstrb(pstrb),
							.pslverr(pslverr[0]),
							.pprot(pprot),
							.prdata(prdata[0])
                            );

  
  initial begin
    #100;
	@(posedge clk);
    @(posedge clk);
    @(posedge clk);
    //#1;
    arvalid = 1'b1; araddr = 32'h0000_0000; arsize = 3'b010; arlen = 8'h03; arburst = 2'b01; arid = 8'd100; arprot = 3'b000;
    $display("================================================================================");
    $display("At time [%0t] AXI master is sending an address_read %0d", $stime, araddr);

    @(posedge clk);
    arvalid = 1'b1; araddr = 32'h0000_1000; arsize = 3'b010; arlen = 8'h03; arburst = 2'b01; arid = 8'd200; arprot = 3'b000;
    $display("================================================================================");
    $display("At time [%0t] AXI master is sending an address_read %0d", $stime, araddr);
	@(posedge clk)
    while(arready != 1) @(posedge clk);
    //#1;
    arvalid = 1'b0; araddr = 32'd0; arsize = 3'b000; arlen = 8'd0; arburst = 2'b00; arid = 8'd0; arprot = 3'b000;
    $display("At time [%0t] AXI master has send address_read completely", $stime);
    $display("================================================================================");
  end
  
  initial begin
    #100;
    @(posedge clk);
	//#1;
	rready = 1'b1;
  end
  
  initial begin
    #100;
    @(posedge clk);
      //#1;
      awvalid = 1'b1; awaddr = 32'h0000_2000; awsize = 3'b010; awlen = 8'd3; awburst = 2'b10; awid = 8'd200; awprot = 3'b000;
      $display("================================================================================");
      $display("At time [%0d], AXI master is sending an address = %h", $stime, awaddr);

    @(posedge clk);
      while(awready != 1) @(posedge clk);
      //#1;
      awvalid = 1'b0; awaddr = 32'd0; awsize = 3'b000; awlen = 8'd0;  awburst = 2'b00; awid = 8'd0; awprot = 3'b000;
      $display("At time [%0d], AXI master sent address completely", $stime);
      $display("================================================================================");
  end
  
  initial begin
    #100;
    @(posedge clk);
      //#1;
      wvalid = 1'b1; wstrb = 4'b1111; wlast = 0; wdata = 32'hFFFF_FFF0;
      $display("================================================================================");
      $display("At time [%0d], AXI master is sending data = %h", $stime, wdata);
    @(posedge clk);
      //#1;
      wdata = 32'hFFFF_FFF1;
      $display("================================================================================");
      $display("At time [%0d], AXI master is sending data = %h", $stime, wdata);
	@(posedge clk);
      //#1;
      wdata = 32'hFFFF_FFF2;
      $display("================================================================================");
      $display("At time [%0d], AXI master is sending data = %h", $stime, wdata);
	@(posedge clk);
      //#1;
      wdata = 32'hFFFF_FFF3; wlast = 1;
      $display("================================================================================");
      $display("At time [%0d], AXI master is sending data = %h", $stime, wdata);
	@(posedge clk);
      //#1;
      wlast = 0;
      $display("================================================================================");
      $display("At time [%0d], wlast = %b", $stime, wlast);

      while(wready != 1) @(posedge clk);
      //#1;
      wvalid = 1'b0; wstrb = 4'd0; wlast = 0; wdata = 32'd0;
      $display("At time [%0d], AXI sent data completely", $stime);
      $display("================================================================================");
  end
  
  initial begin
    #100;
    @(posedge clk);
	//#1;
	rready = 1'b1;
  end

  
  initial begin
    #100;
    @(posedge clk)
      //#1;
	  bready = 1;
  end
  initial begin
    if(SLAVE_NUM >= 1) begin
      prdata[1]  = 32'hFFFF_0000;
	  pready[1]  = 1'b1;
	  pslverr[1] = 1'b0;
	end
	if(SLAVE_NUM >= 2) begin
      prdata[2]  = 32'h00000001;
	  pready[2]  = 1'b1;
	  pslverr[2] = 1'b0;
	end
    if(SLAVE_NUM >= 3) begin
      prdata[3]  = 32'h00000002;
	  pready[3]  = 1'b1;
	  pslverr[3] = 1'b0;
	end
	if(SLAVE_NUM >= 4) begin
      prdata[4]  = 32'h00000003;
	  pready[4]  = 1'b1;
	  pslverr[4] = 1'b0;
	end
    if(SLAVE_NUM >= 5) begin
      prdata[5]  = 32'h00000004;
	  pready[5]  = 1'b1;
	  pslverr[5] = 1'b0;
	end
	if(SLAVE_NUM >= 6) begin
      prdata[6]  = 32'h00000005;
	  pready[6]  = 1'b1;
	  pslverr[6] = 1'b0;
	end
    if(SLAVE_NUM >= 7) begin
      prdata[7]  = 32'h00000006;
	  pready[7]  = 1'b1;
	  pslverr[7] = 1'b0;
	end
	if(SLAVE_NUM >= 8) begin
      prdata[8]  = 32'h00000007;
	  pready[8]  = 1'b1;
	  pslverr[8] = 1'b0;
	end
    if(SLAVE_NUM >= 9) begin
      prdata[9]  = 32'h00000000;
	  pready[9]  = 1'b1;
	  pslverr[9] = 1'b0;
	end
	if(SLAVE_NUM >= 10) begin
      prdata[10]  = 32'h0001;
	  pready[10]  = 1'b1;
	  pslverr[10] = 1'b0;
	end
    if(SLAVE_NUM >= 11) begin
      prdata[11]  = 32'h0002;
	  pready[11]  = 1'b1;
	  pslverr[11] = 1'b0;
	end
	if(SLAVE_NUM >= 12) begin
      prdata[12]  = 32'h0003;
	  pready[12]  = 1'b1;
	  pslverr[12] = 1'b0;
	end
    if(SLAVE_NUM >= 13) begin
      prdata[13]  = 32'h0004;
	  pready[13]  = 1'b1;
	  pslverr[13] = 1'b0;
	end
	if(SLAVE_NUM >= 14) begin
      prdata[14]  = 32'h0005;
	  pready[14]  = 1'b1;
	  pslverr[14] = 1'b0;
	end
    if(SLAVE_NUM >= 15) begin
      prdata[15]  = 32'h0006;
	  pready[15]  = 1'b1;
	  pslverr[15] = 1'b0;
	end
	if(SLAVE_NUM >= 16) begin
      prdata[16]  = 32'h0007;
	  pready[16]  = 1'b1;
	  pslverr[16] = 1'b0;
	end
    if(SLAVE_NUM >= 17) begin
      prdata[17]  = 32'h0000;
	  pready[17]  = 1'b1;
	  pslverr[17] = 1'b0;
	end
	if(SLAVE_NUM >= 18) begin
      prdata[18]  = 32'h0001;
	  pready[18]  = 1'b1;
	  pslverr[18] = 1'b0;
	end
    if(SLAVE_NUM >= 19) begin
      prdata[19]  = 32'h0002;
	  pready[19]  = 1'b1;
	  pslverr[19] = 1'b0;
	end
	if(SLAVE_NUM >= 20) begin
      prdata[20]  = 32'h0003;
	  pready[20]  = 1'b1;
	  pslverr[20] = 1'b0;
	end
    if(SLAVE_NUM >= 21) begin
      prdata[21]  = 32'h0004;
	  pready[21]  = 1'b1;
	  pslverr[21] = 1'b0;
	end
	if(SLAVE_NUM >= 22) begin
      prdata[22]  = 32'h0005;
	  pready[22]  = 1'b1;
	  pslverr[22] = 1'b0;
	end
    if(SLAVE_NUM >= 23) begin
      prdata[23]  = 32'h0006;
	  pready[23]  = 1'b1;
	  pslverr[23] = 1'b0;
	end
	if(SLAVE_NUM >= 24) begin
      prdata[24]  = 32'h0007;
	  pready[24]  = 1'b1;
	  pslverr[24] = 1'b0;
	end
    if(SLAVE_NUM >= 25) begin
      prdata[25]  = 32'h0000;
	  pready[25]  = 1'b1;
	  pslverr[25] = 1'b0;
	end
	if(SLAVE_NUM >= 26) begin
      prdata[26]  = 32'h0001;
	  pready[26]  = 1'b1;
	  pslverr[26] = 1'b0;
	end
    if(SLAVE_NUM >= 27) begin
      prdata[27]  = 32'h0002;
	  pready[27]  = 1'b1;
	  pslverr[27] = 1'b0;
	end
	if(SLAVE_NUM >= 28) begin
      prdata[28]  = 32'h0003;
	  pready[28]  = 1'b1;
	  pslverr[28] = 1'b0;
	end
    if(SLAVE_NUM >= 29) begin
      prdata[29]  = 32'h0004;
	  pready[29]  = 1'b1;
	  pslverr[29] = 1'b0;
	end
	if(SLAVE_NUM >= 30) begin
      prdata[30]  = 32'h0005;
	  pready[30]  = 1'b1;
	  pslverr[30] = 1'b0;
	end
    if(SLAVE_NUM >= 31) begin
      prdata[31]  = 32'h0006;
	  pready[31]  = 1'b1;
	  pslverr[31] = 1'b0;
	end
	if(SLAVE_NUM == 32) begin
      prdata[32]  = 32'h0007;
	  pready[32]  = 1'b1;
	  pslverr[32] = 1'b0;
	end
  end
// `include "run_test.vt"
// task report;
//   input integer status_report;

//   begin
//     if (status_report == 0)
//     begin
//       $display("RESULT: TEST PASSED");
//       $display("\n");
//     end
//     else
//     begin
//       $display("RESULT: TEST FAILED");
//       $display("\n");
//     end
//     $finish;
//   end
// endtask
// initial
//   begin
//     run_test();
//     $display("cnt_err = %0d", cnt_err);
//     report(cnt_err);
//   end
endmodule
