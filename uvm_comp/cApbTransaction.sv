//--------------------------------------
//Project: The UVM environemnt for X2P (AXI protocol To APB protocol)
//Function: APB Agent
//Author:  Phan Van Tien, Nguyen Hoang Tam,...
//Page:    VLSI Technology
//--------------------------------------
class cApbTransaction extends uvm_sequence_item;
  rand bit preset_n;
  rand bit [`SLAVE_NUM:0]pready;
  rand bit [`SLAVE_NUM:0] [31: 0] prdata;
  rand bit [`SLAVE_NUM:0] pslverr;
  rand bit [7:0] preadyDelay;
  //
  logic [31:0] paddr;
  logic [31: 0] pwdata;
  logic [`SLAVE_NUM:0] psel;
  logic [2:0] pprot;
  logic [3:0] pstrb;
  logic pwrite;
  `uvm_object_utils_begin (cApbTransaction)
  `uvm_field_int(pready, UVM_ALL_ON)
  `uvm_field_int(prdata, UVM_ALL_ON)
  `uvm_field_int(pslverr, UVM_ALL_ON)
  `uvm_field_int(preadyDelay, UVM_ALL_ON)
  `uvm_field_int(paddr, UVM_ALL_ON)
  `uvm_field_int(pwdata, UVM_ALL_ON)
  `uvm_field_int(psel, UVM_ALL_ON)
  `uvm_field_int(pprot, UVM_ALL_ON)
  `uvm_field_int(pstrb, UVM_ALL_ON)
  `uvm_object_utils_end
  //Constructor
  function new (string name = "cApbTransaction");
    super.new(name);
  endfunction: new
endclass: cApbTransaction