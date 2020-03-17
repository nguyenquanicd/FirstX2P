//===================================================================================
// File name: x2p_core.sv
// Project  : X2P
// Function : IP core design of AXI to APB bridge
// Author   : Pham Van Thang
// Gmail    : phamanhthang147@gmail.com
// Website  :http://nguyenquanicd.blogspot.com
//===================================================================================
`include "x2p_define.h"
module x2p_core (// AXI protocol
            aclk,
            aresetn,
			// Address write chanel
			awvalid,
			awready,
			awaddr,
			awsize,
			awlen,
			awburst,
			awid,
			awprot,
			// Address read chanel
			arvalid,
			arready,
			araddr,
			arsize,
			arlen,
			arburst,
			arid,
			arprot,
			// Write data chanel
			wvalid,
			wready,
			wdata,
			wstrb,
			wlast,
			// Read data chanel
			rvalid,
			rready,
			rlast,
			rresp,
			rid,
			rdata,
			// Write respond chanel
			bvalid,
			bready,
			bresp,
			bid,
			// APB protocol
			pclk,
			preset_n,
			paddr,
			pwdata,
			psel,
			penable,
			pprot,
			pready,
			pstrb,
			pwrite,
			prdata,
			pslverr,
			//register
			psel_reg,
			pready_reg,
			prdata_reg,
			pslverr_reg
            );
  //iclude parameter file
  `include "x2p_parameter.h"
  //ports declaration
  //AXI protocol
  input logic                   				  aclk;
  input logic                     				  aresetn;
  // Address write chanel
  input  logic                    				  awvalid;
  input  logic [ADDR_WIDTH-1:0]                   awaddr;
  input  logic [SIZE_WIDTH-1:0]                   awsize;
  input  logic [LEN_WIDTH-1:0]                    awlen;
  input  logic [1:0]                              awburst;
  input  logic [ID_WIDTH-1:0]                     awid;
  input  logic [2:0]                              awprot;
  output logic                                    awready;
  // address read chanel
  input  logic                                    arvalid;
  input  logic [ADDR_WIDTH-1:0]                   araddr;
  input  logic [SIZE_WIDTH-1:0]                   arsize;
  input  logic [LEN_WIDTH-1:0]                    arlen;
  input  logic [1:0]                              arburst;
  input  logic [ID_WIDTH-1:0]                     arid;
  input  logic [2:0]                              arprot;
  output logic                                    arready;
  //write data chanel
  input  logic                                    wvalid;
  input  logic [DATA_WIDTH_AXI-1:0]               wdata;
  input  logic [DATA_WIDTH_AXI/8-1:0]             wstrb;
  input  logic                                    wlast;
  output logic                                    wready;
  //read data chanel
  input  logic                                    rready;
  output logic                                    rvalid;
  output logic [1:0]                              rresp;
  output logic                                    rlast;
  output logic [ID_WIDTH-1:0]                     rid;
  output logic [DATA_WIDTH_AXI-1:0]               rdata;
  //write respond chanel
  input  logic                                    bready;
  output logic                                    bvalid;
  output logic [1:0]                              bresp;
  output logic [ID_WIDTH-1:0]                     bid;
  //APB protocol
  input  logic                                    pclk;
  input  logic                                    preset_n;
  input  logic [SLAVE_NUM-1:0]                    pready;
  input  logic [SLAVE_NUM-1:0][31:0]              prdata;
  input  logic [SLAVE_NUM-1:0]                    pslverr;
  output logic [ADDR_WIDTH-1:0]                   paddr;
  output logic [DATA_WIDTH_APB-1:0]               pwdata;
  output logic [SLAVE_NUM-1:0]                    psel;
  output logic                                    penable;
  output logic [2:0]                              pprot;
  output logic [DATA_WIDTH_APB/8-1:0]             pstrb;
  output logic                                    pwrite;
  //register
  input logic                                     pready_reg;
  input logic                                     pslverr_reg;
  output logic                                    psel_reg;
  input logic [DATA_WIDTH_APB-1:0]                prdata_reg;
  //internal signals
  //SFIFO_AW
  logic                           sfifo_aw_full;
  logic                           sfifo_aw_not_full;
  logic                           sfifo_aw_empty;
  logic                           sfifo_aw_not_empty;
  logic                           sfifo_aw_we;
  logic                           sfifo_aw_re;
  logic [ADDR_WIDTH-1:0]          sfifo_aw_awaddr;
  logic [ID_WIDTH-1:0]            sfifo_aw_awid;
  logic [LEN_WIDTH-1:0]           sfifo_aw_ctrl_awlen;
  logic [SIZE_WIDTH-1:0]          sfifo_aw_ctrl_awsize;
  logic [1:0]                     sfifo_aw_ctrl_awburst;
  logic [2:0]                     sfifo_aw_ctrl_awprot;
  //SFIFO_AR
  logic                           sfifo_ar_full;
  logic                           sfifo_ar_not_full;
  logic                           sfifo_ar_empty;
  logic                           sfifo_ar_not_empty;
  logic                           sfifo_ar_we;
  logic                           sfifo_ar_re;
  logic [ADDR_WIDTH-1:0]          sfifo_ar_araddr;
  logic [ID_WIDTH-1:0]            sfifo_ar_arid;
  logic [LEN_WIDTH-1:0]           sfifo_ar_ctrl_arlen;
  logic [SIZE_WIDTH-1:0]          sfifo_ar_ctrl_arsize;
  logic [1:0]                     sfifo_ar_ctrl_arburst;
  logic [2:0]                     sfifo_ar_ctrl_arprot;
  //SFIFO_WD
  logic                           sfifo_wd_full;
  logic                           sfifo_wd_not_full;
  logic                           sfifo_wd_empty;
  logic                           sfifo_wd_not_empty;
  logic                           sfifo_wd_we;
  logic                           sfifo_wd_re;
  logic [DATA_WIDTH_AXI-1:0]      sfifo_wd_wdata;
  logic [DATA_WIDTH_AXI/8-1:0]    sfifo_wd_wstrb;
  //SFIFO_RD
  logic                           sfifo_rd_full;
  logic                           sfifo_rd_not_full;
  logic                           sfifo_rd_empty;
  logic                           sfifo_rd_not_empty;
  logic                           sfifo_rd_we;
  logic                           sfifo_rd_re;
  //RD_CH
  logic[1:0]                      rch_rresp;
  //ARBITER
  logic [1:0]                     abt_grant;
  logic [1:0]                     next_grant;
  logic [1:0]                     next_sel;
  //DECODER
  logic                                         pslverr_apb;
  logic [DATA_WIDTH_APB-1:0]                    prdata_apb;
  logic                                         pready_apb;
  logic                                         transaction_completed;
  logic                                         dec_error;
  logic                                         trans_cnt_en;
  logic [ADDR_WIDTH-1:0]                        start_addr;
  logic [SLAVE_NUM-1:0]                         sel;
  logic [LEN_WIDTH-1:0]                         select_len;
  logic [LEN_WIDTH-1:0]                         transfer_counter;
  logic                                         transfer;
  logic [1:0]                                   next_state;
  logic [1:0]                                   current_state;
  logic [1:0]                                   burst_mode;
  logic [ADDR_WIDTH-1:0]                        incr_next_transaddr;
  logic [ADDR_WIDTH-1:0]                        wrap_next_transaddr;
  logic [3:0]                                   bit_num;
  logic [2:0]                                   bit3_addr;
  logic [3:0]                                   bit4_addr;
  logic [4:0]                                   bit5_addr;
  logic [5:0]                                   bit6_addr;
  logic [6:0]                                   bit7_addr;
  logic [7:0]                                   bit8_addr;
  logic [8:0]                                   bit9_addr;
  logic [9:0]                                   bit10_addr;
  logic [10:0]                                  bit11_addr;
  logic [SLAVE_NUM-1:0]                         pready_out;
  logic [SLAVE_NUM-1:0]                         pslverr_out;
  logic [SLAVE_NUM-1:0][DATA_WIDTH_APB-1:0]     prdata_out;
  logic                                         update;
  logic                                         select_reserve;
  logic                                         pselect_reserve;
  logic [DATA_WIDTH_AXI-1:0]                    prdata_wrap_apb;
  logic 										transfer_en;
  logic [DATA_WIDTH_APB/8-1:0]                  wstrb_en;
