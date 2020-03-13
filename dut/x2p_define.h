//===================================================================================
// File name:	x2p_define.h
// Project:	X2P
// Function:	
// Author:	phamanhthang147@gmail.com
// Website: http://nguyenquanicd.blogspot.com
//===================================================================================

//All defines are used to configured the X2P before synthesizing
//Data bus width is 32 bit
//`define MODE32_32
//Data bus width is 64 bit
`define MODE64_32
//Data bus width is 128 bit
//`define MODE128_32
//Data bus width is 256 bit
//`define MODE256_32
//Data bus width is 512 bit
//`define MODE512_32
//Data bus width is 1024 bit
//`define MODE1024_32

`ifdef MODE1024_32
  `define MODE1024_32_MODE512_32_MODE256_32_MODE128_32_MODE64_32_MODE32_32
  `define MODE1024_32_MODE512_32_MODE256_32_MODE128_32_MODE64_32
  `define MODE1024_32_MODE512_32_MODE256_32_MODE128_32
  `define MODE1024_32_MODE512_32_MODE256_32
  `define MODE1024_32_MODE512_32 
`elsif MODE512_32
  `define MODE1024_32_MODE512_32_MODE256_32_MODE128_32_MODE64_32_MODE32_32
  `define MODE1024_32_MODE512_32_MODE256_32_MODE128_32_MODE64_32
  `define MODE1024_32_MODE512_32_MODE256_32_MODE128_32
  `define MODE1024_32_MODE512_32_MODE256_32
  `define MODE1024_32_MODE512_32
`elsif MODE256_32
  `define MODE1024_32_MODE512_32_MODE256_32_MODE128_32_MODE64_32_MODE32_32
  `define MODE1024_32_MODE512_32_MODE256_32_MODE128_32_MODE64_32
  `define MODE1024_32_MODE512_32_MODE256_32_MODE128_32
  `define MODE1024_32_MODE512_32_MODE256_32
`elsif MODE128_32
  `define MODE1024_32_MODE512_32_MODE256_32_MODE128_32_MODE64_32_MODE32_32
  `define MODE1024_32_MODE512_32_MODE256_32_MODE128_32_MODE64_32	
  `define MODE1024_32_MODE512_32_MODE256_32_MODE128_32
`elsif MODE64_32
  `define MODE1024_32_MODE512_32_MODE256_32_MODE128_32_MODE64_32_MODE32_32
  `define MODE1024_32_MODE512_32_MODE256_32_MODE128_32_MODE64_32
`elsif MODE32_32
  `define MODE1024_32_MODE512_32_MODE256_32_MODE128_32_MODE64_32_MODE32_32
`endif
//-----------------------------------------