//===================================================================================
// File name: X2P.sv
// Project  : X2P
// Function : IP core design of AXI to APB bridge
// Author   : Nguyen Hung Quan, Pham Van Thang, Nguyen Trung Hieu
// Gmail    : phamanhthang147@gmail.com
// Website  :http://nguyenquanicd.blogspot.com
//===================================================================================

module x2p (// AXI protocol
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
			pslverr
            );
  //iclude parameter file
  `include "x2p_parameter.h"
  //ports declaration
  //AXI protocol
  input logic                     aclk;
  input logic                     aresetn;
  // Address write chanel
  input  logic                    awvalid;
  input  logic [31:0]             awaddr;
  input  logic [2:0]              awsize;
  input  logic [7:0]              awlen;
  input  logic [1:0]              awburst;
  input  logic [7:0]              awid;
  input  logic [2:0]              awprot;
  output logic                    awready;
  // address read chanel
  input  logic                    arvalid;
  input  logic [31:0]             araddr;
  input  logic [2:0]              arsize;
  input  logic [7:0]              arlen;
  input  logic [1:0]              arburst;
  input  logic [7:0]              arid;
  input  logic [2:0]              arprot;
  output logic                    arready;
  //write data chanel
  input  logic                    wvalid;
  input  logic [31:0]             wdata;
  input  logic [3:0]              wstrb;
  input  logic                    wlast;
  output logic                    wready;
  //read data chanel
  input  logic                    rready;
  output logic                    rvalid;
  output logic [1:0]              rresp;
  output logic                    rlast;
  output logic [7:0]              rid;
  output logic [31:0]             rdata;
  //write respond chanel
  input  logic                    bready;
  output logic                    bvalid;
  output logic [1:0]              bresp;
  output logic [7:0]              bid;
  //APB protocol
  input  logic                    pclk;
  input  logic                    preset_n;
  input  logic [SLAVE_NUM:0]      pready;
  input  logic [SLAVE_NUM:0][31:0] prdata;
  input  logic [SLAVE_NUM:0]      pslverr;
  output logic [31:0]             paddr;
  output logic [31:0]             pwdata;
  output logic [SLAVE_NUM:0]      psel;
  output logic                    penable;
  output logic [2:0]              pprot;
  output logic [3:0]              pstrb;
  output logic                    pwrite;
  //internal signals
  //SFIFO_AW
  logic                           sfifoAwFull;
  logic                           sfifoAwNotFull;
  logic                           sfifoAwEmpty;
  logic                           sfifoAwNotEmpty;
  logic                           sfifoAwWe;
  logic                           sfifoAwRe;
  logic [31:0]                    sfifoAwAwaddr;
  logic [7:0]                     sfifoAwAwid;
  logic [7:0]                     sfifoAwCtrlAwlen;
  logic [2:0]                     sfifoAwCtrlAwsize;
  logic [1:0]                     sfifoAwCtrlAwburst;
  logic [2:0]                     sfifoAwCtrlAwprot;
  //SFIFO_AR
  logic                           sfifoArFull;
  logic                           sfifoArNotFull;
  logic                           sfifoArEmpty;
  logic                           sfifoArNotEmpty;
  logic                           sfifoArWe;
  logic                           sfifoArRe;
  logic [31:0]                    sfifoArAraddr;
  logic [7:0]                     sfifoArArid;
  logic [7:0]                     sfifoArCtrlArlen;
  logic [2:0]                     sfifoArCtrlArsize;
  logic [1:0]                     sfifoArCtrlArburst;
  logic [2:0]                     sfifoArCtrlArprot;
  //SFIFO_WD
  logic                           sfifoWdFull;
  logic                           sfifoWdNotFull;
  logic                           sfifoWdEmpty;
  logic                           sfifoWdNotEmpty;
  logic                           sfifoWdWe;
  logic                           sfifoWdRe;
  logic [31:0]                    sfifoWdWdata;
  logic [3:0]                     sfifoWdWstrb;
  //SFIFO_RD
  logic                           sfifoRdFull;
  logic                           sfifoRdNotFull;
  logic                           sfifoRdEmpty;
  logic                           sfifoRdNotEmpty;
  logic                           sfifoRdWe;
  logic                           sfifoRdRe;
  //RD_CH
  logic[1:0]                      rChRresp;
  //logic                           rChRlast;
  //ARBITER
  logic [1:0]                     abtGrant;
  logic [1:0]                     nextGrant;
  logic [1:0]                     nextSel;
  //DECODER
  bit                             pslverrX;
  bit [31:0]                      prdataX;
  bit                             preadyX;
  logic                           transCompleted;
  logic                           decError;
  logic                           transCntEn;
  //logic                           pselReg;
  logic [31:0]                    startAddr;
  logic [SLAVE_NUM:0]             sel;
  logic [7:0]                     selectLen;
  logic [7:0]                     transferCounter;
  logic                           transfer;
  logic [1:0]                     nextState;
  logic [1:0]                     currentState;
  logic                           fsmCal;
  logic [1:0]                     burstMode;
  logic [31:0]                    incrNextTransAddr;
  logic [31:0]                    wrapNextTransAddr;
  logic [2:0]                     bitNum;
  logic [2:0]                     bit3Addr;
  logic [3:0]                     bit4Addr;
  logic [4:0]                     bit5Addr;
  logic [5:0]                     bit6Addr;
  logic [SLAVE_NUM:0]             preadyOut;
  logic [SLAVE_NUM:0]             pslverrOut;
  logic [SLAVE_NUM:0][31:0]       prdataOut;
  logic [7:0]                     cnt_transfer;
  logic                           update;
  //body
  //X2P_SFIFO_AR
  sfifo #(.DATA_WIDTH(X2P_SFIFO_AR_DATA_WIDTH), .POINTER_WIDTH(POINTER_WIDTH)) ar_sfifo (
  .clk(aclk),
  .rst_n(aresetn),
  .wr(sfifoArWe),
  .rd(sfifoArRe),
  .data_in({araddr[31:0], arid[7:0], arlen[7:0], arsize[2:0], arburst[1:0], arprot[2:0]}),
  .sfifo_empty(sfifoArEmpty),
  .sfifo_full(sfifoArFull),
  .data_out({sfifoArAraddr[31:0], sfifoArArid[7:0], sfifoArCtrlArlen[7:0], sfifoArCtrlArsize[2:0], sfifoArCtrlArburst[1:0], sfifoArCtrlArprot[2:0]})
  );
  //Logic
  assign sfifoArNotFull  = ~sfifoArFull;
  assign sfifoArNotEmpty = ~sfifoArEmpty;
  assign arready         = sfifoArNotFull;
  assign sfifoArWe       = arready & arvalid;
  assign sfifoArRe       = sfifoArNotEmpty & abtGrant[0] & transCompleted;
  //X2P_SFIFO_RD
  sfifo #(.DATA_WIDTH(X2P_SFIFO_RD_DATA_WIDTH), .POINTER_WIDTH(POINTER_WIDTH)) rd_sfifo(
  .clk(aclk),
  .rst_n(aresetn),
  .wr(sfifoRdWe),
  .rd(sfifoRdRe),
  .data_in({prdataX[31:0], rChRresp[1:0], sfifoArArid[7:0]}),
  .sfifo_empty(sfifoRdEmpty),
  .sfifo_full(sfifoRdFull),
  .data_out({rdata[31:0], rresp[1:0], rid[7:0]})
  );
  //Logic
  assign sfifoRdNotFull  = ~sfifoRdFull;
  assign sfifoRdNotEmpty = ~sfifoRdEmpty;
  assign rvalid          = sfifoRdNotEmpty;
  assign sfifoRdRe       = rvalid & rready;
  assign transCntEn      = |psel[SLAVE_NUM:0] & penable & preadyX;
  assign sfifoRdWe       = sfifoRdNotFull & transCntEn & ~pwrite;
  //RD_CH
  //rChRresp
  always_comb begin
    if(~pslverrX)
	  rChRresp = OKAY;
	else if(decError)
	  rChRresp = DECERR;
	else
	  rChRresp = PSLVERR;
  end
  //rlast
  always_comb begin
    if(transCompleted & abtGrant[0])
	  rlast = 1'b1;
	else
      rlast = 1'b0;	
  end
  //X2P_SFIFO_AW
  sfifo #(.DATA_WIDTH(X2P_SFIFO_AW_DATA_WIDTH), .POINTER_WIDTH(POINTER_WIDTH)) aw_sfifo(
  .clk(aclk),
  .rst_n(aresetn),
  .wr(sfifoAwWe),
  .rd(sfifoAwRe),
  .data_in({awaddr[31:0], awid[7:0], awlen[7:0], awsize[2:0], awburst[1:0], awprot[2:0]}),
  .sfifo_empty(sfifoAwEmpty),
  .sfifo_full(sfifoAwFull),
  .data_out({sfifoAwAwaddr[31:0], sfifoAwAwid[7:0], sfifoAwCtrlAwlen[7:0], sfifoAwCtrlAwsize[2:0], sfifoAwCtrlAwburst[1:0], sfifoAwCtrlAwprot[2:0]})
  );
  //Logic
  assign sfifoAwNotFull  = ~sfifoAwFull;
  assign sfifoAwNotEmpty = ~sfifoAwEmpty;
  assign awready         = sfifoAwNotFull;
  assign sfifoAwWe       = awready & awvalid;
  assign sfifoAwRe       = sfifoAwNotEmpty & abtGrant[1] & transCompleted;
  //X2P_SFIFO_WD
  sfifo #(.DATA_WIDTH(X2P_SFIFO_WD_DATA_WIDTH), .POINTER_WIDTH(POINTER_WIDTH)) wd_sfifo(
  .clk(aclk),
  .rst_n(aresetn),
  .wr(sfifoWdWe),
  .rd(sfifoWdRe),
  .data_in({wdata[31:0], wstrb[3:0]}),
  .sfifo_empty(sfifoWdEmpty),
  .sfifo_full(sfifoWdFull),
  .data_out({sfifoWdWdata[31:0], sfifoWdWstrb[3:0]})
  );
  //logic
  assign sfifoWdNotFull  = ~sfifoWdFull;
  assign sfifoWdNotEmpty = ~sfifoWdEmpty;
  assign wready          = sfifoWdNotFull;
  assign sfifoWdWe       = wvalid & wready;
  assign sfifoWdRe       = sfifoWdNotEmpty & abtGrant[1] & (currentState == ACCESS);
  //B_CH
  //bresp
  always_ff @(posedge aclk, negedge aresetn) begin
    if(~aresetn)
	  bresp[1:0] <= OKAY;
    else if(transCompleted & abtGrant[1]) begin
	  if(~pslverrX)
	    bresp[1:0] <= OKAY;
	  else if(decError)
	    bresp[1:0] <= DECERR;
      else
	    bresp[1:0] <= PSLVERR;
	end
  end
  //bid
  always_ff @(posedge aclk, negedge aresetn) begin
    if(~aresetn)
	  bid[7:0] <= 8'd0;
    else if(transCompleted && abtGrant[1] == 1'b1)
	  bid[7:0] <= sfifoAwAwid[7:0];
	else
	  bid[7:0] <= 8'd0;
  end
  //bvalid
  always_ff @(posedge aclk, negedge aresetn) begin
    if(~aresetn)
	  bvalid <= 1'b0;
	else if(transCompleted && abtGrant[1] == 1'b1)
	  bvalid <= 1'b1;
	else
	  bvalid <= 1'b0;
  end
  //ARBITER
  //nextSel0
  always_comb begin
    if(abtGrant[0])
	  nextSel[0] = 1'b1;
	else if(~nextSel[1])
	  nextSel[0] = 1'b0;
	else if(sfifoArNotEmpty)
	  nextSel[0] = 1'b0;
	else
	  nextSel[0] = 1'b1;
  end
  //nextSel1
  always_comb begin
    if(abtGrant[1])
	  nextSel[1] = 1'b1;
	else if(~nextSel[0])
	  nextSel[1] = 1'b0;
	else if(sfifoAwNotEmpty)
	  nextSel[1] = 1'b0;
	else
	  nextSel[1] = 1'b1;
  end
  //nextGrant[1]
  always_comb begin
    if(~nextSel[0])
	  nextGrant[1] = 1'b0;
	else if(sfifoAwNotEmpty)
	  nextGrant[1] = 1'b1;
	else
	  nextGrant[1] = abtGrant[1];
  end
  //nextGrant[0]
  always_comb begin
    if(~nextSel[1])
	  nextGrant[0] = 1'b0;
	else if(sfifoArNotEmpty)
	  nextGrant[0] = 1'b1;
	else
	  nextGrant[0] = abtGrant[0];
  end
  //abtGrant
  assign update = (abtGrant[0] & sfifoAwNotEmpty & ~sfifoArNotEmpty) | transCompleted;
  always_ff @(posedge aclk, negedge aresetn) begin
    if(~aresetn)
	  abtGrant[1:0] <= 2'b01;
	else if(update)
    //else if(transCompleted || (abtGrant[0] == 1'b1 && sfifoAwNotEmpty == 1'b1))
	  abtGrant[1:0] <= nextGrant[1:0];
	else
	  abtGrant[1:0] <= abtGrant[1:0];	  
  end
  //X2P_DECODER
  //startAddr
  assign startAddr[31:0] = abtGrant[0] ? sfifoArAraddr[31:0] : sfifoAwAwaddr[31:0];
  //sel[SLAVE_NUM-1:0]
  generate
    if(SLAVE_NUM >= 1) begin
	  assign sel[0]  = (startAddr[31:0] >= A_START_REG)     & (startAddr[31:0] <= A_END_REG);
	  assign sel[1]  = (startAddr[31:0] >= A_START_SLAVE0)  & (startAddr[31:0] <= A_END_SLAVE0);
	end
	if(SLAVE_NUM >= 2)
	  assign sel[2]  = (startAddr[31:0] >= A_START_SLAVE1)  & (startAddr[31:0] <= A_END_SLAVE1);
	if(SLAVE_NUM >= 3)
	  assign sel[3]  = (startAddr[31:0] >= A_START_SLAVE2)  & (startAddr[31:0] <= A_END_SLAVE2);
	if(SLAVE_NUM >= 4)
	  assign sel[4]  = (startAddr[31:0] >= A_START_SLAVE3)  & (startAddr[31:0] <= A_END_SLAVE3);
	if(SLAVE_NUM >= 5)
      assign sel[5]  = (startAddr[31:0] >= A_START_SLAVE4)  & (startAddr[31:0] <= A_END_SLAVE4);
	if(SLAVE_NUM >= 6)
	  assign sel[6]  = (startAddr[31:0] >= A_START_SLAVE5)  & (startAddr[31:0] <= A_END_SLAVE5);
	if(SLAVE_NUM >= 7)
      assign sel[7]  = (startAddr[31:0] >= A_START_SLAVE6)  & (startAddr[31:0] <= A_END_SLAVE6);
    if(SLAVE_NUM >= 8)
      assign sel[8]  = (startAddr[31:0] >= A_START_SLAVE7)  & (startAddr[31:0] <= A_END_SLAVE7);
    if(SLAVE_NUM >= 9)
	  assign sel[9]  = (startAddr[31:0] >= A_START_SLAVE8)  & (startAddr[31:0] <= A_END_SLAVE8);
	if(SLAVE_NUM >= 10)
	  assign sel[10]  = (startAddr[31:0] >= A_START_SLAVE9) & (startAddr[31:0] <= A_END_SLAVE9);
	if(SLAVE_NUM >= 11)
	  assign sel[11] = (startAddr[31:0] >= A_START_SLAVE10) & (startAddr[31:0] <= A_END_SLAVE10);
	if(SLAVE_NUM >= 12)
	  assign sel[12] = (startAddr[31:0] >= A_START_SLAVE11) & (startAddr[31:0] <= A_END_SLAVE11);
	if(SLAVE_NUM >= 13)
      assign sel[13] = (startAddr[31:0] >= A_START_SLAVE12) & (startAddr[31:0] <= A_END_SLAVE12);
	if(SLAVE_NUM >= 14)
	  assign sel[14] = (startAddr[31:0] >= A_START_SLAVE13) & (startAddr[31:0] <= A_END_SLAVE13);
	if(SLAVE_NUM >= 15)
      assign sel[15] = (startAddr[31:0] >= A_START_SLAVE14) & (startAddr[31:0] <= A_END_SLAVE14);
    if(SLAVE_NUM >= 16)
      assign sel[16] = (startAddr[31:0] >= A_START_SLAVE15) & (startAddr[31:0] <= A_END_SLAVE15);
    if(SLAVE_NUM >= 17)
	  assign sel[17] = (startAddr[31:0] >= A_START_SLAVE16) & (startAddr[31:0] <= A_END_SLAVE16);
	if(SLAVE_NUM >= 18)
	  assign sel[18] = (startAddr[31:0] >= A_START_SLAVE17) & (startAddr[31:0] <= A_END_SLAVE17);
	if(SLAVE_NUM >= 19)
	  assign sel[19] = (startAddr[31:0] >= A_START_SLAVE18) & (startAddr[31:0] <= A_END_SLAVE18);
	if(SLAVE_NUM >= 20)
	  assign sel[20] = (startAddr[31:0] >= A_START_SLAVE19) & (startAddr[31:0] <= A_END_SLAVE19);
	if(SLAVE_NUM >= 21)
      assign sel[21] = (startAddr[31:0] >= A_START_SLAVE20) & (startAddr[31:0] <= A_END_SLAVE20);
	if(SLAVE_NUM >= 22)
	  assign sel[22] = (startAddr[31:0] >= A_START_SLAVE21) & (startAddr[31:0] <= A_END_SLAVE21);
	if(SLAVE_NUM >= 23)
      assign sel[23] = (startAddr[31:0] >= A_START_SLAVE22) & (startAddr[31:0] <= A_END_SLAVE22);
    if(SLAVE_NUM >= 24)
      assign sel[24] = (startAddr[31:0] >= A_START_SLAVE23) & (startAddr[31:0] <= A_END_SLAVE23);
    if(SLAVE_NUM >= 25)
	  assign sel[25] = (startAddr[31:0] >= A_START_SLAVE24) & (startAddr[31:0] <= A_END_SLAVE24);
	if(SLAVE_NUM >= 26)
	  assign sel[26] = (startAddr[31:0] >= A_START_SLAVE25) & (startAddr[31:0] <= A_END_SLAVE25);
	if(SLAVE_NUM >= 27)
	  assign sel[27] = (startAddr[31:0] >= A_START_SLAVE26) & (startAddr[31:0] <= A_END_SLAVE26);
	if(SLAVE_NUM >= 28)
	  assign sel[28] = (startAddr[31:0] >= A_START_SLAVE27) & (startAddr[31:0] <= A_END_SLAVE27);
	if(SLAVE_NUM >= 29)
      assign sel[29] = (startAddr[31:0] >= A_START_SLAVE28) & (startAddr[31:0] <= A_END_SLAVE28);
	if(SLAVE_NUM >= 30)
	  assign sel[30] = (startAddr[31:0] >= A_START_SLAVE29) & (startAddr[31:0] <= A_END_SLAVE29);
	if(SLAVE_NUM >= 31)
      assign sel[31] = (startAddr[31:0] >= A_START_SLAVE30) & (startAddr[31:0] <= A_END_SLAVE30);
    if(SLAVE_NUM == 32)
      assign sel[32] = (startAddr[31:0] >= A_START_SLAVE31) & (startAddr[31:0] <= A_END_SLAVE31);	  
  endgenerate
  //selectLen
  assign selectLen[7:0] = abtGrant[0] ?  sfifoArCtrlArlen[7:0] : sfifoAwCtrlAwlen[7:0];
  //transCompleted
  assign transCompleted = (transferCounter[7:0] == selectLen[7:0] + 1'b1) ? 1 : 0;
  always_ff @(posedge pclk, negedge preset_n) begin
    if(~preset_n)
	  transferCounter[7:0] <= 8'd0;
    else begin
      casez({transCntEn, transCompleted})
	    2'b?1:  transferCounter[7:0] <= 8'd0;
	    2'b10:  transferCounter[7:0] <= transferCounter[7:0] + 1'b1;
		default transferCounter[7:0] <= transferCounter[7:0];
	  endcase
	end	
  end
  //decError
  
  generate
    if(SLAVE_NUM == 1)
	  assign decError = (startAddr[31:0] < A_START_REG) | (startAddr[31:0] > A_END_SLAVE0);
	else if(SLAVE_NUM == 2)
	  assign decError = (startAddr[31:0] < A_START_REG) | (startAddr[31:0] > A_END_SLAVE1);
	else if(SLAVE_NUM == 3)
	  assign decError = (startAddr[31:0] < A_START_REG) | (startAddr[31:0] > A_END_SLAVE2);
	else if(SLAVE_NUM == 4)
	  assign decError = (startAddr[31:0] < A_START_REG) | (startAddr[31:0] > A_END_SLAVE3);
	else if(SLAVE_NUM == 5)
	  assign decError = (startAddr[31:0] < A_START_REG) | (startAddr[31:0] > A_END_SLAVE4);
	else if(SLAVE_NUM == 6)
	  assign decError = (startAddr[31:0] < A_START_REG) | (startAddr[31:0] > A_END_SLAVE5);
	else if(SLAVE_NUM == 7)
	  assign decError = (startAddr[31:0] < A_START_REG) | (startAddr[31:0] > A_END_SLAVE6);
	else if(SLAVE_NUM == 8)
	  assign decError = (startAddr[31:0] < A_START_REG) | (startAddr[31:0] > A_END_SLAVE7);
	else if(SLAVE_NUM == 9)
	  assign decError = (startAddr[31:0] < A_START_REG) | (startAddr[31:0] > A_END_SLAVE8);
	else if(SLAVE_NUM == 10)
	  assign decError = (startAddr[31:0] < A_START_REG) | (startAddr[31:0] > A_END_SLAVE9);
	else if(SLAVE_NUM == 11)
	  assign decError = (startAddr[31:0] < A_START_REG) | (startAddr[31:0] > A_END_SLAVE10);
	else if(SLAVE_NUM == 12)
	  assign decError = (startAddr[31:0] < A_START_REG) | (startAddr[31:0] > A_END_SLAVE11);
	else if(SLAVE_NUM == 13)
	  assign decError = (startAddr[31:0] < A_START_REG) | (startAddr[31:0] > A_END_SLAVE12);
	else if(SLAVE_NUM == 14)
	  assign decError = (startAddr[31:0] < A_START_REG) | (startAddr[31:0] > A_END_SLAVE13);
	else if(SLAVE_NUM == 15)
	  assign decError = (startAddr[31:0] < A_START_REG) | (startAddr[31:0] > A_END_SLAVE14);
	else if(SLAVE_NUM == 16)
	  assign decError = (startAddr[31:0] < A_START_REG) | (startAddr[31:0] > A_END_SLAVE15);
	else if(SLAVE_NUM == 17)
	  assign decError = (startAddr[31:0] < A_START_REG) | (startAddr[31:0] > A_END_SLAVE16);
	else if(SLAVE_NUM == 18)
	  assign decError = (startAddr[31:0] < A_START_REG) | (startAddr[31:0] > A_END_SLAVE17);
	else if(SLAVE_NUM == 19)
	  assign decError = (startAddr[31:0] < A_START_REG) | (startAddr[31:0] > A_END_SLAVE18);
	else if(SLAVE_NUM == 20)
	  assign decError = (startAddr[31:0] < A_START_REG) | (startAddr[31:0] > A_END_SLAVE19);
	else if(SLAVE_NUM == 21)
	  assign decError = (startAddr[31:0] < A_START_REG) | (startAddr[31:0] > A_END_SLAVE20);
	else if(SLAVE_NUM == 22)
	  assign decError = (startAddr[31:0] < A_START_REG) | (startAddr[31:0] > A_END_SLAVE21);
	else if(SLAVE_NUM == 23)
	  assign decError = (startAddr[31:0] < A_START_REG) | (startAddr[31:0] > A_END_SLAVE22);
	else if(SLAVE_NUM == 24)
	  assign decError = (startAddr[31:0] < A_START_REG) | (startAddr[31:0] > A_END_SLAVE23);
	else if(SLAVE_NUM == 25)
	  assign decError = (startAddr[31:0] < A_START_REG) | (startAddr[31:0] > A_END_SLAVE24);
	else if(SLAVE_NUM == 26)
	  assign decError = (startAddr[31:0] < A_START_REG) | (startAddr[31:0] > A_END_SLAVE25);
	else if(SLAVE_NUM == 27)
	  assign decError = (startAddr[31:0] < A_START_REG) | (startAddr[31:0] > A_END_SLAVE26);
	else if(SLAVE_NUM == 28)
	  assign decError = (startAddr[31:0] < A_START_REG) | (startAddr[31:0] > A_END_SLAVE27);
	else if(SLAVE_NUM == 29)
	  assign decError = (startAddr[31:0] < A_START_REG) | (startAddr[31:0] > A_END_SLAVE28);
	else if(SLAVE_NUM == 30)
	  assign decError = (startAddr[31:0] < A_START_REG) | (startAddr[31:0] > A_END_SLAVE29);
	else if(SLAVE_NUM == 31)
	  assign decError = (startAddr[31:0] < A_START_REG) | (startAddr[31:0] > A_END_SLAVE30);
	else if(SLAVE_NUM == 32)
	  assign decError = (startAddr[31:0] < A_START_REG) | (startAddr[31:0] > A_END_SLAVE31);
  endgenerate
  //pslverrX, preadyX
  assign preadyX  = |preadyOut[SLAVE_NUM:0];
  assign pslverrX = |pslverrOut[SLAVE_NUM:0];
  generate
    genvar i;
	for (i = 0; i <= SLAVE_NUM; i = i + 1) begin: decPreadyAndPslverr
	  assign preadyOut[i]  = psel[i] & pready[i];
	  assign pslverrOut[i] = psel[i] & pslverr[i];
	end
  endgenerate
  //prdataX
  assign prdataX = prdataOut[SLAVE_NUM];
  assign prdataOut[0] = psel[0] ? prdata[0] : 32'd0;
  generate
    genvar j;
	for(j = 1; j <= SLAVE_NUM; j = j + 1) begin: decPrdata
	  assign prdataOut[j] = psel[j] ? prdata[j] : prdataOut[j-1];
	end
  endgenerate
  //transfer
  always_comb begin
    if(cnt_transfer[7:0] >= selectLen[7:0] + 1'b1)
	  transfer = 0;
	else if( |sel[SLAVE_NUM:0])
	  transfer = 1;
	else
	  transfer = 0;
  end
  //always_ff @(posedge pclk, negedge preset_n) begin
    //if(~preset_n)
	 // transfer <= 1'b0;
	//else if(transfer)
	 // transfer <= 1'b0;
	//else if(|sel[SLAVE_NUM:0])//
	//  transfer <= 1'b1;
  //end
  //assign transfer = |sel[SLAVE_NUM:0];
  //cnt_transfer
  always_ff @(posedge pclk, negedge preset_n) begin
    if(~preset_n)
	  cnt_transfer[7:0] <= 8'd0;
	else if(transCompleted)
	  cnt_transfer[7:0] <= 8'd0;
	//else if((currentState == IDLE && transfer == 1'b1)|(currentState == ACCESS && transfer == 1'b1))
	else if(transfer & (currentState == ACCESS || currentState == IDLE))
	  cnt_transfer <= cnt_transfer + 1'b1;
  end
  //nextState circuit
  always_comb begin
    case(currentState[1:0])
	  IDLE: begin
	    if(transfer)
		  nextState[1:0] = SETUP;
		else
		  nextState[1:0] = IDLE;
	  end
	  SETUP: nextState[1:0] = ACCESS;
	  ACCESS: begin
	    if(~preadyX)
		  nextState[1:0] = ACCESS;
		else if(transfer)
		  nextState[1:0] = SETUP;
		else
		  nextState[1:0] = IDLE;
	  end
	endcase
  end
  //currentState
  always_ff @(posedge pclk, negedge preset_n) begin
    if(~preset_n)
	  currentState[1:0] <= IDLE;
	else
	  currentState[1:0] <= nextState[1:0];
  end
  //psel
  always_ff @(posedge pclk, negedge preset_n) begin
    if(~preset_n)
	  psel[SLAVE_NUM:0] <= 0;
	else begin
	  case(currentState[1:0])
	    IDLE:   psel[SLAVE_NUM:0] <= 0;
	    SETUP:  psel[SLAVE_NUM:0] <= sel[SLAVE_NUM:0];
	    ACCESS: psel[SLAVE_NUM:0] <= psel[SLAVE_NUM:0];
	  endcase
	end
  end
  //penable
  always_ff @(posedge pclk, negedge preset_n) begin
    if(~preset_n)
	  penable <= 1'b0;
	else begin
	  case(currentState[1:0])
	    IDLE:   penable <= 1'b0;
		SETUP:  penable <= 1'b0;
		ACCESS: penable <= 1'b1;
	  endcase
	end
  end
  //paddr
  always_ff @(posedge pclk, negedge preset_n) begin
    if(~preset_n)
	  paddr[31:0] = 32'd0;
	else begin
	  case(currentState[1:0])
	    IDLE: paddr[31:0] <= 32'd0;
		SETUP: begin
		  if(~fsmCal)
		    paddr[31:0] <= startAddr[31:0];
		  else begin
		    case(burstMode[1:0])
			  2'b00:  paddr[31:0] <= paddr[31:0];
			  2'b01:  paddr[31:0] <= incrNextTransAddr[31:0];
			  2'b10:  paddr[31:0] <= wrapNextTransAddr[31:0];
			  default paddr[31:0] <= 32'd0;
			endcase
		  end
		end
		ACCESS: paddr[31:0] <= paddr[31:0];
	  endcase
	end
  end
  //fsmCal
  always_ff @(posedge pclk, negedge preset_n) begin
    if(~preset_n)
	  fsmCal <= 1'b0;
	else if(transCompleted)
	  fsmCal <= 1'b0;
	else
	  fsmCal <= |psel[SLAVE_NUM:0];
  end
  //incrNextTransAddr
  assign incrNextTransAddr[31:0] = paddr[31:0] + 32'd4;
  //burstMode
  assign burstMode[1:0] = (abtGrant[0] == 1'b1) ? sfifoArCtrlArburst[1:0] : sfifoAwCtrlAwburst[1:0];
  //bitNum
  always_comb begin
    case(selectLen[7:0])
	  8'd1:  bitNum[2:0] = 3'b011;
	  8'd3:  bitNum[2:0] = 3'b100;
	  8'd7:  bitNum[2:0] = 3'b101;
	  8'd15: bitNum[2:0] = 3'b110;
	endcase
  end
  //bit3Addr, bit4Addr, bit5Addr, bit6Addr
  always_comb begin
    if(bitNum[2:0] == 3'b011)
	  bit3Addr[2:0] = paddr[2:0] + 3'd4;
	else
	  bit3Addr[2:0] = 3'd0;
  end
  always_comb begin
    if(bitNum[2:0] == 3'b100)
	  bit4Addr[3:0] = paddr[3:0] + 4'd4;
	else
	  bit4Addr[3:0] = 4'd0;
  end
  always_comb begin
    if(bitNum[2:0] == 3'b101)
	  bit5Addr[4:0] = paddr[4:0] + 4'd4;
	else
	  bit5Addr[4:0] = 5'd0;
  end
  always_comb begin
    if(bitNum[2:0] == 3'b110)
	  bit6Addr[5:0] = paddr[5:0] + 4'd4;
	else
	  bit6Addr[5:0] = 6'd0;
  end
  //wrapNextTransAddr
  always_comb begin
    case(bitNum[2:0])
	  3'b011: wrapNextTransAddr[31:0] = {paddr[31:3], bit3Addr[2:0]};
	  3'b100: wrapNextTransAddr[31:0] = {paddr[31:4], bit4Addr[3:0]};
	  3'b101: wrapNextTransAddr[31:0] = {paddr[31:5], bit5Addr[4:0]};
	  3'b100: wrapNextTransAddr[31:0] = {paddr[31:6], bit6Addr[5:0]};
	endcase
  end
  //pwrite
  always_ff @(posedge pclk, negedge preset_n) begin
    if(~preset_n)
	  pwrite <= 1'b0;
	else begin
	  case(currentState[1:0])
	    IDLE: pwrite <= 1'b0;
		SETUP: begin
		  if(~abtGrant[0])
		    pwrite <= 1'b1;
		  else
		    pwrite <= 1'b0;
		end
		ACCESS: pwrite <= pwrite;
	  endcase
	end
  end
  //pwdata
  always_ff @(posedge pclk, negedge preset_n) begin
    if(~preset_n)
	  pwdata[31:0]           <= 32'd0;
	else begin
	  case(currentState[1:0])
	    IDLE: pwdata[31:0]   <= 32'd0;
		SETUP: begin
		  if(abtGrant[0])
		    pwdata[31:0]     <= 32'd0;
		  else
		    pwdata[31:0]     <= sfifoWdWdata[31:0];
		end
		ACCESS: pwdata[31:0] <= pwdata[31:0];
	  endcase
	end
  end
  //pprot
  always_ff @(posedge pclk, negedge preset_n) begin
    if(~preset_n)
	  pprot[2:0] <= 3'd0;
	else begin
	  case(currentState[1:0])
	    IDLE: pprot[2:0] <= 3'd0;
	    SETUP: begin
		  if(abtGrant[0])
		    pprot[2:0] <= sfifoArCtrlArprot[2:0];
		  else
		    pprot[2:0] <= sfifoAwCtrlAwprot[2:0];
		end
		ACCESS: pprot[2:0] <= pprot[2:0];
	  endcase
	end
  end
  //pstrb
  always_ff @(posedge pclk, negedge preset_n) begin
    if(~preset_n)
	  pstrb[3:0] = 4'd0;
	else begin
	  case(currentState[1:0])
	    IDLE: pstrb[3:0] <= 4'd0;
		SETUP: begin
		  if(~abtGrant[0])
		    pstrb[3:0] <= sfifoWdWstrb[3:0];
		  else
		    pstrb[3:0] <= 4'd0;
		end
		ACCESS: pstrb[3:0] <= pstrb[3:0];
	  endcase
	end
  end
endmodule: x2p