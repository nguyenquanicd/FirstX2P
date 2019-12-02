//======================================================
//File name: x2p_register.sv
//Function : Default register block
//Author   : Pham Van Thang
//Gmail    : phamanhthang147@gmail.com
// Website :http://nguyenquanicd.blogspot.com
//=======================================================
module x2p_register(pclk,
                    preset_n,
					psel,
					penable,
					pready,
					paddr,
					pwrite,
					pwdata,
					pstrb,
					pslverr,
					pprot,
					prdata
);
  //port declaration
  input  logic        pclk;
  input  logic        preset_n;
  input  logic        psel;
  input  logic        penable;
  output logic        pready;
  input  logic [31:0] paddr;
  input  logic        pwrite;
  input  logic [31:0] pwdata;
  input  logic [3:0]  pstrb;
  output logic        pslverr;
  input  logic [2:0]  pprot;
  output logic [31:0] prdata;
  //signal declaration
  logic [31:0]        x2pRegPaddr;
  logic               x2pRegPenable;
  logic [2:0]         x2pRegPprot;
  logic [31:0]        x2pRegPrdata;
  logic               x2pRegPselReg;
  logic [3:0]         x2pRegPstrb;
  logic [31:0]        x2pRegPwdata;
  logic               x2pRegPwrite;
  logic               errorCondition;
