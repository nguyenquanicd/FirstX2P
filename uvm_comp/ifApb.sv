//--------------------------------------
//Project: The UVM environemnt for X2P (AXI protocol To APB protocol)
//Function: APB Agent
//Author:  Phan Van Tien, Nguyen Hoang Tam,...
//Page:    VLSI Technology
//--------------------------------------
interface ifApbSlave;
  //input DUT
  logic   					 pclk;
  logic		                 preset_n;
  logic  [`SLAVE_NUM:0]       pready;  
  logic  [`SLAVE_NUM:0][31:0] prdata;
  logic	 [`SLAVE_NUM:0]	     pslverr;
  //output DUT 
  logic 	                 penable;
  logic [31:0]               paddr;
  logic [31:0]               pwdata;
  logic [`SLAVE_NUM:0]        psel;
  logic [2:0]                pprot;
  logic [3:0]                pstrb;
  logic                      pwrite;
endinterface: ifApbSlave
