//parameter declaration
//data width AXI
`include "x2p_define.h"
`ifdef MODE32_32
  parameter DATA_WIDTH_AXI = 32;
`endif
`ifdef MODE64_32
  parameter DATA_WIDTH_AXI = 64;
`endif
`ifdef MODE128_32
  parameter DATA_WIDTH_AXI = 128;
`endif
`ifdef MODE256_32
  parameter DATA_WIDTH_AXI = 256;
`endif
`ifdef MODE512_32
  parameter DATA_WIDTH_AXI = 512;
`endif
`ifdef MODE1024_32
  parameter DATA_WIDTH_AXI = 1024;
`endif
parameter LEN_WIDTH       = 8;
parameter ADDR_WIDTH      = 32;
parameter SIZE_WIDTH      = 8;
parameter ID_WIDTH        = 8;
parameter DATA_WIDTH_APB  = 32;

//FIFO
parameter X2P_SFIFO_AW_DATA_WIDTH = ADDR_WIDTH + LEN_WIDTH + ID_WIDTH + SIZE_WIDTH + 5;
parameter X2P_SFIFO_AR_DATA_WIDTH = ADDR_WIDTH + LEN_WIDTH + ID_WIDTH + SIZE_WIDTH + 5;
parameter X2P_SFIFO_WD_DATA_WIDTH = DATA_WIDTH_AXI + DATA_WIDTH_AXI/8;
parameter X2P_SFIFO_RD_DATA_WIDTH = DATA_WIDTH_AXI + ID_WIDTH + 2;
parameter POINTER_WIDTH           = 4;
//state machine
parameter IDLE                    = 2'b00;
parameter SETUP                   = 2'b01;
parameter ACCESS                  = 2'b10;
//Error
parameter OKAY                    = 2'b00;
parameter DECERR                  = 2'b11;
parameter PSLVERR                 = 2'b10;
//parameter SLAVE_NUM is used to set number of APB slave
parameter SLAVE_NUM = 4 ;

//address of Register block
parameter A_START_REG     = 32'h0000_0000;
parameter A_END_REG       = 32'h0000_0FFF; 
//address of SLAVE APB
  parameter A_START_SLAVE0  = 32'h0000_1000;
  parameter A_END_SLAVE0    = 32'h0000_1FFF;
  parameter A_START_SLAVE1  = 32'h0000_2000;
  parameter A_END_SLAVE1    = 32'h0000_2FFF;
  parameter A_START_SLAVE2  = 32'h0000_3000;
  parameter A_END_SLAVE2    = 32'h0000_3FFF;
  parameter A_START_SLAVE3  = 32'h0000_4000;
  parameter A_END_SLAVE3    = 32'h0000_4FFF;
  parameter A_START_SLAVE4  = 32'h0000_5000;
  parameter A_END_SLAVE4    = 32'h0000_5FFF;
  parameter A_START_SLAVE5  = 32'h0000_6000;
  parameter A_END_SLAVE5    = 32'h0000_6FFF;
  parameter A_START_SLAVE6  = 32'h0000_7000;
  parameter A_END_SLAVE6    = 32'h0000_7FFF;
  parameter A_START_SLAVE7  = 32'h0000_8000;
  parameter A_END_SLAVE7    = 32'h0000_8FFF;
  parameter A_START_SLAVE8  = 32'h0000_9000;
  parameter A_END_SLAVE8    = 32'h0000_9FFF;
  parameter A_START_SLAVE9  = 32'h0000_A000;
  parameter A_END_SLAVE9    = 32'h0000_AFFF;
  parameter A_START_SLAVE10 = 32'h0000_B000;
  parameter A_END_SLAVE10   = 32'h0000_BFFF;
  parameter A_START_SLAVE11 = 32'h0000_C000;
  parameter A_END_SLAVE11   = 32'h0000_CFFF;
  parameter A_START_SLAVE12 = 32'h0000_D000;
  parameter A_END_SLAVE12   = 32'h0000_DFFF;
  parameter A_START_SLAVE13 = 32'h0000_E000;
  parameter A_END_SLAVE13   = 32'h0000_EFFF;
  parameter A_START_SLAVE14 = 32'h0000_F000;
  parameter A_END_SLAVE14   = 32'h0000_FFFF;
  parameter A_START_SLAVE15 = 32'h0001_0000;
  parameter A_END_SLAVE15   = 32'h0001_0FFF;
  parameter A_START_SLAVE16 = 32'h0001_1000;
  parameter A_END_SLAVE16   = 32'h0001_1FFF;
  parameter A_START_SLAVE17 = 32'h0001_2000;
  parameter A_END_SLAVE17   = 32'h0001_2FFF;
  parameter A_START_SLAVE18 = 32'h0000_3000;
  parameter A_END_SLAVE18   = 32'h0001_3FFF;
  parameter A_START_SLAVE19 = 32'h0001_4000;
  parameter A_END_SLAVE19   = 32'h0001_4FFF;
  parameter A_START_SLAVE20 = 32'h0001_5000;
  parameter A_END_SLAVE20   = 32'h0001_5FFF;
  parameter A_START_SLAVE21 = 32'h0001_6000;
  parameter A_END_SLAVE21   = 32'h0001_6FFF;
  parameter A_START_SLAVE22 = 32'h0001_7000;
  parameter A_END_SLAVE22   = 32'h0001_7FFF;
  parameter A_START_SLAVE23 = 32'h0001_8000;
  parameter A_END_SLAVE23   = 32'h0001_8FFF;
  parameter A_START_SLAVE24 = 32'h0001_9000;
  parameter A_END_SLAVE24   = 32'h0001_9FFF;
  parameter A_START_SLAVE25 = 32'h0001_A000;
  parameter A_END_SLAVE25   = 32'h0001_AFFF;
  parameter A_START_SLAVE26 = 32'h0001_B000;
  parameter A_END_SLAVE26   = 32'h0001_BFFF;
  parameter A_START_SLAVE27 = 32'h0001_C000;
  parameter A_END_SLAVE27   = 32'h0001_CFFF;
  parameter A_START_SLAVE28 = 32'h0001_D000;
  parameter A_END_SLAVE28   = 32'h0001_DFFF;
  parameter A_START_SLAVE29 = 32'h0001_E000;
  parameter A_END_SLAVE29   = 32'h0001_EFFF;
  parameter A_START_SLAVE30 = 32'h0001_F000;
  parameter A_END_SLAVE30   = 32'h0001_FFFF;
  parameter A_START_SLAVE31 = 32'h0002_0000;
  parameter A_END_SLAVE31   = 32'h0002_0FFF;
  parameter A_START_SLAVE32  = 32'h0002_1000;
  parameter A_END_SLAVE32    = 32'h0002_1FFF;
  parameter A_START_SLAVE33  = 32'h0002_2000;
  parameter A_END_SLAVE33    = 32'h0002_2FFF;
  parameter A_START_SLAVE34  = 32'h0002_3000;
  parameter A_END_SLAVE34    = 32'h0002_3FFF;
  parameter A_START_SLAVE35  = 32'h0002_4000;
  parameter A_END_SLAVE35    = 32'h0002_4FFF;
  parameter A_START_SLAVE36  = 32'h0002_5000;
  parameter A_END_SLAVE36    = 32'h0002_5FFF;
  parameter A_START_SLAVE37  = 32'h0002_6000;
  parameter A_END_SLAVE37    = 32'h0002_6FFF;
  parameter A_START_SLAVE38  = 32'h0002_7000;
  parameter A_END_SLAVE38    = 32'h0002_7FFF;
  parameter A_START_SLAVE39  = 32'h0002_8000;
  parameter A_END_SLAVE39    = 32'h0002_8FFF;
  parameter A_START_SLAVE40  = 32'h0002_9000;
  parameter A_END_SLAVE40    = 32'h0002_9FFF;
  parameter A_START_SLAVE41  = 32'h0002_A000;
  parameter A_END_SLAVE41    = 32'h0002_AFFF;
  parameter A_START_SLAVE42 = 32'h0002_B000;
  parameter A_END_SLAVE42   = 32'h0002_BFFF;
  parameter A_START_SLAVE43 = 32'h0002_C000;
  parameter A_END_SLAVE43   = 32'h0002_CFFF;
  parameter A_START_SLAVE44 = 32'h0002_D000;
  parameter A_END_SLAVE44   = 32'h0002_DFFF;
  parameter A_START_SLAVE45 = 32'h0002_E000;
  parameter A_END_SLAVE45   = 32'h0002_EFFF;
  parameter A_START_SLAVE46 = 32'h0002_F000;
  parameter A_END_SLAVE46   = 32'h0002_FFFF;
  parameter A_START_SLAVE47 = 32'h0003_0000;
  parameter A_END_SLAVE47   = 32'h0003_0FFF;
  parameter A_START_SLAVE48 = 32'h0003_1000;
  parameter A_END_SLAVE48   = 32'h0003_1FFF;
  parameter A_START_SLAVE49 = 32'h0003_2000;
  parameter A_END_SLAVE49   = 32'h0003_2FFF;
  parameter A_START_SLAVE50 = 32'h0003_3000;
  parameter A_END_SLAVE50   = 32'h0003_3FFF;
  parameter A_START_SLAVE51 = 32'h0003_4000;
  parameter A_END_SLAVE51   = 32'h0003_4FFF;
  parameter A_START_SLAVE52 = 32'h0003_5000;
  parameter A_END_SLAVE52   = 32'h0003_5FFF;
  parameter A_START_SLAVE53 = 32'h0003_6000;
  parameter A_END_SLAVE53   = 32'h0003_6FFF;
  parameter A_START_SLAVE54 = 32'h0003_7000;
  parameter A_END_SLAVE54   = 32'h0003_7FFF;
  parameter A_START_SLAVE55 = 32'h0003_8000;
  parameter A_END_SLAVE55   = 32'h0003_8FFF;
  parameter A_START_SLAVE56 = 32'h0003_9000;
  parameter A_END_SLAVE56   = 32'h0003_9FFF;
  parameter A_START_SLAVE57 = 32'h0003_A000;
  parameter A_END_SLAVE57   = 32'h0003_AFFF;
  parameter A_START_SLAVE58 = 32'h0003_B000;
  parameter A_END_SLAVE58   = 32'h0003_BFFF;
  parameter A_START_SLAVE59 = 32'h0003_C000;
  parameter A_END_SLAVE59   = 32'h0003_CFFF;
  parameter A_START_SLAVE60 = 32'h0003_D000;
  parameter A_END_SLAVE60   = 32'h0003_DFFF;
  parameter A_START_SLAVE61 = 32'h0003_E000;
  parameter A_END_SLAVE61   = 32'h0003_EFFF;
  parameter A_START_SLAVE62 = 32'h0003_F000;
  parameter A_END_SLAVE62   = 32'h0003_FFFF;
  parameter A_START_SLAVE63 = 32'h0004_0000;
  parameter A_END_SLAVE63   = 32'h0004_0FFF;
