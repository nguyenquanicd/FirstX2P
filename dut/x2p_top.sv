
module x2p_top(aclk,
               aresetn,
			   awvalid,
			   awaddr,
			   awsize,
			   awlen,
			   awburst,
			   awid,
			   awprot,
			   awready,
			   arvalid,
			   araddr,
			   arsize,
			   arlen,
			   arburst,
			   arid,
			   arprot,
			   arready,
			   wvalid,
			   wdata,
			   wstrb,
			   wlast,
			   wready,
			   rready,
			   rvalid,
			   rresp,
			   rlast,
			   rid,
			   rdata,
			   bready,
			   bvalid,
			   bresp,
			   bid,
			   pclk,
			   preset_n,
			   pready,
			   prdata,
			   pslverr,
			   paddr,
			   pwdata,
			   psel,
			   penable,
			   pprot,
			   pstrb,
			   pwrite
              );
  //declare ports 
  input logic aclk;
  input logic aresetn;
  input logic pclk;
  input logic preset_n;
  //iclude parameter file
  `include "x2p_parameter.h"
  //ports declaration
  // Address write chanel
  input logic                    awvalid;
  input logic [31:0]             awaddr;
  input logic [2:0]              awsize;
  input logic [7:0]              awlen;
  input logic [1:0]              awburst;
  input logic [7:0]              awid;
  input logic [2:0]              awprot;
  output logic                   awready;
  // address read chanel
  input logic                    arvalid;
  input logic [31:0]             araddr;
  input logic [2:0]              arsize;
  input logic [7:0]              arlen;
  input logic [1:0]              arburst;
  input logic [7:0]              arid;
  input logic [2:0]              arprot;
  output logic                   arready;
  //write data chanel
  input logic                    wvalid;
  input logic [31:0]             wdata;
  input logic [3:0]              wstrb;
  input logic                    wlast;
  output logic                   wready;
  //read data chanel
  input logic                     rready;
  output logic                    rvalid;
  output logic [1:0]              rresp;
  output logic                    rlast;
  output logic [7:0]              rid;
  output logic [31:0]             rdata;
  //write data chanel
  input logic                     bready;
  output logic                    bvalid;
  output logic [1:0]              bresp;
  output logic [7:0]              bid;
  //APB protocol
  input logic [SLAVE_NUM-1:0]       pready;
  input logic [SLAVE_NUM-1:0][31:0] prdata;
  input logic [SLAVE_NUM-1:0]       pslverr;
  output logic [31:0]               paddr;
  output logic [31:0]               pwdata;
  output logic [SLAVE_NUM-1:0]      psel;
  output logic                      penable;
  output logic [2:0]                pprot;
  output logic [3:0]                pstrb;
  output logic                      pwrite;
  //internal signal
  logic                              pselReg;
  logic                              preadyReg;
  logic                              pslverrReg;
  logic [31:0]                       prdataReg;

  x2p_core dut_x2p (.aclk(aclk),
               .aresetn(aresetn),
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
			   .pclk(pclk),
			   .preset_n(preset_n),
			   .pready(pready),
			   .prdata(prdata),
			   .pslverr(pslverr),
			   .paddr(paddr),
			   .pwdata(pwdata),
			   .psel(psel),
			   .penable(penable),
			   .pprot(pprot),
			   .pstrb(pstrb),
			   .pwrite(pwrite),
			   //register
			   .pselReg(pselReg),
			   .preadyReg(preadyReg),
			   .pslverrReg(pslverrReg),
			   .prdataReg(prdataReg)
               );
  x2p_register register(.pclk(pclk),
                            .preset_n(preset_n),
							.psel(pselReg),
							.penable(penable),
							.pready(preadyReg),
							.paddr(paddr),
							.pwrite(pwrite),
							.pwdata(pwdata),
							.pstrb(pstrb),
							.pslverr(pslverrReg),
							.pprot(pprot),
							.prdata(prdataReg)
                            );
endmodule: x2p_top