`ifdef MODE1024_32_MODE512_32_MODE256_32_MODE128_32_MODE64_32
  logic                                         cnt_32;
`endif
`ifdef MODE1024_32_MODE512_32_MODE256_32_MODE128_32
  logic                                         cnt_64;
`endif
`ifdef MODE1024_32_MODE512_32_MODE256_32
  logic                                         cnt_128;
`endif
`ifdef MODE1024_32_MODE512_32
  logic                                         cnt_256;
`endif
`ifdef MODE1024_32
  logic                                         cnt_512;
`endif
`ifdef MODE1024_32_MODE512_32_MODE256_32_MODE128_32_MODE64_32_MODE32_32
  logic	                                        sfifo_wd_re_32;
  logic	                                        sfifo_rd_we_32;
`endif
`ifdef MODE1024_32_MODE512_32_MODE256_32_MODE128_32_MODE64_32
  logic	                                        sfifo_wd_re_64;
  logic	                                        sfifo_rd_we_64;
`endif
`ifdef MODE1024_32_MODE512_32_MODE256_32_MODE128_32
  logic	                                        sfifo_wd_re_128;
  logic	                                        sfifo_rd_we_128;
`endif
`ifdef MODE1024_32_MODE512_32_MODE256_32
  logic	                                        sfifo_wd_re_256;
  logic	                                        sfifo_rd_we_256;
`endif
`ifdef MODE1024_32_MODE512_32
  logic	                                        sfifo_wd_re_512;
  logic	                                        sfifo_rd_we_512;
`endif
`ifdef MODE1024_32
  logic	                                        sfifo_wd_re_1024;
  logic	                                        sfifo_rd_we_1024;
`endif
`ifdef MODE32_32
  logic [DATA_WIDTH_AXI-1:0]					prdata_wrap_apb_32;
  logic											transfer_en_32;
  logic [DATA_WIDTH_APB/8-1:0]                  wstrb_32;
  logic [31:0]                                  separate_wdata_32;
`endif
`ifdef MODE64_32 
  logic [DATA_WIDTH_AXI-1:0]					prdata_wrap_apb_64;
  logic											transfer_en_64;
  logic [DATA_WIDTH_APB/8-1:0]                  wstrb_64;
  logic [31:0]                                  separate_wdata_64;
`endif
`ifdef MODE128_32
  logic [DATA_WIDTH_AXI-1:0]					prdata_wrap_apb_128;
  logic											transfer_en_128;
  logic [DATA_WIDTH_APB/8-1:0]                  wstrb_128;
  logic [31:0]                                  separate_wdata_128;
`endif
`ifdef MODE256_32
  logic [DATA_WIDTH_AXI-1:0]					prdata_wrap_apb_256;
  logic											transfer_en_256;
  logic [DATA_WIDTH_APB/8-1:0]                  wstrb_256;
  logic [31:0]                                  separate_wdata_256;
`endif
`ifdef MODE512_32
  logic [DATA_WIDTH_AXI-1:0]					prdata_wrap_apb_512;
  logic											transfer_en_512;
  logic [DATA_WIDTH_APB/8-1:0]                  wstrb_512;
  logic [31:0]                                  separate_wdata_512;
`endif
`ifdef MODE1024_32
  logic [DATA_WIDTH_AXI-1:0]					prdata_wrap_apb_1024;
  logic											transfer_en_1024;
  logic [DATA_WIDTH_APB/8-1:0]                  wstrb_1024;
  logic [31:0]                                  separate_wdata_1024;
`endif
  logic											sel_reg;
  logic [31:0]                                  separate_wdata;
  logic [DATA_WIDTH_APB-1:0]                    prdata_reg_out;
  //body
  //X2P_SFIFO_AR
  sfifo #(.DATA_WIDTH(X2P_SFIFO_AR_DATA_WIDTH), .POINTER_WIDTH(POINTER_WIDTH)) ar_sfifo (
  .clk(aclk),
  .rst_n(aresetn),
  .wr(sfifo_ar_we),
  .rd(sfifo_ar_re),
  .data_in({araddr[ADDR_WIDTH-1:0], arid[ID_WIDTH-1:0], arlen[LEN_WIDTH-1:0], arsize[SIZE_WIDTH-1:0], arburst[1:0], arprot[2:0]}),
  .sfifo_empty(sfifo_ar_empty),
  .sfifo_full(sfifo_ar_full),
  .data_out({sfifo_ar_araddr[ADDR_WIDTH-1:0], sfifo_ar_arid[ID_WIDTH-1:0], sfifo_ar_ctrl_arlen[LEN_WIDTH-1:0], sfifo_ar_ctrl_arsize[SIZE_WIDTH-1:0], sfifo_ar_ctrl_arburst[1:0], sfifo_ar_ctrl_arprot[2:0]})
  );
  //Logic
  assign sfifo_ar_not_full  = ~sfifo_ar_full;
  assign sfifo_ar_not_empty = ~sfifo_ar_empty;
  assign arready            = sfifo_ar_not_full;
  assign sfifo_ar_we        = arready & arvalid;
  assign sfifo_ar_re        = sfifo_ar_not_empty  & transaction_completed & abt_grant[0];
  //X2P_SFIFO_RD
  sfifo #(.DATA_WIDTH(X2P_SFIFO_RD_DATA_WIDTH), .POINTER_WIDTH(POINTER_WIDTH)) rd_sfifo(
  .clk(aclk),
  .rst_n(aresetn),
  .wr(sfifo_rd_we),
  .rd(sfifo_rd_re),
  .data_in({prdata_wrap_apb[DATA_WIDTH_AXI-1:0], rch_rresp[1:0], sfifo_ar_arid[ID_WIDTH-1:0]}),
  .sfifo_empty(sfifo_rd_empty),
  .sfifo_full(sfifo_rd_full),
  .data_out({rdata[DATA_WIDTH_AXI-1:0], rresp[1:0], rid[ID_WIDTH-1:0]})
  );
  //Logic
  assign sfifo_rd_not_full      = ~sfifo_rd_full;
  assign sfifo_rd_not_empty     = ~sfifo_rd_empty;
  assign rvalid                 = sfifo_rd_not_empty;
  assign sfifo_rd_re            = rvalid & rready;
  assign trans_cnt_en           = (|psel[SLAVE_NUM-1:0] | pselect_reserve | psel_reg) & penable & pready_apb;
  //sfifo_rd_we
  `ifdef MODE32_32
    assign sfifo_rd_we = sfifo_rd_we_32;
  `elsif MODE64_32
    assign sfifo_rd_we = sfifo_rd_we_64;
  `elsif MODE128_32
    assign sfifo_rd_we = sfifo_rd_we_128;
  `elsif MODE256_32
    assign sfifo_rd_we = sfifo_rd_we_256;
  `elsif MODE512_32
    assign sfifo_rd_we = sfifo_rd_we_512;
  `elsif MODE1024_32
    assign sfifo_rd_we = sfifo_rd_we_1024;
  `endif
  `ifdef MODE1024_32_MODE512_32_MODE256_32_MODE128_32_MODE64_32_MODE32_32
  assign sfifo_rd_we_32   = sfifo_rd_not_full & trans_cnt_en & abt_grant[0];
  `endif
  `ifdef MODE1024_32_MODE512_32_MODE256_32_MODE128_32_MODE64_32
  assign sfifo_rd_we_64   = sfifo_rd_not_full & trans_cnt_en & abt_grant[0] & (cnt_32 == 1'b1);  
  `endif
  `ifdef MODE1024_32_MODE512_32_MODE256_32_MODE128_32
  assign sfifo_rd_we_128  = sfifo_rd_not_full & trans_cnt_en & abt_grant[0] & (cnt_32 == 1'b1) & (cnt_64 == 1'b1);
  `endif
  `ifdef MODE1024_32_MODE512_32_MODE256_32
  assign sfifo_rd_we_256  = sfifo_rd_not_full & trans_cnt_en & abt_grant[0] & (cnt_32 == 1'b1) & (cnt_64 == 1'b1) & (cnt_128 == 1'b1);
  `endif
  `ifdef MODE1024_32_MODE512_32
  assign sfifo_rd_we_512  = sfifo_rd_not_full & trans_cnt_en & abt_grant[0] & (cnt_32 == 1'b1) & (cnt_64 == 1'b1) & (cnt_128 == 1'b1) & (cnt_256 == 1'b1);
  `endif
  `ifdef MODE1024_32
  assign sfifo_rd_we_1024 = sfifo_rd_not_full & trans_cnt_en & abt_grant[0] & (cnt_32 == 1'b1) & (cnt_64 == 1'b1) & (cnt_128 == 1'b1) & (cnt_256 == 1'b1) & (cnt_512 == 1'b1);
  `endif
  //prdata_wrap_apb
  `ifdef MODE32_32
  assign prdata_wrap_apb[DATA_WIDTH_AXI-1:0]     = prdata_wrap_apb_32[DATA_WIDTH_AXI-1:0];
  `elsif MODE64_32
  assign prdata_wrap_apb[DATA_WIDTH_AXI-1:0]     = prdata_wrap_apb_64[DATA_WIDTH_AXI-1:0];
  `elsif MODE128_32
  assign prdata_wrap_apb[DATA_WIDTH_AXI-1:0]     = prdata_wrap_apb_128[DATA_WIDTH_AXI-1:0];
  `elsif MODE256_32
  assign prdata_wrap_apb[DATA_WIDTH_AXI-1:0]     = prdata_wrap_apb_256[DATA_WIDTH_AXI-1:0];
  `elsif MODE512_32
  assign prdata_wrap_apb[DATA_WIDTH_AXI-1:0]     = prdata_wrap_apb_512[DATA_WIDTH_AXI-1:0];
  `elsif MODE1024_32
  assign prdata_wrap_apb[DATA_WIDTH_AXI-1:0]     = prdata_wrap_apb_1024[DATA_WIDTH_AXI-1:0];
  `endif
  `ifdef MODE32_32
  assign prdata_wrap_apb_32[DATA_WIDTH_AXI-1:0]  = prdata_apb[DATA_WIDTH_APB-1:0];
  `endif
  `ifdef MODE64_32
  always_ff @(posedge pclk, negedge preset_n) begin
    if(!preset_n)
	  prdata_wrap_apb_64[31:0] <= 32'd0;
	else if(trans_cnt_en & abt_grant[0] & (cnt_32 == 1'b0))
	  prdata_wrap_apb_64[31:0] <= prdata_apb[DATA_WIDTH_APB-1:0];
  end
  `endif
  `ifdef MODE64_32
  always_comb begin
    if(trans_cnt_en & abt_grant[0] & (cnt_32 == 1'b1))
	  prdata_wrap_apb_64[DATA_WIDTH_AXI-1:32] = prdata_apb[DATA_WIDTH_APB-1:0];
	else
	  prdata_wrap_apb_64[DATA_WIDTH_AXI-1:32] = 32'd0;	  
  end
  `endif
  `ifdef MODE128_32
  always_ff @(posedge pclk, negedge preset_n) begin
    if(!preset_n)
	  prdata_wrap_apb_128[31:0] <= 32'd0;
	else if(trans_cnt_en & abt_grant[0] & (cnt_32 == 1'b0) & (cnt_64 == 1'b0))
	  prdata_wrap_apb_128[31:0] <= prdata_apb[DATA_WIDTH_APB-1:0];
  end
 `endif
  `ifdef MODE128_32 
  always_ff @(posedge pclk, negedge preset_n) begin
    if(!preset_n)
	  prdata_wrap_apb_128[63:32] <= 32'd0;
	else if(trans_cnt_en & abt_grant[0] & (cnt_32 == 1'b1) & (cnt_64 == 1'b0))
	  prdata_wrap_apb_128[63:32] <= prdata_apb[31:0];
  end
  `endif
  `ifdef MODE128_32
  always_ff @(posedge pclk, negedge preset_n) begin
    if(!preset_n)
	  prdata_wrap_apb_128[95:64] <= 32'd0;
	else if(trans_cnt_en & abt_grant[0] & (cnt_32 == 1'b0) & (cnt_64 == 1'b1))
	  prdata_wrap_apb_128[95:64] <= prdata_apb[31:0];
  end
  `endif
  `ifdef MODE128_32
  always_comb begin
    if(trans_cnt_en & abt_grant[0] & (cnt_32 == 1'b1) & (cnt_64 == 1'b1))
	  prdata_wrap_apb_128[DATA_WIDTH_AXI-1:96] = prdata_apb[DATA_WIDTH_APB-1:0];
	else
	  prdata_wrap_apb_128[DATA_WIDTH_AXI-1:96] = 32'd0;	  
  end
  `endif
  `ifdef MODE256_32
  always_ff @(posedge pclk, negedge preset_n) begin
    if(!preset_n)
	  prdata_wrap_apb_256[31:0] <= 32'd0;
	else if(trans_cnt_en & abt_grant[0] & (cnt_32 == 1'b0) & (cnt_64 == 1'b0) & (cnt_128 == 1'b0))
	  prdata_wrap_apb_256[31:0] <= prdata_apb[DATA_WIDTH_APB-1:0];
  end  
  `endif
  `ifdef MODE256_32
  always_ff @(posedge pclk, negedge preset_n) begin
    if(!preset_n)
	  prdata_wrap_apb_256[63:32] <= 32'd0;
	else if(trans_cnt_en & abt_grant[0] & (cnt_32 == 1'b1) & (cnt_64 == 1'b0) & (cnt_128 == 1'b0))
	  prdata_wrap_apb_256[63:32] <= prdata_apb[DATA_WIDTH_APB-1:0];
  end  
  `endif  
  `ifdef MODE256_32
  always_ff @(posedge pclk, negedge preset_n) begin
    if(!preset_n)
	  prdata_wrap_apb_256[95:64] <= 32'd0;
	else if(trans_cnt_en & abt_grant[0] & (cnt_32 == 1'b0) & (cnt_64 == 1'b1) & (cnt_128 == 1'b0))
	  prdata_wrap_apb_256[95:64] <= prdata_apb[DATA_WIDTH_APB-1:0];
  end  
  `endif
  `ifdef MODE256_32
  always_ff @(posedge pclk, negedge preset_n) begin
    if(!preset_n)
	  prdata_wrap_apb_256[127:96] <= 32'd0;
	else if(trans_cnt_en & abt_grant[0] & (cnt_32 == 1'b1) & (cnt_64 == 1'b1) & (cnt_128 == 1'b0))
	  prdata_wrap_apb_256[127:96] <= prdata_apb[DATA_WIDTH_APB-1:0];
  end  
  `endif
  `ifdef MODE256_32
  always_ff @(posedge pclk, negedge preset_n) begin
    if(!preset_n)
	  prdata_wrap_apb_256[159:128] <= 32'd0;
	else if(trans_cnt_en & abt_grant[0] & (cnt_32 == 1'b0) & (cnt_64 == 1'b0) & (cnt_128 == 1'b1))
	  prdata_wrap_apb_256[159:128] <= prdata_apb[DATA_WIDTH_APB-1:0];
  end  
  `endif
  `ifdef MODE256_32
  always_ff @(posedge pclk, negedge preset_n) begin
    if(!preset_n)
	  prdata_wrap_apb_256[191:160] <= 32'd0;
	else if(trans_cnt_en & abt_grant[0] & (cnt_32 == 1'b1) & (cnt_64 == 1'b0) & (cnt_128 == 1'b1))
	  prdata_wrap_apb_256[191:160] <= prdata_apb[DATA_WIDTH_APB-1:0];
  end  
  `endif
  `ifdef MODE256_32
  always_ff @(posedge pclk, negedge preset_n) begin
    if(!preset_n)
	  prdata_wrap_apb_256[223:192] <= 32'd0;
	else if(trans_cnt_en & abt_grant[0] & (cnt_32 == 1'b0) & (cnt_64 == 1'b1) & (cnt_128 == 1'b1))
	  prdata_wrap_apb_256[223:192] <= prdata_apb[DATA_WIDTH_APB-1:0];
  end  
  `endif
  `ifdef MODE256_32
  always_comb begin
    if(trans_cnt_en & abt_grant[0] & (cnt_32 == 1'b1) & (cnt_64 == 1'b1) & (cnt_128 == 1'b1))
	  prdata_wrap_apb_256[DATA_WIDTH_AXI-1:224] = prdata_apb[DATA_WIDTH_APB-1:0];
	else
	  prdata_wrap_apb_256[DATA_WIDTH_AXI-1:224] = 32'd0;	  
  end
  `endif
  `ifdef MODE512_32
  always_ff @(posedge pclk, negedge preset_n) begin
    if(!preset_n)
	  prdata_wrap_apb_512[31:0] <= 32'd0;
	else if(trans_cnt_en & abt_grant[0] & (cnt_32 == 1'b0) & (cnt_64 == 1'b0) & (cnt_128 == 1'b0) & (cnt_256 == 1'b0))
	  prdata_wrap_apb_512[31:0] <= prdata_apb[DATA_WIDTH_APB-1:0];
  end  
  `endif
  `ifdef MODE512_32
  always_ff @(posedge pclk, negedge preset_n) begin
    if(!preset_n)
	  prdata_wrap_apb_512[63:32] <= 32'd0;
	else if(trans_cnt_en & abt_grant[0] & (cnt_32 == 1'b1) & (cnt_64 == 1'b0) & (cnt_128 == 1'b0) & (cnt_256 == 1'b0))
	  prdata_wrap_apb_512[63:32] <= prdata_apb[DATA_WIDTH_APB-1:0];
  end  
  `endif
  `ifdef MODE512_32
  always_ff @(posedge pclk, negedge preset_n) begin
    if(!preset_n)
	  prdata_wrap_apb_512[95:64] <= 32'd0;
	else if(trans_cnt_en & abt_grant[0] & (cnt_32 == 1'b0) & (cnt_64 == 1'b1) & (cnt_128 == 1'b0) & (cnt_256 == 1'b0))
	  prdata_wrap_apb_512[95:64] <= prdata_apb[DATA_WIDTH_APB-1:0];
  end  
  `endif
  `ifdef MODE512_32
  always_ff @(posedge pclk, negedge preset_n) begin
    if(!preset_n)
	  prdata_wrap_apb_512[127:96] <= 32'd0;
	else if(trans_cnt_en & abt_grant[0] & (cnt_32 == 1'b1) & (cnt_64 == 1'b1) & (cnt_128 == 1'b0) & (cnt_256 == 1'b0))
	  prdata_wrap_apb_512[127:96] <= prdata_apb[DATA_WIDTH_APB-1:0];
  end  
  `endif
  `ifdef MODE512_32
  always_ff @(posedge pclk, negedge preset_n) begin
    if(!preset_n)
	  prdata_wrap_apb_512[159:128] <= 32'd0;
	else if(trans_cnt_en & abt_grant[0] & (cnt_32 == 1'b0) & (cnt_64 == 1'b0) & (cnt_128 == 1'b1) & (cnt_256 == 1'b0))
	  prdata_wrap_apb_512[159:128] <= prdata_apb[DATA_WIDTH_APB-1:0];
  end  
  `endif
  `ifdef MODE512_32
  always_ff @(posedge pclk, negedge preset_n) begin
    if(!preset_n)
	  prdata_wrap_apb_512[191:160] <= 32'd0;
	else if(trans_cnt_en & abt_grant[0] & (cnt_32 == 1'b1) & (cnt_64 == 1'b0) & (cnt_128 == 1'b1) & (cnt_256 == 1'b0))
	  prdata_wrap_apb_512[191:160] <= prdata_apb[DATA_WIDTH_APB-1:0];
  end  
  `endif
  `ifdef MODE512_32
  always_ff @(posedge pclk, negedge preset_n) begin
    if(!preset_n)
	  prdata_wrap_apb_512[223:192] <= 32'd0;
	else if(trans_cnt_en & abt_grant[0] & (cnt_32 == 1'b0) & (cnt_64 == 1'b1) & (cnt_128 == 1'b1) & (cnt_256 == 1'b0))
	  prdata_wrap_apb_512[223:192] <= prdata_apb[DATA_WIDTH_APB-1:0];
  end  
  `endif
  `ifdef MODE512_32
  always_ff @(posedge pclk, negedge preset_n) begin
    if(!preset_n)
	  prdata_wrap_apb_512[255:224] <= 32'd0;
	else if(trans_cnt_en & abt_grant[0] & (cnt_32 == 1'b1) & (cnt_64 == 1'b1) & (cnt_128 == 1'b1) & (cnt_256 == 1'b0))
	  prdata_wrap_apb_512[255:224] <= prdata_apb[DATA_WIDTH_APB-1:0];
  end  
  `endif
  `ifdef MODE512_32
  always_ff @(posedge pclk, negedge preset_n) begin
    if(!preset_n)
	  prdata_wrap_apb_512[287:256] <= 32'd0;
	else if(trans_cnt_en & abt_grant[0] & (cnt_32 == 1'b0) & (cnt_64 == 1'b0) & (cnt_128 == 1'b0) & (cnt_256 == 1'b1))
	  prdata_wrap_apb_512[287:256] <= prdata_apb[DATA_WIDTH_APB-1:0];
  end  
  `endif
  `ifdef MODE512_32
  always_ff @(posedge pclk, negedge preset_n) begin
    if(!preset_n)
	  prdata_wrap_apb_512[319:288] <= 32'd0;
	else if(trans_cnt_en & abt_grant[0] & (cnt_32 == 1'b1) & (cnt_64 == 1'b0) & (cnt_128 == 1'b0) & (cnt_256 == 1'b1))
	  prdata_wrap_apb_512[319:288] <= prdata_apb[DATA_WIDTH_APB-1:0];
  end  
  `endif
  `ifdef MODE512_32
  always_ff @(posedge pclk, negedge preset_n) begin
    if(!preset_n)
	  prdata_wrap_apb_512[351:320] <= 32'd0;
	else if(trans_cnt_en & abt_grant[0] & (cnt_32 == 1'b0) & (cnt_64 == 1'b1) & (cnt_128 == 1'b0) & (cnt_256 == 1'b1))
	  prdata_wrap_apb_512[351:320] <= prdata_apb[DATA_WIDTH_APB-1:0];
  end  
  `endif
  `ifdef MODE512_32
  always_ff @(posedge pclk, negedge preset_n) begin
    if(!preset_n)
	  prdata_wrap_apb_512[383:352] <= 32'd0;
	else if(trans_cnt_en & abt_grant[0] & (cnt_32 == 1'b1) & (cnt_64 == 1'b1) & (cnt_128 == 1'b0) & (cnt_256 == 1'b1))
	  prdata_wrap_apb_512[383:352] <= prdata_apb[DATA_WIDTH_APB-1:0];
  end  
  `endif
  `ifdef MODE512_32
  always_ff @(posedge pclk, negedge preset_n) begin
    if(!preset_n)
	  prdata_wrap_apb_512[415:384] <= 32'd0;
	else if(trans_cnt_en & abt_grant[0] & (cnt_32 == 1'b0) & (cnt_64 == 1'b0) & (cnt_128 == 1'b1) & (cnt_256 == 1'b1))
	  prdata_wrap_apb_512[415:384] <= prdata_apb[DATA_WIDTH_APB-1:0];
  end  
  `endif
  `ifdef MODE512_32
  always_ff @(posedge pclk, negedge preset_n) begin
    if(!preset_n)
	  prdata_wrap_apb_512[447:416] <= 32'd0;
	else if(trans_cnt_en & abt_grant[0] & (cnt_32 == 1'b1) & (cnt_64 == 1'b0) & (cnt_128 == 1'b1) & (cnt_256 == 1'b1))
	  prdata_wrap_apb_512[447:416] <= prdata_apb[DATA_WIDTH_APB-1:0];
  end  
  `endif
  `ifdef MODE512_32
  always_ff @(posedge pclk, negedge preset_n) begin
    if(!preset_n)
	  prdata_wrap_apb_512[479:448] <= 32'd0;
	else if(trans_cnt_en & abt_grant[0] & (cnt_32 == 1'b0) & (cnt_64 == 1'b1) & (cnt_128 == 1'b1) & (cnt_256 == 1'b1))
	  prdata_wrap_apb_512[479:448] <= prdata_apb[DATA_WIDTH_APB-1:0];
  end  
  `endif
  `ifdef MODE512_32
  always_comb begin
    if(trans_cnt_en & abt_grant[0] & (cnt_32 == 1'b1) & (cnt_64 == 1'b1) & (cnt_128 == 1'b1) & (cnt_256 == 1'b1))
	  prdata_wrap_apb_512[DATA_WIDTH_AXI-1:480] = prdata_apb[DATA_WIDTH_APB-1:0];
	else
	  prdata_wrap_apb_512[DATA_WIDTH_AXI-1:480] = 32'd0;	  
  end
  `endif
  `ifdef MODE1024_32
  always_ff @(posedge pclk, negedge preset_n) begin
    if(!preset_n)
	  prdata_wrap_apb_1024[31:0] <= 32'd0;
	else if(trans_cnt_en & abt_grant[0] & (cnt_32 == 1'b0) & (cnt_64 == 1'b0) & (cnt_128 == 1'b0) & (cnt_256 == 1'b0) & (cnt_512 == 1'b0))
	  prdata_wrap_apb_1024[31:0] <= prdata_apb[DATA_WIDTH_APB-1:0];
  end  
  `endif
  `ifdef MODE1024_32
  always_ff @(posedge pclk, negedge preset_n) begin
    if(!preset_n)
	  prdata_wrap_apb_1024[63:32] <= 32'd0;
	else if(trans_cnt_en & abt_grant[0] & (cnt_32 == 1'b1) & (cnt_64 == 1'b0) & (cnt_128 == 1'b0) & (cnt_256 == 1'b0) & (cnt_512 == 1'b0))
	  prdata_wrap_apb_1024[63:32] <= prdata_apb[DATA_WIDTH_APB-1:0];
  end  
  `endif
  `ifdef MODE1024_32
  always_ff @(posedge pclk, negedge preset_n) begin
    if(!preset_n)
	  prdata_wrap_apb_1024[95:64] <= 32'd0;
	else if(trans_cnt_en & abt_grant[0] & (cnt_32 == 1'b0) & (cnt_64 == 1'b1) & (cnt_128 == 1'b0) & (cnt_256 == 1'b0) & (cnt_512 == 1'b0))
	  prdata_wrap_apb_1024[95:64] <= prdata_apb[DATA_WIDTH_APB-1:0];
  end  
  `endif
  `ifdef MODE1024_32
  always_ff @(posedge pclk, negedge preset_n) begin
    if(!preset_n)
	  prdata_wrap_apb_1024[127:96] <= 32'd0;
	else if(trans_cnt_en & abt_grant[0] & (cnt_32 == 1'b1) & (cnt_64 == 1'b1) & (cnt_128 == 1'b0) & (cnt_256 == 1'b0) & (cnt_512 == 1'b0))
	  prdata_wrap_apb_1024[127:96] <= prdata_apb[DATA_WIDTH_APB-1:0];
  end  
  `endif
  `ifdef MODE1024_32
  always_ff @(posedge pclk, negedge preset_n) begin
    if(!preset_n)
	  prdata_wrap_apb_1024[159:128] <= 32'd0;
	else if(trans_cnt_en & abt_grant[0] & (cnt_32 == 1'b0) & (cnt_64 == 1'b0) & (cnt_128 == 1'b1) & (cnt_256 == 1'b0) & (cnt_512 == 1'b0))
	  prdata_wrap_apb_1024[159:128] <= prdata_apb[DATA_WIDTH_APB-1:0];
  end  
  `endif
  `ifdef MODE1024_32
  always_ff @(posedge pclk, negedge preset_n) begin
    if(!preset_n)
	  prdata_wrap_apb_1024[191:160] <= 32'd0;
	else if(trans_cnt_en & abt_grant[0] & (cnt_32 == 1'b1) & (cnt_64 == 1'b0) & (cnt_128 == 1'b1) & (cnt_256 == 1'b0) & (cnt_512 == 1'b0))
	  prdata_wrap_apb_1024[191:160] <= prdata_apb[DATA_WIDTH_APB-1:0];
  end  
  `endif
  `ifdef MODE1024_32
  always_ff @(posedge pclk, negedge preset_n) begin
    if(!preset_n)
	  prdata_wrap_apb_1024[223:192] <= 32'd0;
	else if(trans_cnt_en & abt_grant[0] & (cnt_32 == 1'b0) & (cnt_64 == 1'b1) & (cnt_128 == 1'b1) & (cnt_256 == 1'b0) & (cnt_512 == 1'b0))
	  prdata_wrap_apb_1024[223:192] <= prdata_apb[DATA_WIDTH_APB-1:0];
  end  
  `endif
  `ifdef MODE1024_32
  always_ff @(posedge pclk, negedge preset_n) begin
    if(!preset_n)
	  prdata_wrap_apb_1024[255:224] <= 32'd0;
	else if(trans_cnt_en & abt_grant[0] & (cnt_32 == 1'b1) & (cnt_64 == 1'b1) & (cnt_128 == 1'b1) & (cnt_256 == 1'b0) & (cnt_512 == 1'b0))
	  prdata_wrap_apb_1024[255:224] <= prdata_apb[DATA_WIDTH_APB-1:0];
  end  
  `endif
  `ifdef MODE1024_32
  always_ff @(posedge pclk, negedge preset_n) begin
    if(!preset_n)
	  prdata_wrap_apb_1024[287:256] <= 32'd0;
	else if(trans_cnt_en & abt_grant[0] & (cnt_32 == 1'b0) & (cnt_64 == 1'b0) & (cnt_128 == 1'b0) & (cnt_256 == 1'b1) & (cnt_512 == 1'b0))
	  prdata_wrap_apb_1024[287:256] <= prdata_apb[DATA_WIDTH_APB-1:0];
  end  
  `endif
  `ifdef MODE1024_32
  always_ff @(posedge pclk, negedge preset_n) begin
    if(!preset_n)
	  prdata_wrap_apb_1024[319:288] <= 32'd0;
	else if(trans_cnt_en & abt_grant[0] & (cnt_32
	== 1'b1) & (cnt_64 == 1'b0) & (cnt_128 == 1'b0) & (cnt_256 == 1'b1) & (cnt_512 == 1'b0))
	  prdata_wrap_apb_1024[319:288] <= prdata_apb[DATA_WIDTH_APB-1:0];
  end  
  `endif
  `ifdef MODE1024_32
  always_ff @(posedge pclk, negedge preset_n) begin
    if(!preset_n)
	  prdata_wrap_apb_1024[351:320] <= 32'd0;
	else if(trans_cnt_en & abt_grant[0] & (cnt_32 == 1'b0) & (cnt_64 == 1'b1) & (cnt_128 == 1'b0) & (cnt_256 == 1'b1) & (cnt_512 == 1'b0))
	  prdata_wrap_apb_1024[351:320] <= prdata_apb[DATA_WIDTH_APB-1:0];
  end  
  `endif
  `ifdef MODE1024_32
  always_ff @(posedge pclk, negedge preset_n) begin
    if(!preset_n)
	  prdata_wrap_apb_1024[383:352] <= 32'd0;
	else if(trans_cnt_en & abt_grant[0] & (cnt_32 == 1'b1) & (cnt_64 == 1'b1) & (cnt_128 == 1'b0) & (cnt_256 == 1'b1) & (cnt_512 == 1'b0))
	  prdata_wrap_apb_1024[383:352] <= prdata_apb[DATA_WIDTH_APB-1:0];
  end  
  `endif
  `ifdef MODE1024_32
  always_ff @(posedge pclk, negedge preset_n) begin
    if(!preset_n)
	  prdata_wrap_apb_1024[415:384] <= 32'd0;
	else if(trans_cnt_en & abt_grant[0] & (cnt_32 == 1'b0) & (cnt_64 == 1'b0) & (cnt_128 == 1'b1) & (cnt_256 == 1'b1) & (cnt_512 == 1'b0))
	  prdata_wrap_apb_1024[415:384] <= prdata_apb[DATA_WIDTH_APB-1:0];
  end  
  `endif
  `ifdef MODE1024_32
  always_ff @(posedge pclk, negedge preset_n) begin
    if(!preset_n)
	  prdata_wrap_apb_1024[447:416] <= 32'd0;
	else if(trans_cnt_en & abt_grant[0] & (cnt_32 == 1'b1) & (cnt_64 == 1'b0) & (cnt_128 == 1'b1) & (cnt_256 == 1'b1) & (cnt_512 == 1'b0))
	  prdata_wrap_apb_1024[447:416] <= prdata_apb[DATA_WIDTH_APB-1:0];
  end  
  `endif
  `ifdef MODE1024_32
  always_ff @(posedge pclk, negedge preset_n) begin
    if(!preset_n)
	  prdata_wrap_apb_1024[479:448] <= 32'd0;
	else if(trans_cnt_en & abt_grant[0] & (cnt_32 == 1'b0) & (cnt_64 == 1'b1) & (cnt_128 == 1'b1) & (cnt_256 == 1'b1) & (cnt_512 == 1'b0))
	  prdata_wrap_apb_1024[479:448] <= prdata_apb[DATA_WIDTH_APB-1:0];
  end  
  `endif
  `ifdef MODE1024_32
  always_ff @(posedge pclk, negedge preset_n) begin
    if(!preset_n)
	  prdata_wrap_apb_1024[511:480] <= 32'd0;
	else if(trans_cnt_en & abt_grant[0] & (cnt_32 == 1'b1) & (cnt_64 == 1'b1) & (cnt_128 == 1'b1) & (cnt_256 == 1'b1) & (cnt_512 == 1'b0))
	  prdata_wrap_apb_1024[511:480] <= prdata_apb[DATA_WIDTH_APB-1:0];
  end  
  `endif
  `ifdef MODE1024_32
  always_ff @(posedge pclk, negedge preset_n) begin
    if(!preset_n)
	  prdata_wrap_apb_1024[543:512] <= 32'd0;
	else if(trans_cnt_en & abt_grant[0] & (cnt_32 == 1'b0) & (cnt_64 == 1'b0) & (cnt_128 == 1'b0) & (cnt_256 == 1'b0) & (cnt_512 == 1'b1))
	  prdata_wrap_apb_1024[543:512] <= prdata_apb[DATA_WIDTH_APB-1:0];
  end  
  `endif
  `ifdef MODE1024_32
  always_ff @(posedge pclk, negedge preset_n) begin
    if(!preset_n)
	  prdata_wrap_apb_1024[575:544] <= 32'd0;
	else if(trans_cnt_en & abt_grant[0] & (cnt_32 == 1'b1) & (cnt_64 == 1'b0) & (cnt_128 == 1'b0) & (cnt_256 == 1'b0) & (cnt_512 == 1'b1))
	  prdata_wrap_apb_1024[575:544] <= prdata_apb[DATA_WIDTH_APB-1:0];
  end  
  `endif
  `ifdef MODE1024_32
  always_ff @(posedge pclk, negedge preset_n) begin
    if(!preset_n)
	  prdata_wrap_apb_1024[607:576] <= 32'd0;
	else if(trans_cnt_en & abt_grant[0] & (cnt_32 == 1'b0) & (cnt_64 == 1'b1) & (cnt_128 == 1'b0) & (cnt_256 == 1'b0) & (cnt_512 == 1'b1))
	  prdata_wrap_apb_1024[607:576] <= prdata_apb[DATA_WIDTH_APB-1:0];
  end  
  `endif
  `ifdef MODE1024_32
  always_ff @(posedge pclk, negedge preset_n) begin
    if(!preset_n)
	  prdata_wrap_apb_1024[639:608] <= 32'd0;
	else if(trans_cnt_en & abt_grant[0] & (cnt_32 == 1'b1) & (cnt_64 == 1'b1) & (cnt_128 == 1'b0) & (cnt_256 == 1'b0) & (cnt_512 == 1'b1))
	  prdata_wrap_apb_1024[639:608] <= prdata_apb[DATA_WIDTH_APB-1:0];
  end  
  `endif
  `ifdef MODE1024_32
  always_ff @(posedge pclk, negedge preset_n) begin
    if(!preset_n)
	  prdata_wrap_apb_1024[671:640] <= 32'd0;
	else if(trans_cnt_en & abt_grant[0] & (cnt_32 == 1'b0) & (cnt_64 == 1'b0) & (cnt_128 == 1'b1) & (cnt_256 == 1'b0) & (cnt_512 == 1'b1))
	  prdata_wrap_apb_1024[671:640] <= prdata_apb[DATA_WIDTH_APB-1:0];
  end  
  `endif
  `ifdef MODE1024_32
  always_ff @(posedge pclk, negedge preset_n) begin
    if(!preset_n)
	  prdata_wrap_apb_1024[703:672] <= 32'd0;
	else if(trans_cnt_en & abt_grant[0] & (cnt_32 == 1'b1) & (cnt_64 == 1'b0) & (cnt_128 == 1'b1) & (cnt_256 == 1'b0) & (cnt_512 == 1'b1))
	  prdata_wrap_apb_1024[703:672] <= prdata_apb[DATA_WIDTH_APB-1:0];
  end  
  `endif
  `ifdef MODE1024_32
  always_ff @(posedge pclk, negedge preset_n) begin
    if(!preset_n)
	  prdata_wrap_apb_1024[735:704] <= 32'd0;
	else if(trans_cnt_en & abt_grant[0] & (cnt_32 == 1'b0) & (cnt_64 == 1'b1) & (cnt_128 == 1'b1) & (cnt_256 == 1'b0) & (cnt_512 == 1'b1))
	  prdata_wrap_apb_1024[735:704] <= prdata_apb[DATA_WIDTH_APB-1:0];
  end  
  `endif
  `ifdef MODE1024_32
  always_ff @(posedge pclk, negedge preset_n) begin
    if(!preset_n)
	  prdata_wrap_apb_1024[767:736] <= 32'd0;
	else if(trans_cnt_en & abt_grant[0] & (cnt_32 == 1'b1) & (cnt_64 == 1'b1) & (cnt_128 == 1'b1) & (cnt_256 == 1'b0) & (cnt_512 == 1'b1))
	  prdata_wrap_apb_1024[767:736] <= prdata_apb[DATA_WIDTH_APB-1:0];
  end  
  `endif
  `ifdef MODE1024_32
  always_ff @(posedge pclk, negedge preset_n) begin
    if(!preset_n)
	  prdata_wrap_apb_1024[799:768] <= 32'd0;
	else if(trans_cnt_en & abt_grant[0] & (cnt_32 == 1'b0) & (cnt_64 == 1'b0) & (cnt_128 == 1'b0) & (cnt_256 == 1'b1) & (cnt_512 == 1'b1))
	  prdata_wrap_apb_1024[799:768] <= prdata_apb[DATA_WIDTH_APB-1:0];
  end  
  `endif
  `ifdef MODE1024_32
  always_ff @(posedge pclk, negedge preset_n) begin
    if(!preset_n)
	  prdata_wrap_apb_1024[831:800] <= 32'd0;
	else if(trans_cnt_en & abt_grant[0] & (cnt_32 == 1'b1) & (cnt_64 == 1'b0) & (cnt_128 == 1'b0) & (cnt_256 == 1'b1) & (cnt_512 == 1'b1))
	  prdata_wrap_apb_1024[831:800] <= prdata_apb[DATA_WIDTH_APB-1:0];
  end  
  `endif
  `ifdef MODE1024_32
  always_ff @(posedge pclk, negedge preset_n) begin
    if(!preset_n)
	  prdata_wrap_apb_1024[863:832] <= 32'd0;
	else if(trans_cnt_en & abt_grant[0] & (cnt_32 == 1'b0) & (cnt_64 == 1'b1) & (cnt_128 == 1'b0) & (cnt_256 == 1'b1) & (cnt_512 == 1'b1))
	  prdata_wrap_apb_1024[863:832] <= prdata_apb[DATA_WIDTH_APB-1:0];
  end  
  `endif
  `ifdef MODE1024_32
  always_ff @(posedge pclk, negedge preset_n) begin
    if(!preset_n)
	  prdata_wrap_apb_1024[895:864] <= 32'd0;
	else if(trans_cnt_en & abt_grant[0] & (cnt_32 == 1'b1) & (cnt_64 == 1'b1) & (cnt_128 == 1'b0) & (cnt_256 == 1'b1) & (cnt_512 == 1'b1))
	  prdata_wrap_apb_1024[895:864] <= prdata_apb[DATA_WIDTH_APB-1:0];
  end  
  `endif
  `ifdef MODE1024_32
  always_ff @(posedge pclk, negedge preset_n) begin
    if(!preset_n)
	  prdata_wrap_apb_1024[927:896] <= 32'd0;
	else if(trans_cnt_en & abt_grant[0] & (cnt_32 == 1'b0) & (cnt_64 == 1'b0) & (cnt_128 == 1'b1) & (cnt_256 == 1'b1) & (cnt_512 == 1'b1))
	  prdata_wrap_apb_1024[927:896] <= prdata_apb[DATA_WIDTH_APB-1:0];
  end  
  `endif
  `ifdef MODE1024_32
  always_ff @(posedge pclk, negedge preset_n) begin
    if(!preset_n)
	  prdata_wrap_apb_1024[959:928] <= 32'd0;
	else if(trans_cnt_en & abt_grant[0] & (cnt_32 == 1'b1) & (cnt_64 == 1'b0) & (cnt_128 == 1'b1) & (cnt_256 == 1'b1) & (cnt_512 == 1'b1))
	  prdata_wrap_apb_1024[959:928] <= prdata_apb[DATA_WIDTH_APB-1:0];
  end  
  `endif
  `ifdef MODE1024_32
  always_ff @(posedge pclk, negedge preset_n) begin
    if(!preset_n)
	  prdata_wrap_apb_1024[991:960] <= 32'd0;
	else if(trans_cnt_en & abt_grant[0] & (cnt_32 == 1'b0) & (cnt_64 == 1'b1) & (cnt_128 == 1'b1) & (cnt_256 == 1'b1) & (cnt_512 == 1'b1))
	  prdata_wrap_apb_1024[991:960] <= prdata_apb[DATA_WIDTH_APB-1:0];
  end  
  `endif
  `ifdef MODE1024_32
  always_comb begin
    if(trans_cnt_en & abt_grant[0] & (cnt_32 == 1'b1) & (cnt_64 == 1'b1) & (cnt_128 == 1'b1) & (cnt_256 == 1'b1) & (cnt_512 == 1'b1))
	  prdata_wrap_apb_1024[DATA_WIDTH_AXI-1:992] = prdata_apb[DATA_WIDTH_APB-1:0];
	else
	  prdata_wrap_apb_1024[DATA_WIDTH_AXI-1:992] = 32'd0;	  
  end
  `endif
  //RD_CH
  //rch_rresp
  always_comb begin
    if(~pslverr_apb)
	  rch_rresp = OKAY;
	else if(dec_error)
	  rch_rresp = DECERR;
	else
	  rch_rresp = PSLVERR;
  end
  //rlast
  always_ff @(posedge pclk, negedge preset_n) begin
    if(!preset_n)
	  rlast <= 1'b0;
	else if(transaction_completed & abt_grant[0])
	  rlast = 1'b1;
	else
      rlast = 1'b0;	
  end
  //transfer_en
  `ifdef MODE32_32
    assign transfer_en = transfer_en_32;
  `elsif MODE64_32
    assign transfer_en = transfer_en_64;
  `elsif MODE128_32
    assign transfer_en = transfer_en_128;
  `elsif MODE256_32
    assign transfer_en = transfer_en_256;
  `elsif MODE512_32
    assign transfer_en = transfer_en_512;
  `elsif MODE1024_32
    assign transfer_en = transfer_en_1024;
  `endif
  `ifdef MODE32_32
  assign transfer_en_32 = sfifo_rd_we_32 | (sfifo_rd_not_full & trans_cnt_en & abt_grant[1]);
  `endif
  `ifdef MODE64_32
  assign transfer_en_64 = sfifo_rd_we_64 | (sfifo_rd_not_full & trans_cnt_en & abt_grant[1] & (cnt_32 == 1'b0));
  `endif
  `ifdef MODE128_32
  assign transfer_en_128 = sfifo_rd_we_128 | (sfifo_rd_not_full & trans_cnt_en & abt_grant[1] & (cnt_32 == 1'b0) & (cnt_64 == 1'b0));
  `endif
  `ifdef MODE256_32
  assign transfer_en_256 = sfifo_rd_we_256 | (sfifo_rd_not_full & trans_cnt_en & abt_grant[1] & (cnt_32 == 1'b0) & (cnt_64 == 1'b0) & (cnt_128 == 1'b0));
  `endif
  `ifdef MODE512_32
  assign transfer_en_512 = sfifo_rd_we_512 | (sfifo_rd_not_full & trans_cnt_en & abt_grant[1] & (cnt_32 == 1'b0) & (cnt_64 == 1'b0) & (cnt_128 == 1'b0) & (cnt_256 == 1'b0));
  `endif
  `ifdef MODE1024_32
  assign transfer_en_1024 = sfifo_rd_we_1024 | (sfifo_rd_not_full & trans_cnt_en & abt_grant[1] & (cnt_32 == 1'b0) & (cnt_64 == 1'b0) & (cnt_128 == 1'b0) & (cnt_256 == 1'b0) & (cnt_512 == 1'b0));
  `endif
  //X2P_SFIFO_AW
  sfifo #(.DATA_WIDTH(X2P_SFIFO_AW_DATA_WIDTH), .POINTER_WIDTH(POINTER_WIDTH)) aw_sfifo(
  .clk(aclk),
  .rst_n(aresetn),
  .wr(sfifo_aw_we),
  .rd(sfifo_aw_re),
  .data_in({awaddr[ADDR_WIDTH-1:0], awid[ID_WIDTH-1:0], awlen[LEN_WIDTH-1:0], awsize[SIZE_WIDTH-1:0], awburst[1:0], awprot[2:0]}),
  .sfifo_empty(sfifo_aw_empty),
  .sfifo_full(sfifo_aw_full),
  .data_out({sfifo_aw_awaddr[ADDR_WIDTH-1:0], sfifo_aw_awid[ID_WIDTH-1:0], sfifo_aw_ctrl_awlen[LEN_WIDTH-1:0], sfifo_aw_ctrl_awsize[SIZE_WIDTH-1:0], sfifo_aw_ctrl_awburst[1:0], sfifo_aw_ctrl_awprot[2:0]})
  );
  //Logic
  assign sfifo_aw_not_full  = ~sfifo_aw_full;
  assign sfifo_aw_not_empty = ~sfifo_aw_empty;
  assign awready         = sfifo_aw_not_full;
  assign sfifo_aw_we       = awready & awvalid;
  assign sfifo_aw_re       = sfifo_aw_not_empty & transaction_completed & abt_grant[1];
  //X2P_SFIFO_WD
  sfifo #(.DATA_WIDTH(X2P_SFIFO_WD_DATA_WIDTH), .POINTER_WIDTH(POINTER_WIDTH)) wd_sfifo(
  .clk(aclk),
  .rst_n(aresetn),
  .wr(sfifo_wd_we),
  .rd(sfifo_wd_re),
  .data_in({wdata[DATA_WIDTH_AXI-1:0], wstrb[DATA_WIDTH_AXI/8-1:0]}),
  .sfifo_empty(sfifo_wd_empty),
  .sfifo_full(sfifo_wd_full),
  .data_out({sfifo_wd_wdata[DATA_WIDTH_AXI-1:0], sfifo_wd_wstrb[DATA_WIDTH_AXI/8-1:0]})
  );
  //logic
  assign sfifo_wd_not_full  = ~sfifo_wd_full;
  assign sfifo_wd_not_empty = ~sfifo_wd_empty;
  assign wready             = sfifo_wd_not_full;
  assign sfifo_wd_we        = wvalid & wready;
  `ifdef MODE32_32
    assign sfifo_wd_re = sfifo_wd_re_32;
  `elsif MODE64_32
    assign sfifo_wd_re = sfifo_wd_re_64;
  `elsif MODE128_32
    assign sfifo_wd_re = sfifo_wd_re_128;
  `elsif MODE256_32
    assign sfifo_wd_re = sfifo_wd_re_256;
  `elsif MODE512_32
    assign sfifo_wd_re = sfifo_wd_re_512;
  `elsif MODE1024_32
    assign sfifo_wd_re = sfifo_wd_re_1024;
  `endif
  `ifdef MODE1024_32_MODE512_32_MODE256_32_MODE128_32_MODE64_32_MODE32_32
//  assign sfifo_wd_re_32   = sfifo_wd_not_empty & abt_grant[1] & (current_state == SETUP);  
  assign sfifo_wd_re_32   = sfifo_wd_not_empty & abt_grant[1] & trans_cnt_en | (sfifo_wd_not_empty & abt_grant[1] & (current_state == IDLE) & transfer);
  `endif
  `ifdef MODE1024_32_MODE512_32_MODE256_32_MODE128_32_MODE64_32
  assign sfifo_wd_re_64   = sfifo_wd_not_empty & abt_grant[1] & trans_cnt_en & (cnt_32 == 1'b1);
  `endif
  `ifdef MODE1024_32_MODE512_32_MODE256_32_MODE128_32
  assign sfifo_wd_re_128  = sfifo_wd_not_empty & abt_grant[1] & trans_cnt_en & (cnt_32 == 1'b1) & (cnt_64 == 1'b1);
  `endif
  `ifdef MODE1024_32_MODE512_32_MODE256_32
  assign sfifo_wd_re_256  = sfifo_wd_not_empty & abt_grant[1] & trans_cnt_en & (cnt_32 == 1'b1) & (cnt_64 == 1'b1) & (cnt_128 == 1'b1);
  `endif
  `ifdef MODE1024_32_MODE512_32
  assign sfifo_wd_re_512  = sfifo_wd_not_empty & abt_grant[1] & trans_cnt_en & (cnt_32 == 1'b1) & (cnt_64 == 1'b1) & (cnt_128 == 1'b1) & (cnt_256 == 1'b1);
  `endif
  `ifdef MODE1024_32
  assign sfifo_wd_re_1024 = sfifo_wd_not_empty & abt_grant[1] & trans_cnt_en & (cnt_32 == 1'b1) & (cnt_64 == 1'b1) & (cnt_128 == 1'b1) & (cnt_256 == 1'b1) & (cnt_512 == 1'b1);
  `endif
  //B_CH
  //bresp
  always_ff @(posedge aclk, negedge aresetn) begin
    if(~aresetn)
	  bresp[1:0] <= OKAY;
    else if(transaction_completed & abt_grant[1]) begin
	  if(~pslverr_apb)
	    bresp[1:0] <= OKAY;
	  else if(dec_error)
	    bresp[1:0] <= DECERR;
      else
	    bresp[1:0] <= PSLVERR;
	end
  end
  //bid
  always_ff @(posedge aclk, negedge aresetn) begin
    if(~aresetn)
	  bid[ID_WIDTH-1:0] <= {ID_WIDTH{1'b0}};
    else if(transaction_completed & abt_grant[1])
	  bid[ID_WIDTH-1:0] <= sfifo_aw_awid[ID_WIDTH-1:0];
  end
  //bvalid
  always_ff @(posedge aclk, negedge aresetn) begin
    if(~aresetn)
	  bvalid <= 1'b0;
	else if(bvalid)
	  bvalid <= 1'b0;
	else if(transaction_completed & abt_grant[1])
	  bvalid <= 1'b1;
  end
  //checked to here
  //ARBITER
  //next_sel0
  always_comb begin
    if(abt_grant[0])
	  next_sel[0] = 1'b1;
	else if(~next_sel[1])
	  next_sel[0] = 1'b0;
	else if(sfifo_ar_not_empty)
	  next_sel[0] = 1'b0;
	else
	  next_sel[0] = 1'b1;
  end
  //next_sel1
  always_comb begin
    if(abt_grant[1])
	  next_sel[1] = 1'b1;
	else if(~next_sel[0])
	  next_sel[1] = 1'b0;
	else if(sfifo_aw_not_empty)
	  next_sel[1] = 1'b0;
	else
	  next_sel[1] = 1'b1;
  end
  //next_grant[1]
  always_comb begin
    if(~next_sel[0])
	  next_grant[1] = 1'b0;
	else if(sfifo_aw_not_empty)
	  next_grant[1] = 1'b1;
	else
	  next_grant[1] = abt_grant[1];
  end
  //next_grant[0]
  always_comb begin
    if(~next_sel[1])
	  next_grant[0] = 1'b0;
	else if(sfifo_ar_not_empty)
	  next_grant[0] = 1'b1;
	else
	  next_grant[0] = abt_grant[0];
  end
  //abt_grant
  assign update = (abt_grant[0] & sfifo_aw_not_empty & ~sfifo_ar_not_empty) | transaction_completed;
  always_ff @(posedge aclk, negedge aresetn) begin
    if(!aresetn) begin
	   abt_grant[1:0] <= 2'b01;
	end
	else if(update) begin
	   abt_grant[1:0] <= next_grant[1:0];
    end		
  end
  //X2P_DECODER
  //start_addr
  assign start_addr[ADDR_WIDTH-1:0] = abt_grant[0] ? sfifo_ar_araddr[ADDR_WIDTH-1:0] : sfifo_aw_awaddr[ADDR_WIDTH-1:0];
  //sel[SLAVE_NUM-1:0]
  generate
    if(SLAVE_NUM >= 1) begin
	  assign sel_reg = (start_addr[ADDR_WIDTH-1:0] >= A_START_REG)     & (start_addr[ADDR_WIDTH-1:0] <= A_END_REG);
	  assign sel[0]  = (start_addr[ADDR_WIDTH-1:0] >= A_START_SLAVE0)  & (start_addr[ADDR_WIDTH-1:0] <= A_END_SLAVE0);
	end
	if(SLAVE_NUM >= 2) begin
	  assign sel[1]  = (start_addr[ADDR_WIDTH-1:0] >= A_START_SLAVE1)  & (start_addr[ADDR_WIDTH-1:0] <= A_END_SLAVE1);
	end
	if(SLAVE_NUM >= 3) begin
	  assign sel[2]  = (start_addr[ADDR_WIDTH-1:0] >= A_START_SLAVE2)  & (start_addr[ADDR_WIDTH-1:0] <= A_END_SLAVE2);
	end
	if(SLAVE_NUM >= 4) begin
	  assign sel[3]  = (start_addr[ADDR_WIDTH-1:0] >= A_START_SLAVE3)  & (start_addr[ADDR_WIDTH-1:0] <= A_END_SLAVE3);
	end
	if(SLAVE_NUM >= 5) begin
      assign sel[4]  = (start_addr[ADDR_WIDTH-1:0] >= A_START_SLAVE4)  & (start_addr[ADDR_WIDTH-1:0] <= A_END_SLAVE4);
	end
	if(SLAVE_NUM >= 6) begin
	  assign sel[5]  = (start_addr[ADDR_WIDTH-1:0] >= A_START_SLAVE5)  & (start_addr[ADDR_WIDTH-1:0] <= A_END_SLAVE5);
	end
	if(SLAVE_NUM >= 7) begin
      assign sel[6]  = (start_addr[ADDR_WIDTH-1:0] >= A_START_SLAVE6)  & (start_addr[ADDR_WIDTH-1:0] <= A_END_SLAVE6);
    end
	if(SLAVE_NUM >= 8) begin
      assign sel[7]  = (start_addr[ADDR_WIDTH-1:0] >= A_START_SLAVE7)  & (start_addr[ADDR_WIDTH-1:0] <= A_END_SLAVE7);
    end
	if(SLAVE_NUM >= 9) begin
	  assign sel[8]  = (start_addr[ADDR_WIDTH-1:0] >= A_START_SLAVE8)  & (start_addr[ADDR_WIDTH-1:0] <= A_END_SLAVE8);
	end
	if(SLAVE_NUM >= 10) begin
	  assign sel[9]  = (start_addr[ADDR_WIDTH-1:0] >= A_START_SLAVE9) & (start_addr[ADDR_WIDTH-1:0] <= A_END_SLAVE9);
	end
	if(SLAVE_NUM >= 11) begin
	  assign sel[10] = (start_addr[ADDR_WIDTH-1:0] >= A_START_SLAVE10) & (start_addr[ADDR_WIDTH-1:0] <= A_END_SLAVE10);
	end
	if(SLAVE_NUM >= 12) begin
	  assign sel[11] = (start_addr[ADDR_WIDTH-1:0] >= A_START_SLAVE11) & (start_addr[ADDR_WIDTH-1:0] <= A_END_SLAVE11);
	end
	if(SLAVE_NUM >= 13) begin
      assign sel[12] = (start_addr[ADDR_WIDTH-1:0] >= A_START_SLAVE12) & (start_addr[ADDR_WIDTH-1:0] <= A_END_SLAVE12);
	end
	if(SLAVE_NUM >= 14) begin
	  assign sel[13] = (start_addr[ADDR_WIDTH-1:0] >= A_START_SLAVE13) & (start_addr[ADDR_WIDTH-1:0] <= A_END_SLAVE13);
	end
	if(SLAVE_NUM >= 15) begin
      assign sel[14] = (start_addr[ADDR_WIDTH-1:0] >= A_START_SLAVE14) & (start_addr[ADDR_WIDTH-1:0] <= A_END_SLAVE14);
    end
	if(SLAVE_NUM >= 16) begin
      assign sel[15] = (start_addr[ADDR_WIDTH-1:0] >= A_START_SLAVE15) & (start_addr[ADDR_WIDTH-1:0] <= A_END_SLAVE15);
    end
	if(SLAVE_NUM >= 17) begin
	  assign sel[16] = (start_addr[ADDR_WIDTH-1:0] >= A_START_SLAVE16) & (start_addr[ADDR_WIDTH-1:0] <= A_END_SLAVE16);
	end
	if(SLAVE_NUM >= 18) begin
	  assign sel[17] = (start_addr[ADDR_WIDTH-1:0] >= A_START_SLAVE17) & (start_addr[ADDR_WIDTH-1:0] <= A_END_SLAVE17);
	end
	if(SLAVE_NUM >= 19) begin
	  assign sel[18] = (start_addr[ADDR_WIDTH-1:0] >= A_START_SLAVE18) & (start_addr[ADDR_WIDTH-1:0] <= A_END_SLAVE18);
    end
	if(SLAVE_NUM >= 20) begin
	  assign sel[19] = (start_addr[ADDR_WIDTH-1:0] >= A_START_SLAVE19) & (start_addr[ADDR_WIDTH-1:0] <= A_END_SLAVE19);
	end
	if(SLAVE_NUM >= 21) begin
      assign sel[20] = (start_addr[ADDR_WIDTH-1:0] >= A_START_SLAVE20) & (start_addr[ADDR_WIDTH-1:0] <= A_END_SLAVE20);
	end
	if(SLAVE_NUM >= 22) begin
	  assign sel[21] = (start_addr[ADDR_WIDTH-1:0] >= A_START_SLAVE21) & (start_addr[ADDR_WIDTH-1:0] <= A_END_SLAVE21);
	end
	if(SLAVE_NUM >= 23) begin
      assign sel[22] = (start_addr[ADDR_WIDTH-1:0] >= A_START_SLAVE22) & (start_addr[ADDR_WIDTH-1:0] <= A_END_SLAVE22);
    end
	if(SLAVE_NUM >= 24) begin
      assign sel[23] = (start_addr[ADDR_WIDTH-1:0] >= A_START_SLAVE23) & (start_addr[ADDR_WIDTH-1:0] <= A_END_SLAVE23);
    end
	if(SLAVE_NUM >= 25) begin
	  assign sel[24] = (start_addr[ADDR_WIDTH-1:0] >= A_START_SLAVE24) & (start_addr[ADDR_WIDTH-1:0] <= A_END_SLAVE24);
	end
	if(SLAVE_NUM >= 26) begin
	  assign sel[25] = (start_addr[ADDR_WIDTH-1:0] >= A_START_SLAVE25) & (start_addr[ADDR_WIDTH-1:0] <= A_END_SLAVE25);
	end
	if(SLAVE_NUM >= 27) begin
	  assign sel[26] = (start_addr[ADDR_WIDTH-1:0] >= A_START_SLAVE26) & (start_addr[ADDR_WIDTH-1:0] <= A_END_SLAVE26);
	end
	if(SLAVE_NUM >= 28) begin
	  assign sel[27] = (start_addr[ADDR_WIDTH-1:0] >= A_START_SLAVE27) & (start_addr[ADDR_WIDTH-1:0] <= A_END_SLAVE27);
	end
	if(SLAVE_NUM >= 29) begin
      assign sel[28] = (start_addr[ADDR_WIDTH-1:0] >= A_START_SLAVE28) & (start_addr[ADDR_WIDTH-1:0] <= A_END_SLAVE28);
	end
	if(SLAVE_NUM >= 30) begin
	  assign sel[29] = (start_addr[ADDR_WIDTH-1:0] >= A_START_SLAVE29) & (start_addr[ADDR_WIDTH-1:0] <= A_END_SLAVE29);
    end
	if(SLAVE_NUM >= 31) begin
      assign sel[30] = (start_addr[ADDR_WIDTH-1:0] >= A_START_SLAVE30) & (start_addr[ADDR_WIDTH-1:0] <= A_END_SLAVE30);
    end
	if(SLAVE_NUM == 32) begin
      assign sel[31] = (start_addr[ADDR_WIDTH-1:0] >= A_START_SLAVE31) & (start_addr[ADDR_WIDTH-1:0] <= A_END_SLAVE31);
    end	  
  endgenerate

  //select_reserve
  generate
    if(SLAVE_NUM == 1)
	  assign select_reserve  = (start_addr[ADDR_WIDTH-1:0] < A_START_REG)|(start_addr[ADDR_WIDTH-1:0] > A_END_SLAVE0);
	if(SLAVE_NUM == 2)
	  assign select_reserve  = (start_addr[ADDR_WIDTH-1:0] < A_START_REG)|(start_addr[ADDR_WIDTH-1:0] > A_END_SLAVE1);
	if(SLAVE_NUM == 3)
	  assign select_reserve  = (start_addr[ADDR_WIDTH-1:0] < A_START_REG)|(start_addr[ADDR_WIDTH-1:0] > A_END_SLAVE2);
	if(SLAVE_NUM == 4)
	  assign select_reserve  = (start_addr[ADDR_WIDTH-1:0] < A_START_REG)|(start_addr[ADDR_WIDTH-1:0] > A_END_SLAVE3);
    if(SLAVE_NUM == 5)
	  assign select_reserve  = (start_addr[ADDR_WIDTH-1:0] < A_START_REG)|(start_addr[ADDR_WIDTH-1:0] > A_END_SLAVE4);
	if(SLAVE_NUM == 6)
	  assign select_reserve  = (start_addr[ADDR_WIDTH-1:0] < A_START_REG)|(start_addr[ADDR_WIDTH-1:0] > A_END_SLAVE5);
	if(SLAVE_NUM == 7)
	  assign select_reserve  = (start_addr[ADDR_WIDTH-1:0] < A_START_REG)|(start_addr[ADDR_WIDTH-1:0] > A_END_SLAVE6);
	if(SLAVE_NUM == 8)
	  assign select_reserve  = (start_addr[ADDR_WIDTH-1:0] < A_START_REG)|(start_addr[ADDR_WIDTH-1:0] > A_END_SLAVE7);
    if(SLAVE_NUM == 9)
	  assign select_reserve  = (start_addr[ADDR_WIDTH-1:0] < A_START_REG)|(start_addr[ADDR_WIDTH-1:0] > A_END_SLAVE8);
	if(SLAVE_NUM == 10)
	  assign select_reserve  = (start_addr[ADDR_WIDTH-1:0] < A_START_REG)|(start_addr[ADDR_WIDTH-1:0] > A_END_SLAVE9);
	if(SLAVE_NUM == 11)
	  assign select_reserve  = (start_addr[ADDR_WIDTH-1:0] < A_START_REG)|(start_addr[ADDR_WIDTH-1:0] > A_END_SLAVE10);
	if(SLAVE_NUM == 12)
	  assign select_reserve  = (start_addr[ADDR_WIDTH-1:0] < A_START_REG)|(start_addr[ADDR_WIDTH-1:0] > A_END_SLAVE11);
    if(SLAVE_NUM == 13)
	  assign select_reserve  = (start_addr[ADDR_WIDTH-1:0] < A_START_REG)|(start_addr[ADDR_WIDTH-1:0] > A_END_SLAVE12);
	if(SLAVE_NUM == 14)
	  assign select_reserve  = (start_addr[ADDR_WIDTH-1:0] < A_START_REG)|(start_addr[ADDR_WIDTH-1:0] > A_END_SLAVE13);
	if(SLAVE_NUM == 15)
	  assign select_reserve  = (start_addr[ADDR_WIDTH-1:0] < A_START_REG)|(start_addr[ADDR_WIDTH-1:0] > A_END_SLAVE14);
	if(SLAVE_NUM == 16)
	  assign select_reserve  = (start_addr[ADDR_WIDTH-1:0] < A_START_REG)|(start_addr[ADDR_WIDTH-1:0] > A_END_SLAVE15);
    if(SLAVE_NUM == 17)
	  assign select_reserve  = (start_addr[ADDR_WIDTH-1:0] < A_START_REG)|(start_addr[ADDR_WIDTH-1:0] > A_END_SLAVE16);
	if(SLAVE_NUM == 18)
	  assign select_reserve  = (start_addr[ADDR_WIDTH-1:0] < A_START_REG)|(start_addr[ADDR_WIDTH-1:0] > A_END_SLAVE17);
	if(SLAVE_NUM == 19)
	  assign select_reserve  = (start_addr[ADDR_WIDTH-1:0] < A_START_REG)|(start_addr[ADDR_WIDTH-1:0] > A_END_SLAVE18);
	if(SLAVE_NUM == 20)
	  assign select_reserve  = (start_addr[ADDR_WIDTH-1:0] < A_START_REG)|(start_addr[ADDR_WIDTH-1:0] > A_END_SLAVE19);
    if(SLAVE_NUM == 21)
	  assign select_reserve  = (start_addr[ADDR_WIDTH-1:0] < A_START_REG)|(start_addr[ADDR_WIDTH-1:0] > A_END_SLAVE20);
	if(SLAVE_NUM == 22)
	  assign select_reserve  = (start_addr[ADDR_WIDTH-1:0] < A_START_REG)|(start_addr[ADDR_WIDTH-1:0] > A_END_SLAVE21);
	if(SLAVE_NUM == 23)
	  assign select_reserve  = (start_addr[ADDR_WIDTH-1:0] < A_START_REG)|(start_addr[ADDR_WIDTH-1:0] > A_END_SLAVE22);
	if(SLAVE_NUM == 24)
	  assign select_reserve  = (start_addr[ADDR_WIDTH-1:0] < A_START_REG)|(start_addr[ADDR_WIDTH-1:0] > A_END_SLAVE23);
    if(SLAVE_NUM == 25)
	  assign select_reserve  = (start_addr[ADDR_WIDTH-1:0] < A_START_REG)|(start_addr[ADDR_WIDTH-1:0] > A_END_SLAVE24);
	if(SLAVE_NUM == 26)
	  assign select_reserve  = (start_addr[ADDR_WIDTH-1:0] < A_START_REG)|(start_addr[ADDR_WIDTH-1:0] > A_END_SLAVE25);
	if(SLAVE_NUM == 27)
	  assign select_reserve  = (start_addr[ADDR_WIDTH-1:0] < A_START_REG)|(start_addr[ADDR_WIDTH-1:0] > A_END_SLAVE26);
	if(SLAVE_NUM == 28)
	  assign select_reserve  = (start_addr[ADDR_WIDTH-1:0] < A_START_REG)|(start_addr[ADDR_WIDTH-1:0] > A_END_SLAVE27);
    if(SLAVE_NUM == 29)
	  assign select_reserve  = (start_addr[ADDR_WIDTH-1:0] < A_START_REG)|(start_addr[ADDR_WIDTH-1:0] > A_END_SLAVE28);
	if(SLAVE_NUM == 30)
	  assign select_reserve  = (start_addr[ADDR_WIDTH-1:0] < A_START_REG)|(start_addr[ADDR_WIDTH-1:0] > A_END_SLAVE29);
	if(SLAVE_NUM == 31)
	  assign select_reserve  = (start_addr[ADDR_WIDTH-1:0] < A_START_REG)|(start_addr[ADDR_WIDTH-1:0] > A_END_SLAVE30);
	if(SLAVE_NUM == 32)
	  assign select_reserve  = (start_addr[ADDR_WIDTH-1:0] < A_START_REG)|(start_addr[ADDR_WIDTH-1:0] > A_END_SLAVE31);
  endgenerate
  //select_len
  assign select_len[LEN_WIDTH-1:0] = abt_grant[0] ?  sfifo_ar_ctrl_arlen[LEN_WIDTH-1:0] : sfifo_aw_ctrl_awlen[LEN_WIDTH-1:0];
  //transaction_completed
  assign transaction_completed = ((transfer_counter[LEN_WIDTH-1:0] == select_len[LEN_WIDTH-1:0]) ? 1'b1 : 1'b0) & transfer_en;
  always_ff @(posedge pclk, negedge preset_n) begin
    if(!preset_n)
	  transfer_counter[LEN_WIDTH-1:0] <= {LEN_WIDTH{1'b0}};
    else begin
      casez({transfer_en, transaction_completed})
	    2'b?1:  transfer_counter[LEN_WIDTH-1:0] <= {LEN_WIDTH{1'b0}};
	    2'b10:  transfer_counter[LEN_WIDTH-1:0] <= transfer_counter[LEN_WIDTH-1:0] + 1'b1;
		 default transfer_counter[LEN_WIDTH-1:0] <= transfer_counter[LEN_WIDTH-1:0];
	  endcase
	end	
  end
  //dec_error
  generate
    if(SLAVE_NUM == 1)
	  assign dec_error = (start_addr[ADDR_WIDTH-1:0] < A_START_REG) | (start_addr[ADDR_WIDTH-1:0] > A_END_SLAVE0);
	if(SLAVE_NUM == 2)
	  assign dec_error = (start_addr[ADDR_WIDTH-1:0] < A_START_REG) | (start_addr[ADDR_WIDTH-1:0] > A_END_SLAVE1);
	if(SLAVE_NUM == 3)
	  assign dec_error = (start_addr[ADDR_WIDTH-1:0] < A_START_REG) | (start_addr[ADDR_WIDTH-1:0] > A_END_SLAVE2);
	if(SLAVE_NUM == 4)
	  assign dec_error = (start_addr[ADDR_WIDTH-1:0] < A_START_REG) | (start_addr[ADDR_WIDTH-1:0] > A_END_SLAVE3);
	if(SLAVE_NUM == 5)
	  assign dec_error = (start_addr[ADDR_WIDTH-1:0] < A_START_REG) | (start_addr[ADDR_WIDTH-1:0] > A_END_SLAVE4);
	if(SLAVE_NUM == 6)
	  assign dec_error = (start_addr[ADDR_WIDTH-1:0] < A_START_REG) | (start_addr[ADDR_WIDTH-1:0] > A_END_SLAVE5);
	if(SLAVE_NUM == 7)
	  assign dec_error = (start_addr[ADDR_WIDTH-1:0] < A_START_REG) | (start_addr[ADDR_WIDTH-1:0] > A_END_SLAVE6);
	if(SLAVE_NUM == 8)
	  assign dec_error = (start_addr[ADDR_WIDTH-1:0] < A_START_REG) | (start_addr[ADDR_WIDTH-1:0] > A_END_SLAVE7);
	if(SLAVE_NUM == 9)
	  assign dec_error = (start_addr[ADDR_WIDTH-1:0] < A_START_REG) | (start_addr[ADDR_WIDTH-1:0] > A_END_SLAVE8);
	if(SLAVE_NUM == 10)
	  assign dec_error = (start_addr[ADDR_WIDTH-1:0] < A_START_REG) | (start_addr[ADDR_WIDTH-1:0] > A_END_SLAVE9);
	if(SLAVE_NUM == 11)
	  assign dec_error = (start_addr[ADDR_WIDTH-1:0] < A_START_REG) | (start_addr[ADDR_WIDTH-1:0] > A_END_SLAVE10);
	if(SLAVE_NUM == 12)
	  assign dec_error = (start_addr[ADDR_WIDTH-1:0] < A_START_REG) | (start_addr[ADDR_WIDTH-1:0] > A_END_SLAVE11);
	if(SLAVE_NUM == 13)
	  assign dec_error = (start_addr[ADDR_WIDTH-1:0] < A_START_REG) | (start_addr[ADDR_WIDTH-1:0] > A_END_SLAVE12);
	if(SLAVE_NUM == 14)
	  assign dec_error = (start_addr[ADDR_WIDTH-1:0] < A_START_REG) | (start_addr[ADDR_WIDTH-1:0] > A_END_SLAVE13);
	if(SLAVE_NUM == 15)
	  assign dec_error = (start_addr[ADDR_WIDTH-1:0] < A_START_REG) | (start_addr[ADDR_WIDTH-1:0] > A_END_SLAVE14);
	if(SLAVE_NUM == 16)
	  assign dec_error = (start_addr[ADDR_WIDTH-1:0] < A_START_REG) | (start_addr[ADDR_WIDTH-1:0] > A_END_SLAVE15);
	if(SLAVE_NUM == 17)
	  assign dec_error = (start_addr[ADDR_WIDTH-1:0] < A_START_REG) | (start_addr[ADDR_WIDTH-1:0] > A_END_SLAVE16);
	if(SLAVE_NUM == 18)
	  assign dec_error = (start_addr[ADDR_WIDTH-1:0] < A_START_REG) | (start_addr[ADDR_WIDTH-1:0] > A_END_SLAVE17);
	if(SLAVE_NUM == 19)
	  assign dec_error = (start_addr[ADDR_WIDTH-1:0] < A_START_REG) | (start_addr[ADDR_WIDTH-1:0] > A_END_SLAVE18);
	if(SLAVE_NUM == 20)
	  assign dec_error = (start_addr[ADDR_WIDTH-1:0] < A_START_REG) | (start_addr[ADDR_WIDTH-1:0] > A_END_SLAVE19);
	if(SLAVE_NUM == 21)
	  assign dec_error = (start_addr[ADDR_WIDTH-1:0] < A_START_REG) | (start_addr[ADDR_WIDTH-1:0] > A_END_SLAVE20);
	if(SLAVE_NUM == 22)
	  assign dec_error = (start_addr[ADDR_WIDTH-1:0] < A_START_REG) | (start_addr[ADDR_WIDTH-1:0] > A_END_SLAVE21);
	if(SLAVE_NUM == 23)
	  assign dec_error = (start_addr[ADDR_WIDTH-1:0] < A_START_REG) | (start_addr[ADDR_WIDTH-1:0] > A_END_SLAVE22);
	if(SLAVE_NUM == 24)
	  assign dec_error = (start_addr[ADDR_WIDTH-1:0] < A_START_REG) | (start_addr[ADDR_WIDTH-1:0] > A_END_SLAVE23);
	if(SLAVE_NUM == 25)
	  assign dec_error = (start_addr[ADDR_WIDTH-1:0] < A_START_REG) | (start_addr[ADDR_WIDTH-1:0] > A_END_SLAVE24);
	if(SLAVE_NUM == 26)
	  assign dec_error = (start_addr[ADDR_WIDTH-1:0] < A_START_REG) | (start_addr[ADDR_WIDTH-1:0] > A_END_SLAVE25);
	if(SLAVE_NUM == 27)
	  assign dec_error = (start_addr[ADDR_WIDTH-1:0] < A_START_REG) | (start_addr[ADDR_WIDTH-1:0] > A_END_SLAVE26);
	if(SLAVE_NUM == 28)
	  assign dec_error = (start_addr[ADDR_WIDTH-1:0] < A_START_REG) | (start_addr[ADDR_WIDTH-1:0] > A_END_SLAVE27);
	if(SLAVE_NUM == 29)
	  assign dec_error = (start_addr[ADDR_WIDTH-1:0] < A_START_REG) | (start_addr[ADDR_WIDTH-1:0] > A_END_SLAVE28);
	if(SLAVE_NUM == 30)
	  assign dec_error = (start_addr[ADDR_WIDTH-1:0] < A_START_REG) | (start_addr[ADDR_WIDTH-1:0] > A_END_SLAVE29);
	if(SLAVE_NUM == 31)
	  assign dec_error = (start_addr[ADDR_WIDTH-1:0] < A_START_REG) | (start_addr[ADDR_WIDTH-1:0] > A_END_SLAVE30);
	if(SLAVE_NUM == 32)
	  assign dec_error = (start_addr[ADDR_WIDTH-1:0] < A_START_REG) | (start_addr[ADDR_WIDTH-1:0] > A_END_SLAVE31);
  endgenerate
  //pslverr_apb, pready_apb
  assign pready_apb  = |pready_out[SLAVE_NUM-1:0] | pselect_reserve | psel_reg & pready_reg;
  assign pslverr_apb = |pslverr_out[SLAVE_NUM-1:0]| pselect_reserve | psel_reg & pslverr_reg;
  generate
    genvar i;
	for (i = 0; i <= SLAVE_NUM-1; i = i + 1) begin: decPreadyAndPslverr
	  assign pready_out[i]  = psel[i] & pready[i];
	  assign pslverr_out[i] = psel[i] & pslverr[i];
	end
  endgenerate
  //prdata_apb
  assign prdata_apb[DATA_WIDTH_APB-1:0] = prdata_out[SLAVE_NUM-1][DATA_WIDTH_APB-1:0] | prdata_reg_out[DATA_WIDTH_APB-1:0];
  assign prdata_out[0] = psel[0] ? prdata[0] : {DATA_WIDTH_APB{1'b0}};
  generate
    genvar j;
	for(j = 1; j <= SLAVE_NUM-1; j = j + 1) begin: decPrdata
	  assign prdata_out[j] = psel[j] ? prdata[j] : prdata_out[j-1];
	end
  endgenerate
  assign prdata_reg_out[DATA_WIDTH_APB-1:0] = psel_reg ? prdata_reg[DATA_WIDTH_APB-1:0] : {DATA_WIDTH_APB{1'b0}};
  //transfer
  assign transfer = sfifo_ar_not_empty | sfifo_aw_not_empty;
  //next_state circuit
  always_comb begin
    case(current_state[1:0])
	   IDLE: begin
	     if(transfer)
		    next_state[1:0] = SETUP;
		  else
		    next_state[1:0] = IDLE;
	    end
	   SETUP: next_state[1:0] = ACCESS;
	   ACCESS: begin
	     if(~pready_apb)
		    next_state[1:0] = ACCESS;
		  else if(transaction_completed)
		    next_state[1:0] = IDLE;
		  else if(transfer)
		    next_state[1:0] = SETUP;
		  else
		    next_state[1:0] = IDLE;
	   end
		default next_state[1:0] = IDLE;
	endcase
  end
  //current_state
  always_ff @(posedge pclk, negedge preset_n) begin
    if(!preset_n)
	  current_state[1:0] <= IDLE;
	else
	  current_state[1:0] <= next_state[1:0];
  end
  //psel
  always_ff @(posedge pclk, negedge preset_n) begin
    if(!preset_n) begin
	  psel[SLAVE_NUM-1:0] <= {SLAVE_NUM{1'b0}};
	  psel_reg <= 1'b0;
	  pselect_reserve <= 1'b0;
	end
	else begin
	  case(current_state[1:0])
	    IDLE:begin
		  if(transfer) begin
		    psel[SLAVE_NUM-1:0] <= sel[SLAVE_NUM-1:0];
		    psel_reg <= sel_reg;
			pselect_reserve <= select_reserve;
		  end
		  else begin
		    psel[SLAVE_NUM-1:0] <= {SLAVE_NUM{1'b0}};
		    psel_reg <= 1'b0;
			pselect_reserve <= 1'b0;
		  end
		end
	    SETUP:begin
		  psel[SLAVE_NUM-1:0] <= psel[SLAVE_NUM-1:0];
		  psel_reg <= psel_reg;
		  pselect_reserve <= pselect_reserve;
		end
	    ACCESS:begin
		  if(transaction_completed) begin
		    psel[SLAVE_NUM-1:0] <= {SLAVE_NUM{1'b0}};
		    psel_reg <= 1'b0;
			pselect_reserve <= 1'b0;
		  end
		  else begin
		    psel[SLAVE_NUM-1:0] <= psel[SLAVE_NUM-1:0];
			psel_reg <= psel_reg;
			pselect_reserve <= pselect_reserve;
		  end
		end
	  endcase
	end
  end
  //penable
  always_ff @(posedge pclk, negedge preset_n) begin
    if(!preset_n)
	  penable <= 1'b0;
	else begin
	  case(current_state[1:0])
	    IDLE:   penable <= 1'b0;
		SETUP:  penable <= 1'b1;
		ACCESS: penable <= 1'b0;
	  endcase
	end
  end
  //paddr
  always_ff @(posedge pclk, negedge preset_n) begin
    if(!preset_n)
	  paddr[ADDR_WIDTH-1:0] <= {ADDR_WIDTH{1'b0}};
	else begin
	  case(current_state[1:0])
	    IDLE: begin
		  if(transfer)
			paddr[ADDR_WIDTH-1:0] <= start_addr[ADDR_WIDTH-1:0];
		  else
		    paddr[ADDR_WIDTH-1:0] <= {ADDR_WIDTH{1'b0}};
		end
		SETUP: begin
		  paddr[ADDR_WIDTH-1:0] <= paddr[ADDR_WIDTH-1:0];
		end
		ACCESS: begin
		  if(transaction_completed)
		    paddr[ADDR_WIDTH-1:0] <= {ADDR_WIDTH{1'b0}};
		  else begin
		    case(burst_mode[1:0])
			  2'b00: paddr[ADDR_WIDTH-1:0] <= paddr[ADDR_WIDTH-1:0];
			  2'b01: paddr[ADDR_WIDTH-1:0] <= incr_next_transaddr[ADDR_WIDTH-1:0];
			  2'b10: paddr[ADDR_WIDTH-1:0] <= wrap_next_transaddr[ADDR_WIDTH-1:0];
			  2'b11: paddr[ADDR_WIDTH-1:0] <= {ADDR_WIDTH{1'b0}};
			endcase
		  end
		end
	  endcase
	end
  end
  //incr_next_transaddr
  assign incr_next_transaddr[31:0] = paddr[31:0] + 32'd4;
  //burst_mode
  assign burst_mode[1:0] = (abt_grant[0] == 1'b1) ? sfifo_ar_ctrl_arburst[1:0] : sfifo_aw_ctrl_awburst[1:0];
  //bit_num
  always_comb begin
    if(select_len[LEN_WIDTH-1:0] == 'd1) begin
	  casez(DATA_WIDTH_AXI)
	    32: bit_num[3:0]   = 4'h3;
		64: bit_num[3:0]   = 4'h4;
		128: bit_num[3:0]  = 4'h5;
		256: bit_num[3:0]  = 4'h6;
		512: bit_num[3:0]  = 4'h7;
		1024: bit_num[3:0] = 4'h8;
		default bit_num[3:0] = 4'bx;
	  endcase
	end
	else if(select_len[LEN_WIDTH-1:0] == 'd3) begin
	  casez(DATA_WIDTH_AXI)
	    32: bit_num[3:0]   = 4'h4;
		64: bit_num[3:0]   = 4'h5;
		128: bit_num[3:0]  = 4'h6;
		256: bit_num[3:0]  = 4'h7;
		512: bit_num[3:0]  = 4'h8;
		1024: bit_num[3:0] = 4'h9;
		default bit_num = 1'bx;
	  endcase
	end
	else if(select_len[LEN_WIDTH-1:0] == 'd7) begin
	  casez(DATA_WIDTH_AXI)
	    32: bit_num[3:0]   = 4'h5;
		64: bit_num[3:0]   = 4'h6;
		128: bit_num[3:0]  = 4'h7;
		256: bit_num[3:0]  = 4'h8;
		512: bit_num[3:0]  = 4'h9;
		1024: bit_num[3:0] = 4'hA;
		default bit_num = 1'bx;
	  endcase
	end
	else if(select_len[LEN_WIDTH-1:0] == 'd15) begin
	  casez(DATA_WIDTH_AXI)
	    32: bit_num[3:0]   = 4'h6;
		64: bit_num[3:0]   = 4'h7;
		128: bit_num[3:0]  = 4'h8;
		256: bit_num[3:0]  = 4'h9;
		512: bit_num[3:0]  = 4'hA;
		1024: bit_num[3:0] = 4'hB;
		default bit_num = 1'bx;
	  endcase
	end
	else
	  bit_num[3:0] = 4'hx;
  end
  //bit3_addr, bit4_addr, bit5_addr, bit6_addr
  
  always_comb begin
    if(bit_num[3:0] == 4'b0011)
	  bit3_addr[2:0] = paddr[2:0] + 3'd4;
	else
	  bit3_addr[2:0] = 3'd0;
  end
  always_comb begin
    if(bit_num[3:0] == 4'b0100)
	  bit4_addr[3:0] = paddr[3:0] + 4'd4;
	else
	  bit4_addr[3:0] = 4'd0;
  end
  always_comb begin
    if(bit_num[3:0] == 4'b0101)
	  bit5_addr[4:0] = paddr[4:0] + 5'd4;
	else
	  bit5_addr[4:0] = 5'd0;
  end
  always_comb begin
    if(bit_num[3:0] == 4'b0110)
	  bit6_addr[5:0] = paddr[5:0] + 6'd4;
	else
	  bit6_addr[5:0] = 6'd0;
  end
  always_comb begin
    if(bit_num[3:0] == 4'b0111)
	  bit7_addr[6:0] = paddr[6:0] + 7'd4;
	else
	  bit7_addr[6:0] = 7'd0;
  end
  always_comb begin
    if(bit_num[3:0] == 4'b1000)
	  bit8_addr[7:0] = paddr[7:0] + 8'd4;
	else
	  bit8_addr[7:0] = 8'd0;
  end
  always_comb begin
    if(bit_num[3:0] == 4'b1001)
	  bit9_addr[8:0] = paddr[8:0] + 9'd4;
	else
	  bit9_addr[8:0] = 9'd0;
  end
  always_comb begin
    if(bit_num[3:0] == 4'b1010)
	  bit10_addr[9:0] = paddr[9:0] + 10'd4;
	else
	  bit10_addr[9:0] = 10'd0;
  end
  always_comb begin
    if(bit_num[3:0] == 4'b1011)
	  bit11_addr[10:0] = paddr[10:0] + 11'd4;
	else
	  bit11_addr[10:0] = 11'd0;
  end
  //wrap_next_transaddr
  always_comb begin
    casez(bit_num[3:0])
	  4'b0011: wrap_next_transaddr[ADDR_WIDTH-1:0] = {paddr[ADDR_WIDTH-1:3], bit3_addr[2:0]};
	  4'b0100: wrap_next_transaddr[ADDR_WIDTH-1:0] = {paddr[ADDR_WIDTH-1:4], bit4_addr[3:0]};
	  4'b0101: wrap_next_transaddr[ADDR_WIDTH-1:0] = {paddr[ADDR_WIDTH-1:5], bit5_addr[4:0]};
	  4'b0110: wrap_next_transaddr[ADDR_WIDTH-1:0] = {paddr[ADDR_WIDTH-1:6], bit6_addr[5:0]};
	  4'b0111: wrap_next_transaddr[ADDR_WIDTH-1:0] = {paddr[ADDR_WIDTH-1:7], bit7_addr[6:0]};
	  4'b1000: wrap_next_transaddr[ADDR_WIDTH-1:0] = {paddr[ADDR_WIDTH-1:8], bit8_addr[7:0]};
	  4'b1001: wrap_next_transaddr[ADDR_WIDTH-1:0] = {paddr[ADDR_WIDTH-1:9], bit9_addr[8:0]};
	  4'b1010: wrap_next_transaddr[ADDR_WIDTH-1:0] = {paddr[ADDR_WIDTH-1:10], bit10_addr[9:0]};
	  4'b1011: wrap_next_transaddr[ADDR_WIDTH-1:0] = {paddr[ADDR_WIDTH-1:11], bit11_addr[10:0]};
	  default wrap_next_transaddr[ADDR_WIDTH-1:0] = {ADDR_WIDTH{1'bx}};
	endcase
  end
  //pwrite
  always_ff @(posedge pclk, negedge preset_n) begin
    if(!preset_n)
	  pwrite <= 1'b0;
	else begin
	  case(current_state[1:0])
	    IDLE: begin
		  if(~transfer)
		    pwrite <= 1'b0;
		  else if(~abt_grant[0])
		    pwrite <= 1'b1;
		  else
		    pwrite <= 1'b0;
		end
		SETUP: pwrite <= pwrite;
		ACCESS: begin
		  if(transaction_completed)
		    pwrite <= 1'b0;
		  else
		    pwrite <= pwrite;
		end
	  endcase
	end
  end
  //pwdata
  always_ff @(posedge pclk, negedge preset_n) begin
    if(!preset_n)
	  pwdata[DATA_WIDTH_APB-1:0] <= {DATA_WIDTH_APB{1'b0}};
	else begin
	  case(current_state[1:0])
	    IDLE: begin
		  if(~transfer)
		    pwdata[DATA_WIDTH_APB-1:0] <= {DATA_WIDTH_APB{1'b0}};
		  else if(abt_grant[0])
		    pwdata[DATA_WIDTH_APB-1:0] <= {DATA_WIDTH_APB{1'b0}};
		  else
		    pwdata[DATA_WIDTH_APB-1:0] <= separate_wdata[31:0];
		end
		SETUP: begin
          pwdata[DATA_WIDTH_APB-1:0] <= pwdata[DATA_WIDTH_APB-1:0];  
		end
		ACCESS: begin
		  if(transaction_completed)
		    pwdata[DATA_WIDTH_APB-1:0] <= {DATA_WIDTH_APB{1'b0}};
		  else if(~abt_grant[0])
		    pwdata[DATA_WIDTH_APB-1:0] <= separate_wdata[31:0];
		  else
		    pwdata[DATA_WIDTH_APB-1:0] <= {DATA_WIDTH_APB{1'b0}};
		end
	  endcase
	end
  end
  //separate_wdata
  `ifdef MODE32_32
    assign separate_wdata[31:0] = separate_wdata_32[31:0];
  `endif
  `ifdef MODE64_32
    assign separate_wdata[31:0] = separate_wdata_64[31:0];
  `endif
  `ifdef MODE128_32
    assign separate_wdata[31:0] = separate_wdata_128[31:0];
  `endif
  `ifdef MODE256_32
    assign separate_wdata[31:0] = separate_wdata_256[31:0];
  `endif
  `ifdef MODE512_32
    assign separate_wdata[31:0] = separate_wdata_512[31:0];
  `endif
  `ifdef MODE1024_32
    assign separate_wdata[31:0] = separate_wdata_1024[31:0];
  `endif
  `ifdef MODE32_32
    assign separate_wdata_32[31:0] = sfifo_wd_wdata[DATA_WIDTH_AXI-1:0]; 
  `endif
  `ifdef MODE64_32
	always_comb begin
	  casez(cnt_32)
	    1'b0: separate_wdata_64[31:0] = sfifo_wd_wdata[31:0];
		1'b1: separate_wdata_64[31:0] = sfifo_wd_wdata[DATA_WIDTH_AXI-1:32];
	  endcase
	end
  `endif
  `ifdef MODE128_32
    always_comb begin
      casez({cnt_64, cnt_32})
	      2'b00: separate_wdata_128[31:0] = sfifo_wd_wdata[31:0];
		  2'b01: separate_wdata_128[31:0] = sfifo_wd_wdata[63:32];
		  2'b10: separate_wdata_128[31:0] = sfifo_wd_wdata[95:64];
		  2'b11: separate_wdata_128[31:0] = sfifo_wd_wdata[DATA_WIDTH_AXI-1:96];
	   endcase
	 end
  `endif
  `ifdef MODE256_32
    always_comb begin
      casez({cnt_128, cnt_64, cnt_32})
	    3'b000: separate_wdata_256[31:0] = sfifo_wd_wdata[31:0];
		3'b001: separate_wdata_256[31:0] = sfifo_wd_wdata[63:32];
		3'b010: separate_wdata_256[31:0] = sfifo_wd_wdata[95:64];
		3'b011: separate_wdata_256[31:0] = sfifo_wd_wdata[127:96];
		3'b100: separate_wdata_256[31:0] = sfifo_wd_wdata[159:128];
		3'b101: separate_wdata_256[31:0] = sfifo_wd_wdata[191:160];
		3'b110: separate_wdata_256[31:0] = sfifo_wd_wdata[223:192];
		3'b111: separate_wdata_256[31:0] = sfifo_wd_wdata[DATA_WIDTH_AXI-1:224];
	  endcase
	end
  `endif
  `ifdef MODE512_32
    always_comb begin
      casez({cnt_256, cnt_128, cnt_64, cnt_32})
	    4'b0000: separate_wdata_512[31:0] = sfifo_wd_wdata[31:0];
		4'b0001: separate_wdata_512[31:0] = sfifo_wd_wdata[63:32];
		4'b0010: separate_wdata_512[31:0] = sfifo_wd_wdata[95:64];
		4'b0011: separate_wdata_512[31:0] = sfifo_wd_wdata[127:96];
		4'b0100: separate_wdata_512[31:0] = sfifo_wd_wdata[159:128];
		4'b0101: separate_wdata_512[31:0] = sfifo_wd_wdata[191:160];
		4'b0110: separate_wdata_512[31:0] = sfifo_wd_wdata[223:192];
		4'b0111: separate_wdata_512[31:0] = sfifo_wd_wdata[255:224];
		4'b1000: separate_wdata_512[31:0] = sfifo_wd_wdata[287:256];
		4'b1001: separate_wdata_512[31:0] = sfifo_wd_wdata[319:288];
		4'b1010: separate_wdata_512[31:0] = sfifo_wd_wdata[351:320];
		4'b1011: separate_wdata_512[31:0] = sfifo_wd_wdata[383:352];
		4'b1100: separate_wdata_512[31:0] = sfifo_wd_wdata[415:384];
		4'b1101: separate_wdata_512[31:0] = sfifo_wd_wdata[447:416];
		4'b1110: separate_wdata_512[31:0] = sfifo_wd_wdata[479:448];
		4'b1111: separate_wdata_512[31:0] = sfifo_wd_wdata[DATA_WIDTH_AXI-1:480];
	  endcase
	end
  `endif
  `ifdef MODE1024_32
    always_comb begin
      casez({cnt_512, cnt_256, cnt_128, cnt_64, cnt_32})
	    5'b00000: separate_wdata_1024[31:0] = sfifo_wd_wdata[31:0];
		5'b00001: separate_wdata_1024[31:0] = sfifo_wd_wdata[63:32];
		5'b00010: separate_wdata_1024[31:0] = sfifo_wd_wdata[95:64];
		5'b00011: separate_wdata_1024[31:0] = sfifo_wd_wdata[127:96];
		5'b00100: separate_wdata_1024[31:0] = sfifo_wd_wdata[159:128];
		5'b00101: separate_wdata_1024[31:0] = sfifo_wd_wdata[191:160];
		5'b00110: separate_wdata_1024[31:0] = sfifo_wd_wdata[223:192];
		5'b00111: separate_wdata_1024[31:0] = sfifo_wd_wdata[255:224];
		5'b01000: separate_wdata_1024[31:0] = sfifo_wd_wdata[287:256];
		5'b01001: separate_wdata_1024[31:0] = sfifo_wd_wdata[319:288];
		5'b01010: separate_wdata_1024[31:0] = sfifo_wd_wdata[351:320];
		5'b01011: separate_wdata_1024[31:0] = sfifo_wd_wdata[383:352];
		5'b01100: separate_wdata_1024[31:0] = sfifo_wd_wdata[415:384];
		5'b01101: separate_wdata_1024[31:0] = sfifo_wd_wdata[447:416];
		5'b01110: separate_wdata_1024[31:0] = sfifo_wd_wdata[479:448];
		5'b01111: separate_wdata_1024[31:0] = sfifo_wd_wdata[511:480];
		5'b10000: separate_wdata_1024[31:0] = sfifo_wd_wdata[543:512];
		5'b10001: separate_wdata_1024[31:0] = sfifo_wd_wdata[575:544];
		5'b10010: separate_wdata_1024[31:0] = sfifo_wd_wdata[607:576];
		5'b10011: separate_wdata_1024[31:0] = sfifo_wd_wdata[639:608];
		5'b10100: separate_wdata_1024[31:0] = sfifo_wd_wdata[671:640];
		5'b10101: separate_wdata_1024[31:0] = sfifo_wd_wdata[703:672];
		5'b10110: separate_wdata_1024[31:0] = sfifo_wd_wdata[735:704];
		5'b10111: separate_wdata_1024[31:0] = sfifo_wd_wdata[767:736];
		5'b11000: separate_wdata_1024[31:0] = sfifo_wd_wdata[799:768];
		5'b11001: separate_wdata_1024[31:0] = sfifo_wd_wdata[831:800];
		5'b11010: separate_wdata_1024[31:0] = sfifo_wd_wdata[863:832];
		5'b11011: separate_wdata_1024[31:0] = sfifo_wd_wdata[895:864];
		5'b11100: separate_wdata_1024[31:0] = sfifo_wd_wdata[927:896];
		5'b11101: separate_wdata_1024[31:0] = sfifo_wd_wdata[959:928];
		5'b11110: separate_wdata_1024[31:0] = sfifo_wd_wdata[991:960];
		5'b11111: separate_wdata_1024[31:0] = sfifo_wd_wdata[DATA_WIDTH_AXI-1:992];
	  endcase
	end
  `endif
  //pprot
  always_ff @(posedge pclk, negedge preset_n) begin
    if(!preset_n)
	  pprot[2:0] <= 3'd0;
	else begin
	  case(current_state[1:0])
	    IDLE: begin
		  if(transfer)
		    if(abt_grant[0])
		      pprot[2:0] <= sfifo_ar_ctrl_arprot[2:0];
		    else
		      pprot[2:0] <= sfifo_aw_ctrl_awprot[2:0];
		  else
		    pprot[2:0] <= 3'd0;
		end
	    SETUP: begin
		  pprot[2:0] <= pprot[2:0];
		end
		ACCESS: begin
		  if(transaction_completed)
		    pprot[2:0] <= 3'd0;
		  else
		    pprot[2:0] <= pprot[2:0];
		end
	  endcase
	end
  end
  //pstrb
  always_ff @(posedge pclk, negedge preset_n) begin
    if(!preset_n)
	  pstrb[DATA_WIDTH_APB/8-1:0] = {DATA_WIDTH_APB/8{1'b0}};
	else begin
	  casez(current_state[1:0])
	    IDLE: begin
          if(~transfer)		
		    pstrb[DATA_WIDTH_APB/8-1:0] <= {DATA_WIDTH_APB/8{1'b0}};
		  else if(abt_grant[0])
		    pstrb[DATA_WIDTH_APB/8-1:0] <= {DATA_WIDTH_APB/8{1'b0}};
		  else
		    pstrb[DATA_WIDTH_APB/8-1:0] <= wstrb_en[DATA_WIDTH_APB/8-1:0];
		end
		SETUP: begin
          pstrb[DATA_WIDTH_APB/8-1:0] <= pstrb[DATA_WIDTH_APB/8-1:0];
		end
		ACCESS: begin
		  if(transaction_completed)
		    pstrb[DATA_WIDTH_APB/8-1:0] <= {DATA_WIDTH_APB/8{1'b0}};
		  else if(~abt_grant[0])
		    pstrb[DATA_WIDTH_APB/8-1:0] <= wstrb_en[DATA_WIDTH_APB/8-1:0];
		  else
		    pstrb[DATA_WIDTH_APB/8-1:0] <= {DATA_WIDTH_APB/8{1'b0}};
		end
	  endcase
	end
  end
  `ifdef MODE32_32
    assign wstrb_en[DATA_WIDTH_APB/8-1:0] = wstrb_32[DATA_WIDTH_APB/8-1:0];
  `elsif MODE64_32
    assign wstrb_en[DATA_WIDTH_APB/8-1:0] = wstrb_64[DATA_WIDTH_APB/8-1:0];
  `elsif MODE128_32
    assign wstrb_en[DATA_WIDTH_APB/8-1:0] = wstrb_128[DATA_WIDTH_APB/8-1:0];
  `elsif MODE256_32
    assign wstrb_en[DATA_WIDTH_APB/8-1:0] = wstrb_256[DATA_WIDTH_APB/8-1:0];
  `elsif MODE512_32
    assign wstrb_en[DATA_WIDTH_APB/8-1:0] = wstrb_512[DATA_WIDTH_APB/8-1:0];
  `elsif MODE1024_32
    assign wstrb_en[DATA_WIDTH_APB/8-1:0] = wstrb_1024[DATA_WIDTH_APB/8-1:0];
  `endif
  `ifdef MODE32_32
    assign wstrb_32[DATA_WIDTH_APB/8-1:0] = sfifo_wd_wstrb[DATA_WIDTH_AXI/8-1:0];
  `elsif MODE64_32
	always_comb begin
	  casez({cnt_32})
	    1'b0: wstrb_64[DATA_WIDTH_APB/8-1:0] = sfifo_wd_wstrb[3:0];
		1'b1: wstrb_64[DATA_WIDTH_APB/8-1:0] = sfifo_wd_wstrb[DATA_WIDTH_AXI/8-1:4];
	  endcase
	end
  `elsif MODE128_32
    always_comb begin
      casez({cnt_64, cnt_32})
	    2'b00: wstrb_128[DATA_WIDTH_APB/8-1:0] = sfifo_wd_wstrb[3:0];
		2'b01: wstrb_128[DATA_WIDTH_APB/8-1:0] = sfifo_wd_wstrb[7:4];
	    2'b10: wstrb_128[DATA_WIDTH_APB/8-1:0] = sfifo_wd_wstrb[11:8];
	    2'b11: wstrb_128[DATA_WIDTH_APB/8-1:0] = sfifo_wd_wstrb[DATA_WIDTH_AXI/8-1:12];
	  endcase
	end
  `elsif MODE256_32
    always_comb begin
      casez({cnt_128, cnt_64, cnt_32})
	    3'b000: wstrb_256[DATA_WIDTH_APB/8-1:0] = sfifo_wd_wstrb[3:0];
		3'b001: wstrb_256[DATA_WIDTH_APB/8-1:0] = sfifo_wd_wstrb[7:4];
	    3'b010: wstrb_256[DATA_WIDTH_APB/8-1:0] = sfifo_wd_wstrb[11:8];
	    3'b011: wstrb_256[DATA_WIDTH_APB/8-1:0] = sfifo_wd_wstrb[15:12];
	    3'b100: wstrb_256[DATA_WIDTH_APB/8-1:0] = sfifo_wd_wstrb[19:16];	  
	    3'b101: wstrb_256[DATA_WIDTH_APB/8-1:0] = sfifo_wd_wstrb[23:20];
	    3'b110: wstrb_256[DATA_WIDTH_APB/8-1:0] = sfifo_wd_wstrb[27:24];
	    3'b111: wstrb_256[DATA_WIDTH_APB/8-1:0] = sfifo_wd_wstrb[DATA_WIDTH_AXI/8-1:28];
	  endcase
	end
  `elsif MODE512_32
    always_comb begin
      casez({cnt_256, cnt_128, cnt_64, cnt_32})
	    4'b0000: wstrb_512[DATA_WIDTH_APB/8-1:0] = sfifo_wd_wstrb[3:0];
		4'b0001: wstrb_512[DATA_WIDTH_APB/8-1:0] = sfifo_wd_wstrb[7:4];
	    4'b0010: wstrb_512[DATA_WIDTH_APB/8-1:0] = sfifo_wd_wstrb[11:8];
	    4'b0011: wstrb_512[DATA_WIDTH_APB/8-1:0] = sfifo_wd_wstrb[15:12];
	    4'b0100: wstrb_512[DATA_WIDTH_APB/8-1:0] = sfifo_wd_wstrb[19:16];	  
	    4'b0101: wstrb_512[DATA_WIDTH_APB/8-1:0] = sfifo_wd_wstrb[23:20];
	    4'b0110: wstrb_512[DATA_WIDTH_APB/8-1:0] = sfifo_wd_wstrb[27:24];
	    4'b0111: wstrb_512[DATA_WIDTH_APB/8-1:0] = sfifo_wd_wstrb[31:28];
	    4'b1000: wstrb_512[DATA_WIDTH_APB/8-1:0] = sfifo_wd_wstrb[35:32];
	    4'b1001: wstrb_512[DATA_WIDTH_APB/8-1:0] = sfifo_wd_wstrb[39:36];
	    4'b1010: wstrb_512[DATA_WIDTH_APB/8-1:0] = sfifo_wd_wstrb[43:40];
	    4'b1011: wstrb_512[DATA_WIDTH_APB/8-1:0] = sfifo_wd_wstrb[47:44];
	    4'b1100: wstrb_512[DATA_WIDTH_APB/8-1:0] = sfifo_wd_wstrb[51:48];
	    4'b1101: wstrb_512[DATA_WIDTH_APB/8-1:0] = sfifo_wd_wstrb[55:52];
	    4'b1110: wstrb_512[DATA_WIDTH_APB/8-1:0] = sfifo_wd_wstrb[59:56];
	    4'b1111: wstrb_512[DATA_WIDTH_APB/8-1:0] = sfifo_wd_wstrb[DATA_WIDTH_AXI/8-1:60];
	  endcase
	end
  `elsif MODE1024_32
    always_comb begin
      casez({cnt_512, cnt_256, cnt_128, cnt_64, cnt_32})
	     5'b00000: wstrb_1024[DATA_WIDTH_APB/8-1:0] = sfifo_wd_wstrb[3:0];
		  5'b00001: wstrb_1024[DATA_WIDTH_APB/8-1:0] = sfifo_wd_wstrb[7:4];
	     5'b00010: wstrb_1024[DATA_WIDTH_APB/8-1:0] = sfifo_wd_wstrb[11:8];
	     5'b00011: wstrb_1024[DATA_WIDTH_APB/8-1:0] = sfifo_wd_wstrb[15:12];
	     5'b00100: wstrb_1024[DATA_WIDTH_APB/8-1:0] = sfifo_wd_wstrb[19:16];	  
	     5'b00101: wstrb_1024[DATA_WIDTH_APB/8-1:0] = sfifo_wd_wstrb[23:20];
	     5'b00110: wstrb_1024[DATA_WIDTH_APB/8-1:0] = sfifo_wd_wstrb[27:24];
	     5'b00111: wstrb_1024[DATA_WIDTH_APB/8-1:0] = sfifo_wd_wstrb[31:28];
	     5'b01000: wstrb_1024[DATA_WIDTH_APB/8-1:0] = sfifo_wd_wstrb[35:32];
	     5'b01001: wstrb_1024[DATA_WIDTH_APB/8-1:0] = sfifo_wd_wstrb[39:36];
	     5'b01010: wstrb_1024[DATA_WIDTH_APB/8-1:0] = sfifo_wd_wstrb[43:40];
	     5'b01011: wstrb_1024[DATA_WIDTH_APB/8-1:0] = sfifo_wd_wstrb[47:44];
	     5'b01100: wstrb_1024[DATA_WIDTH_APB/8-1:0] = sfifo_wd_wstrb[51:48];
	     5'b01101: wstrb_1024[DATA_WIDTH_APB/8-1:0] = sfifo_wd_wstrb[55:52];
	     5'b01110: wstrb_1024[DATA_WIDTH_APB/8-1:0] = sfifo_wd_wstrb[59:56];
	     5'b01111: wstrb_1024[DATA_WIDTH_APB/8-1:0] = sfifo_wd_wstrb[63:60];
	     5'b10000: wstrb_1024[DATA_WIDTH_APB/8-1:0] = sfifo_wd_wstrb[67:64];	  
	     5'b10001: wstrb_1024[DATA_WIDTH_APB/8-1:0] = sfifo_wd_wstrb[71:68];
	     5'b10010: wstrb_1024[DATA_WIDTH_APB/8-1:0] = sfifo_wd_wstrb[75:72];
	     5'b10011: wstrb_1024[DATA_WIDTH_APB/8-1:0] = sfifo_wd_wstrb[79:76];
	     5'b10100: wstrb_1024[DATA_WIDTH_APB/8-1:0] = sfifo_wd_wstrb[83:80];
	     5'b10101: wstrb_1024[DATA_WIDTH_APB/8-1:0] = sfifo_wd_wstrb[87:84];
	     5'b10110: wstrb_1024[DATA_WIDTH_APB/8-1:0] = sfifo_wd_wstrb[91:88];
	     5'b10111: wstrb_1024[DATA_WIDTH_APB/8-1:0] = sfifo_wd_wstrb[95:92];
	     5'b11000: wstrb_1024[DATA_WIDTH_APB/8-1:0] = sfifo_wd_wstrb[99:96];
	     5'b11001: wstrb_1024[DATA_WIDTH_APB/8-1:0] = sfifo_wd_wstrb[103:100];
	     5'b11010: wstrb_1024[DATA_WIDTH_APB/8-1:0] = sfifo_wd_wstrb[107:104];
	     5'b11011: wstrb_1024[DATA_WIDTH_APB/8-1:0] = sfifo_wd_wstrb[111:108];
	     5'b11100: wstrb_1024[DATA_WIDTH_APB/8-1:0] = sfifo_wd_wstrb[115:112];
	     5'b11101: wstrb_1024[DATA_WIDTH_APB/8-1:0] = sfifo_wd_wstrb[119:116];
	     5'b11110: wstrb_1024[DATA_WIDTH_APB/8-1:0] = sfifo_wd_wstrb[123:120];
	     5'b11111: wstrb_1024[DATA_WIDTH_APB/8-1:0] = sfifo_wd_wstrb[DATA_WIDTH_AXI/8-1:124];	  
	  endcase
	end
  `endif
  //cnt_32
  `ifdef MODE1024_32_MODE512_32_MODE256_32_MODE128_32_MODE64_32
  always_ff @(posedge pclk, negedge preset_n) begin
    if(!preset_n) begin
	   cnt_32 <= 1'b0;
	 end
	else if(abt_grant[0]) begin
	  casez({cnt_32, sfifo_rd_we_32})
	    2'b01: cnt_32 <= 1'b1;
		2'b10: cnt_32 <= 1'b1;
		2'b11: cnt_32 <= 1'b0;
		2'b00: cnt_32 <= 1'b0;
	  endcase
	end
	else begin
	  casez({cnt_32, sfifo_wd_re_32})
	    2'b01: cnt_32 <= 1'b1;
	    2'b10: cnt_32 <= 1'b1;
	    2'b11: cnt_32 <= 1'b0;
	    2'b00: cnt_32 <= 1'b0;
	  endcase
	end
  end
  `endif
  //cnt_64
  `ifdef MODE1024_32_MODE512_32_MODE256_32_MODE128_32
  always_ff @(posedge pclk, negedge preset_n) begin
    if(!preset_n)
	  cnt_64 <= 1'b0;
	else if(abt_grant[0]) begin
	  casez({cnt_64, sfifo_rd_we_64})
	    2'b01: cnt_64 <= 1'b1;
		2'b10: cnt_64 <= 1'b1;
		2'b11: cnt_64 <= 1'b0;
		2'b00: cnt_64 <= 1'b0;
	  endcase
	end
	else begin
	  casez({cnt_64, sfifo_wd_re_64})
	    2'b01: cnt_64 <= 1'b1;
		2'b10: cnt_64 <= 1'b1;
		2'b11: cnt_64 <= 1'b0;
		2'b00: cnt_64 <= 1'b0;
	  endcase
	end
  end
  `endif
  //cnt_128
  `ifdef MODE1024_32_MODE512_32_MODE256_32
    always_ff @(posedge pclk, negedge preset_n) begin
      if(!preset_n)
	    cnt_128 <= 1'b0;
	  else if(abt_grant[0]) begin
	    casez({cnt_128, sfifo_rd_we_128})
	      2'b01: cnt_128 <= 1'b1;
		  2'b10: cnt_128 <= 1'b1;
		  2'b11: cnt_128 <= 1'b0;
		  2'b00: cnt_128 <= 1'b0;
	    endcase
	  end
	else begin
	  casez({cnt_128, sfifo_wd_re_128})
	    2'b01: cnt_128 <= 1'b1;
		2'b10: cnt_128 <= 1'b1;
		2'b11: cnt_128 <= 1'b0;
		2'b00: cnt_128 <= 1'b0;
	  endcase
	end
  end
  `endif
  //cnt_256
  `ifdef MODE1024_32_MODE512_32
  always_ff @(posedge pclk, negedge preset_n) begin
    if(!preset_n)
	  cnt_256 <= 1'b0;
	else if(abt_grant[0]) begin
	  casez({cnt_256, sfifo_rd_we_256})
	    2'b01: cnt_256 <= 1'b1;
		2'b10: cnt_256 <= 1'b1;
		2'b11: cnt_256 <= 1'b0;
		2'b00: cnt_256 <= 1'b0;
	  endcase
	end
	else begin
	  casez({cnt_256, sfifo_wd_re_256})
	    2'b01: cnt_256 <= 1'b1;
		2'b10: cnt_256 <= 1'b1;
		2'b11: cnt_256 <= 1'b0;
		2'b00: cnt_256 <= 1'b0;
	  endcase
	end
  end
  `endif
  `ifdef MODE1024_32
  //cnt_512
  always_ff @(posedge pclk, negedge preset_n) begin
    if(!preset_n)
	  cnt_512 <= 1'b0;
	else if(abt_grant[0]) begin
	  casez({cnt_512, sfifo_rd_we_512})
	    2'b01: cnt_512 <= 1'b1;
		2'b10: cnt_512 <= 1'b1;
		2'b11: cnt_512 <= 1'b0;
		2'b00: cnt_512 <= 1'b0;
	  endcase
	end
	else begin
	  casez({cnt_512, sfifo_wd_re_512})
	    2'b01: cnt_512 <= 1'b1;
		2'b10: cnt_512 <= 1'b1;
		2'b11: cnt_512 <= 1'b0;
		2'b00: cnt_512 <= 1'b0;
	  endcase
	end
  end
  `endif
endmodule:x2p_core