//X2P_REGISTER
  `include "x2p_parameter.h"
  //prdata
  always_ff @(posedge pclk, negedge preset_n) begin
    if(~preset_n)
	  prdata[31:0] <= 32'd0;
	else if(psel)
	  prdata[31:0] <= x2pRegPrdata[31:0];	  
  end
  //prdata  
  //generate
  always_comb begin
    if(SLAVE_NUM >= 2) begin: REG0
	  case(paddr[7:0])
		8'h00: x2pRegPrdata[31:0] = A_START_SLAVE0;
		8'h04: x2pRegPrdata[31:0] = A_END_SLAVE0;
		default x2pRegPrdata[31:0] = 32'd0;
	  endcase
	end
	if(SLAVE_NUM >= 3) begin: REG1
	  case(paddr[7:0])
		8'h08: x2pRegPrdata[31:0] = A_START_SLAVE1;
		8'h0C: x2pRegPrdata[31:0] = A_END_SLAVE1;
		default x2pRegPrdata[31:0] = 32'd0;
	  endcase
	end
	if(SLAVE_NUM >= 4) begin: REG2
	    case(paddr[7:0])
		  8'h10: x2pRegPrdata[31:0] = A_START_SLAVE2;
		  8'h14: x2pRegPrdata[31:0] = A_END_SLAVE2;
		  default x2pRegPrdata[31:0] = 32'd0;
		endcase
	end	
	if(SLAVE_NUM >= 5) begin: REG3
	    case(paddr[7:0])
		  8'h18: x2pRegPrdata[31:0] = A_START_SLAVE3;
		  8'h1C: x2pRegPrdata[31:0] = A_END_SLAVE3;
		  default x2pRegPrdata[31:0] = 32'd0;
		endcase
	end
	if(SLAVE_NUM >= 6) begin: REG4
	    case(paddr[7:0])
		  8'h20: x2pRegPrdata[31:0] = A_START_SLAVE4;
		  8'h24: x2pRegPrdata[31:0] = A_END_SLAVE4;
		  default x2pRegPrdata[31:0] = 32'd0;
		endcase
	end
    if(SLAVE_NUM >= 7) begin: REG5
	    case(paddr[7:0])
		  8'h28: x2pRegPrdata[31:0] = A_START_SLAVE5;
		  8'h2C: x2pRegPrdata[31:0] = A_END_SLAVE5;
		endcase
	end
	if(SLAVE_NUM >= 8) begin: REG6
	    case(paddr[7:0])
		  8'h30: x2pRegPrdata[31:0] = A_START_SLAVE6;
		  8'h34: x2pRegPrdata[31:0] = A_END_SLAVE6;
		endcase
	end
	if(SLAVE_NUM >= 9) begin: REG7
	    case(paddr[7:0])
		  8'h38: x2pRegPrdata[31:0] = A_START_SLAVE7;
		  8'h3C: x2pRegPrdata[31:0] = A_END_SLAVE7;
		endcase
	end	
	if(SLAVE_NUM >= 10) begin: REG8
	    case(paddr[7:0])
		  8'h40: x2pRegPrdata[31:0] = A_START_SLAVE8;
		  8'h44: x2pRegPrdata[31:0] = A_END_SLAVE8;
		endcase
	end
	if(SLAVE_NUM >= 11) begin: REG9
	    case(paddr[7:0])
		  8'h48: x2pRegPrdata[31:0] = A_START_SLAVE9;
		  8'h4C: x2pRegPrdata[31:0] = A_END_SLAVE9;
		endcase
	end
    if(SLAVE_NUM >= 12) begin: REG10
	    case(paddr[7:0])
		  8'h50: x2pRegPrdata[31:0] = A_START_SLAVE10;
		  8'h54: x2pRegPrdata[31:0] = A_END_SLAVE10;
		endcase
	end
	if(SLAVE_NUM >= 13) begin: REG11
	    case(paddr[7:0])
		  8'h58: x2pRegPrdata[31:0] = A_START_SLAVE11;
		  8'h5C: x2pRegPrdata[31:0] = A_END_SLAVE11;
		endcase
	end
	if(SLAVE_NUM >= 14) begin: REG12
	    case(paddr[7:0])
		  8'h60: x2pRegPrdata[31:0] = A_START_SLAVE12;
		  8'h64: x2pRegPrdata[31:0] = A_END_SLAVE12;
		endcase
	end	
	if(SLAVE_NUM >= 15) begin: REG13
	    case(paddr[7:0])
		  8'h68: x2pRegPrdata[31:0] = A_START_SLAVE13;
		  8'h6C: x2pRegPrdata[31:0] = A_END_SLAVE13;
		endcase
	end
	if(SLAVE_NUM >= 16) begin: REG14
	    case(paddr[7:0])
		  8'h70: x2pRegPrdata[31:0] = A_START_SLAVE14;
		  8'h74: x2pRegPrdata[31:0] = A_END_SLAVE14;
		endcase
	end
    if(SLAVE_NUM >= 17) begin: REG15
	    case(paddr[7:0])
		  8'h78: x2pRegPrdata[31:0] = A_START_SLAVE15;
		  8'h7C: x2pRegPrdata[31:0] = A_END_SLAVE15;
		endcase
	end
	if(SLAVE_NUM >= 18) begin: REG16
	    case(paddr[7:0])
		  8'h80: x2pRegPrdata[31:0] = A_START_SLAVE16;
		  8'h84: x2pRegPrdata[31:0] = A_END_SLAVE16;
		endcase
	end
	if(SLAVE_NUM >= 19) begin: REG17
	    case(paddr[7:0])
		  8'h88: x2pRegPrdata[31:0] = A_START_SLAVE17;
		  8'h8C: x2pRegPrdata[31:0] = A_END_SLAVE17;
		endcase
	end	
	if(SLAVE_NUM >= 20) begin: REG18
	    case(paddr[7:0])
		  8'h90: x2pRegPrdata[31:0] = A_START_SLAVE18;
		  8'h94: x2pRegPrdata[31:0] = A_END_SLAVE18;
		endcase
	end
	if(SLAVE_NUM >= 21) begin: REG19
	    case(paddr[7:0])
		  8'h98: x2pRegPrdata[31:0] = A_START_SLAVE19;
		  8'h9C: x2pRegPrdata[31:0] = A_END_SLAVE19;
		endcase
	end
    if(SLAVE_NUM >= 22) begin: REG20
	    case(paddr[7:0])
		  8'hA0: x2pRegPrdata[31:0] = A_START_SLAVE20;
		  8'hA4: x2pRegPrdata[31:0] = A_END_SLAVE20;
		endcase
	end
	if(SLAVE_NUM >= 23) begin: REG21
	    case(paddr[7:0])
		  8'hA8: x2pRegPrdata[31:0] = A_START_SLAVE21;
		  8'hAC: x2pRegPrdata[31:0] = A_END_SLAVE21;
		endcase
	end
	if(SLAVE_NUM >= 24) begin: REG22
	    case(paddr[7:0])
		  8'hB0: x2pRegPrdata[31:0] = A_START_SLAVE22;
		  8'hB4: x2pRegPrdata[31:0] = A_END_SLAVE22;
		endcase
	end	
	if(SLAVE_NUM >= 25) begin: REG23
	    case(paddr[7:0])
		  8'hB8: x2pRegPrdata[31:0] = A_START_SLAVE23;
		  8'hBC: x2pRegPrdata[31:0] = A_END_SLAVE23;
		endcase
	end
	if(SLAVE_NUM >= 26) begin: REG24
	    case(paddr[7:0])
		  8'hC0: x2pRegPrdata[31:0] = A_START_SLAVE24;
		  8'hC4: x2pRegPrdata[31:0] = A_END_SLAVE24;
		endcase
	end
    if(SLAVE_NUM >= 27) begin: REG25
	    case(paddr[7:0])
		  8'hC8: x2pRegPrdata[31:0] = A_START_SLAVE25;
		  8'hCC: x2pRegPrdata[31:0] = A_END_SLAVE25;
		endcase
	end
	if(SLAVE_NUM >= 28) begin: REG26
	    case(paddr[7:0])
		  8'hD0: x2pRegPrdata[31:0] = A_START_SLAVE26;
		  8'hD4: x2pRegPrdata[31:0] = A_END_SLAVE26;
		endcase
	end
	if(SLAVE_NUM >= 29) begin: REG27
	    case(paddr[7:0])
		  8'hD8: x2pRegPrdata[31:0] = A_START_SLAVE27;
		  8'hDC: x2pRegPrdata[31:0] = A_END_SLAVE27;
		endcase
	end	
	if(SLAVE_NUM >= 30) begin: REG28
	    case(paddr[7:0])
		  8'hE0: x2pRegPrdata[31:0] = A_START_SLAVE28;
		  8'hE4: x2pRegPrdata[31:0] = A_END_SLAVE28;
		endcase
	end
	if(SLAVE_NUM >= 31) begin: REG29
	    case(paddr[7:0])
		  8'hE8: x2pRegPrdata[31:0] = A_START_SLAVE29;
		  8'hEC: x2pRegPrdata[31:0] = A_END_SLAVE29;
		endcase
	end
    if(SLAVE_NUM >= 32) begin: REG30
	    case(paddr[7:0])
		  8'hF0: x2pRegPrdata[31:0] = A_START_SLAVE30;
		  8'hF4: x2pRegPrdata[31:0] = A_END_SLAVE30;
		endcase
	end
	if(SLAVE_NUM == 33) begin: REG31
	    case(paddr[7:0])
		  8'hF8: x2pRegPrdata[31:0] = A_START_SLAVE31;
		  8'hFC: x2pRegPrdata[31:0] = A_END_SLAVE31;
		endcase
	end
  end
  //endgenerate
  //pready
  assign pready = 1'b1;
  //pslverr
  always_ff @(posedge pclk, negedge preset_n) begin
    if(~preset_n)
	  pslverr <= 1'd0;
	else if(psel) begin
	  if(errorCondition)
	    pslverr <= 1'd1;
      else
	    pslverr <= 1'd0;
	end
  end
  generate
    if(SLAVE_NUM == 2)
	  assign errorCondition = (x2pRegPselReg & x2pRegPenable & x2pRegPwrite) | (x2pRegPaddr[1:0] != 2'b00) | (x2pRegPaddr[31:0] > 32'h0000_0004);
	else if(SLAVE_NUM == 3)
	  assign errorCondition = (x2pRegPselReg & x2pRegPenable & x2pRegPwrite) | (x2pRegPaddr[1:0] != 2'b00) | (x2pRegPaddr[31:0] > 32'h0000_000C);
    else if(SLAVE_NUM == 4)
	  assign errorCondition = (x2pRegPselReg & x2pRegPenable & x2pRegPwrite) | (x2pRegPaddr[1:0] != 2'b00) | (x2pRegPaddr[31:0] > 32'h0000_0014);
	else if(SLAVE_NUM == 5)
	  assign errorCondition = (x2pRegPselReg & x2pRegPenable & x2pRegPwrite) | (x2pRegPaddr[1:0] != 2'b00) | (x2pRegPaddr[31:0] > 32'h0000_001C);
    else if(SLAVE_NUM == 6)
	  assign errorCondition = (x2pRegPselReg & x2pRegPenable & x2pRegPwrite) | (x2pRegPaddr[1:0] != 2'b00) | (x2pRegPaddr[31:0] > 32'h0000_0024);
	else if(SLAVE_NUM == 7)
	  assign errorCondition = (x2pRegPselReg & x2pRegPenable & x2pRegPwrite) | (x2pRegPaddr[1:0] != 2'b00) | (x2pRegPaddr[31:0] > 32'h0000_002C);
    else if(SLAVE_NUM == 8)
	  assign errorCondition = (x2pRegPselReg & x2pRegPenable & x2pRegPwrite) | (x2pRegPaddr[1:0] != 2'b00) | (x2pRegPaddr[31:0] > 32'h0000_0034);
	else if(SLAVE_NUM == 9)
	  assign errorCondition = (x2pRegPselReg & x2pRegPenable & x2pRegPwrite) | (x2pRegPaddr[1:0] != 2'b00) | (x2pRegPaddr[31:0] > 32'h0000_003C);
    else if(SLAVE_NUM == 10)
	  assign errorCondition = (x2pRegPselReg & x2pRegPenable & x2pRegPwrite) | (x2pRegPaddr[1:0] != 2'b00) | (x2pRegPaddr[31:0] > 32'h0000_0044);
	else if(SLAVE_NUM == 11)
	  assign errorCondition = (x2pRegPselReg & x2pRegPenable & x2pRegPwrite) | (x2pRegPaddr[1:0] != 2'b00) | (x2pRegPaddr[31:0] > 32'h0000_004C);
    else if(SLAVE_NUM == 12)
	  assign errorCondition = (x2pRegPselReg & x2pRegPenable & x2pRegPwrite) | (x2pRegPaddr[1:0] != 2'b00) | (x2pRegPaddr[31:0] > 32'h0000_0054);
	else if(SLAVE_NUM == 13)
	  assign errorCondition = (x2pRegPselReg & x2pRegPenable & x2pRegPwrite) | (x2pRegPaddr[1:0] != 2'b00) | (x2pRegPaddr[31:0] > 32'h0000_005C);
    else if(SLAVE_NUM == 14)
	  assign errorCondition = (x2pRegPselReg & x2pRegPenable & x2pRegPwrite) | (x2pRegPaddr[1:0] != 2'b00) | (x2pRegPaddr[31:0] > 32'h0000_0064);
	else if(SLAVE_NUM == 15)
	  assign errorCondition = (x2pRegPselReg & x2pRegPenable & x2pRegPwrite) | (x2pRegPaddr[1:0] != 2'b00) | (x2pRegPaddr[31:0] > 32'h0000_006C);
    else if(SLAVE_NUM == 16)
	  assign errorCondition = (x2pRegPselReg & x2pRegPenable & x2pRegPwrite) | (x2pRegPaddr[1:0] != 2'b00) | (x2pRegPaddr[31:0] > 32'h0000_0074);
	else if(SLAVE_NUM == 17)
	  assign errorCondition = (x2pRegPselReg & x2pRegPenable & x2pRegPwrite) | (x2pRegPaddr[1:0] != 2'b00) | (x2pRegPaddr[31:0] > 32'h0000_007C);
    else if(SLAVE_NUM == 18)
	  assign errorCondition = (x2pRegPselReg & x2pRegPenable & x2pRegPwrite) | (x2pRegPaddr[1:0] != 2'b00) | (x2pRegPaddr[31:0] > 32'h0000_0084);
	else if(SLAVE_NUM == 19)
	  assign errorCondition = (x2pRegPselReg & x2pRegPenable & x2pRegPwrite) | (x2pRegPaddr[1:0] != 2'b00) | (x2pRegPaddr[31:0] > 32'h0000_008C);
    else if(SLAVE_NUM == 20)
	  assign errorCondition = (x2pRegPselReg & x2pRegPenable & x2pRegPwrite) | (x2pRegPaddr[1:0] != 2'b00) | (x2pRegPaddr[31:0] > 32'h0000_0094);
	else if(SLAVE_NUM == 21)
	  assign errorCondition = (x2pRegPselReg & x2pRegPenable & x2pRegPwrite) | (x2pRegPaddr[1:0] != 2'b00) | (x2pRegPaddr[31:0] > 32'h0000_009C);
    else if(SLAVE_NUM == 22)
	  assign errorCondition = (x2pRegPselReg & x2pRegPenable & x2pRegPwrite) | (x2pRegPaddr[1:0] != 2'b00) | (x2pRegPaddr[31:0] > 32'h0000_00A4);
	else if(SLAVE_NUM == 23)
	  assign errorCondition = (x2pRegPselReg & x2pRegPenable & x2pRegPwrite) | (x2pRegPaddr[1:0] != 2'b00) | (x2pRegPaddr[31:0] > 32'h0000_00AC);
    else if(SLAVE_NUM == 24)
	  assign errorCondition = (x2pRegPselReg & x2pRegPenable & x2pRegPwrite) | (x2pRegPaddr[1:0] != 2'b00) | (x2pRegPaddr[31:0] > 32'h0000_00B4);
	else if(SLAVE_NUM == 25)
	  assign errorCondition = (x2pRegPselReg & x2pRegPenable & x2pRegPwrite) | (x2pRegPaddr[1:0] != 2'b00) | (x2pRegPaddr[31:0] > 32'h0000_00BC);
    else if(SLAVE_NUM == 26)
	  assign errorCondition = (x2pRegPselReg & x2pRegPenable & x2pRegPwrite) | (x2pRegPaddr[1:0] != 2'b00) | (x2pRegPaddr[31:0] > 32'h0000_00C4);
	else if(SLAVE_NUM == 27)
	  assign errorCondition = (x2pRegPselReg & x2pRegPenable & x2pRegPwrite) | (x2pRegPaddr[1:0] != 2'b00) | (x2pRegPaddr[31:0] > 32'h0000_00CC);
    else if(SLAVE_NUM == 28)
	  assign errorCondition = (x2pRegPselReg & x2pRegPenable & x2pRegPwrite) | (x2pRegPaddr[1:0] != 2'b00) | (x2pRegPaddr[31:0] > 32'h0000_00D4);
	else if(SLAVE_NUM == 29)
	  assign errorCondition = (x2pRegPselReg & x2pRegPenable & x2pRegPwrite) | (x2pRegPaddr[1:0] != 2'b00) | (x2pRegPaddr[31:0] > 32'h0000_00DC);
    else if(SLAVE_NUM == 30)
	  assign errorCondition = (x2pRegPselReg & x2pRegPenable & x2pRegPwrite) | (x2pRegPaddr[1:0] != 2'b00) | (x2pRegPaddr[31:0] > 32'h0000_00E4);
	else if(SLAVE_NUM == 31)
	  assign errorCondition = (x2pRegPselReg & x2pRegPenable & x2pRegPwrite) | (x2pRegPaddr[1:0] != 2'b00) | (x2pRegPaddr[31:0] > 32'h0000_00EC);
    else if(SLAVE_NUM == 32)
	  assign errorCondition = (x2pRegPselReg & x2pRegPenable & x2pRegPwrite) | (x2pRegPaddr[1:0] != 2'b00) | (x2pRegPaddr[31:0] > 32'h0000_00F4);
	else if(SLAVE_NUM == 33)
	  assign errorCondition = (x2pRegPselReg & x2pRegPenable & x2pRegPwrite) | (x2pRegPaddr[1:0] != 2'b00) | (x2pRegPaddr[31:0] > 32'h0000_00FC);
  endgenerate
endmodule: x2p_register