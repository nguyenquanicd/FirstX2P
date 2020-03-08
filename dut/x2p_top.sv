
module x2p_top;
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
  
  x2p_core dut_x2p (.aclk(clk),
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
endmodule
