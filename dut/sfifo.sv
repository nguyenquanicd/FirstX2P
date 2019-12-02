//===================================================================================
// File name:	sfifo.v
// Project:	  RTL code generator
// Module:    Flexible synchronous FIFO
// Function:	Synchronous FIFO with the configuration parameters
// Author:	  nguyenquan.icd@gmail.com
// Website:   http://nguyenquanicd.blogspot.com
// License:   It's free but do not remove header when you use this RTL code for your project
//===================================================================================

//All defines are used to configured the synchronous FIFO before synthesizing
`ifndef EMPTY_SIGNAL
  `define EMPTY_SIGNAL
`endif
`ifndef FULL_SIGNAL
  `define FULL_SIGNAL
`endif
//`define SET_LOW_EN
//`define SET_HIGH_EN
//`define LOW_TH_SIGNAL
//`define HIGH_TH_SIGNAL
//`define OV_SIGNAL
//`define UD_SIGNAL
//`define OUTPUT_REG
//`define TWO_CLOCK
module sfifo (rst_n, wr, rd,
                  `ifdef TWO_CLOCK
                    clk_rd, clk_wr,
                  `else
                    clk,
                  `endif
                  `ifdef EMPTY_SIGNAL
                    sfifo_empty,
                  `endif
                  `ifdef FULL_SIGNAL
                    sfifo_full,
                  `endif
                  `ifdef SET_LOW_EN
                    low_th,
                  `endif
                  `ifdef SET_HIGH_EN
                    high_th,
                  `endif
                  `ifdef LOW_TH_SIGNAL
                    sfifo_low_th,
                  `endif
                  `ifdef HIGH_TH_SIGNAL
                    sfifo_high_th,
                  `endif
                  `ifdef OV_SIGNAL
                    sfifo_ov,
                  `endif
                  `ifdef UD_SIGNAL
                    sfifo_ud,
                  `endif
                    data_in, data_out);
//Parameters are used to set the capacity of FIFO
parameter DATA_WIDTH    = 8;
parameter POINTER_WIDTH = 3;
//
`ifndef SET_HIGH_EN
  parameter TH_LEVEL  = (2**POINTER_WIDTH)/2;
`else
  `ifndef SET_LOW_EN
     parameter TH_LEVEL  = (2**POINTER_WIDTH)/2;
  `endif
`endif
parameter DATA_NUM      = 2**POINTER_WIDTH;
//
//inputs
`ifdef TWO_CLOCK
  input clk_rd;
  input clk_wr;
`else
  input clk;
`endif
`ifdef SET_LOW_EN
  input [POINTER_WIDTH:0] low_th;
`endif
`ifdef SET_HIGH_EN
  input [POINTER_WIDTH:0] high_th;
`endif
input rst_n;
input wr;
input rd;
input [DATA_WIDTH-1:0] data_in;
//outputs
output  reg [DATA_WIDTH-1:0] data_out;
`ifdef LOW_TH_SIGNAL
  output wire sfifo_low_th;
`endif
`ifdef HIGH_TH_SIGNAL
  output wire sfifo_high_th;
`endif
`ifdef OV_SIGNAL
  output wire sfifo_ov;
`endif
`ifdef UD_SIGNAL
  output wire sfifo_ud;
`endif
`ifdef EMPTY_SIGNAL
  output  sfifo_empty;
`else
  wire    sfifo_empty;
`endif
`ifdef FULL_SIGNAL
  output  sfifo_full;
`else
  wire    sfifo_full;
`endif
//internal signals
reg [POINTER_WIDTH:0] w_pointer;
reg [POINTER_WIDTH:0] r_pointer;
reg [DATA_WIDTH-1:0] mem_array [DATA_NUM-1:0];
wire    msb_diff;
wire    lsb_equal;
wire    sfifo_re;
wire    sfifo_we;
//write pointer
assign sfifo_we = wr & (~sfifo_full);
//
`ifdef TWO_CLOCK
  wire rclk = clk_rd;
  wire wclk = clk_wr;
`else
  wire rclk = clk;
  wire wclk = clk;
`endif
always @ (posedge wclk or negedge rst_n) begin
  if (~rst_n) w_pointer <= {POINTER_WIDTH+1{1'b0}};
  else if (sfifo_we) w_pointer <= w_pointer+1'b1;
end
//read pointer
assign sfifo_re = rd & (~sfifo_empty);
//
always @ (posedge rclk or negedge rst_n) begin
  if (~rst_n) r_pointer <= {POINTER_WIDTH+1{1'b0}};
  else if (sfifo_re) r_pointer <= r_pointer + 1'b1;
end
//memory array and write decoder
always @ (posedge wclk) begin
  if (sfifo_we)
    mem_array[w_pointer[POINTER_WIDTH-1:0]]
             <= data_in[DATA_WIDTH-1:0];
end
//read decoder
`ifdef OUTPUT_REG
  always @ (posedge rclk) begin
    data_out[DATA_WIDTH-1:0]
    <= mem_array[r_pointer[POINTER_WIDTH-1:0]];
  end
`else
  always @ (*) begin
    data_out[DATA_WIDTH-1:0]
    = mem_array[r_pointer[POINTER_WIDTH-1:0]];
  end
`endif
//status signal
assign  msb_diff = w_pointer[POINTER_WIDTH]
                  ^r_pointer[POINTER_WIDTH];
//
assign  lsb_equal = (w_pointer[POINTER_WIDTH-1:0]
                  == r_pointer[POINTER_WIDTH-1:0]);
//
assign  sfifo_full = msb_diff & lsb_equal;
//
assign  sfifo_empty = (~msb_diff) & lsb_equal;
//Overflow
`ifdef OV_SIGNAL
  reg ov_reg;
  `ifdef TWO_CLOCK
    assign sfifo_ov = ov_reg & sfifo_full;
    wire clr_ov = ~sfifo_full;
  `else
    wire clr_ov = sfifo_re;
    assign sfifo_ov = ov_reg;
  `endif
  always @ (posedge wclk) begin
    if (~rst_n) ov_reg <= 1'b0;
    else if (clr_ov) ov_reg <= 1'b0;
    else if (wr & sfifo_full) ov_reg <= 1'b1;
  end
`endif
//Underflow
`ifdef UD_SIGNAL
  reg ud_reg;
  `ifdef TWO_CLOCK
    assign sfifo_ud = ud_reg & sfifo_empty;
    wire clr_ud = ~sfifo_empty;
  `else
    assign sfifo_ud = ud_reg;
    wire clr_ud = sfifo_we;
  `endif
  always @ (posedge rclk) begin
    if (~rst_n) ud_reg <= 1'b0;
    else if (clr_ud) ud_reg <= 1'b0;
    else if (rd & sfifo_empty) ud_reg <= 1'b1;
  end
`endif
//The minus result of two pointers
`ifdef LOW_TH_SIGNAL
  wire [POINTER_WIDTH:0] minus_result = w_pointer[POINTER_WIDTH:0] - r_pointer[POINTER_WIDTH:0];
`else
  `ifdef HIGH_TH_SIGNAL
    wire [POINTER_WIDTH:0] minus_result = w_pointer[POINTER_WIDTH:0] - r_pointer[POINTER_WIDTH:0];
  `endif
`endif
//The low threshold signal
`ifdef LOW_TH_SIGNAL
  `ifdef SET_LOW_EN
    wire [POINTER_WIDTH:0] low_level = low_th[POINTER_WIDTH:0];
  `else
    wire [POINTER_WIDTH:0] low_level = TH_LEVEL;
  `endif
`endif

`ifdef LOW_TH_SIGNAL
  assign sfifo_low_th = (minus_result[POINTER_WIDTH:0] < low_level[POINTER_WIDTH:0]);
`endif
//The high threshold signal
`ifdef HIGH_TH_SIGNAL
  `ifdef SET_HIGH_EN
    wire [POINTER_WIDTH:0] high_level = high_th[POINTER_WIDTH:0];
  `else
    wire [POINTER_WIDTH:0] high_level = TH_LEVEL;
  `endif
`endif

`ifdef HIGH_TH_SIGNAL
  assign sfifo_high_th = (minus_result[POINTER_WIDTH:0] >= high_level[POINTER_WIDTH:0]);
`endif
endmodule: sfifo
