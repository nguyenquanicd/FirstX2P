//--------------------------------------
//Project: The UVM environemnt for X2P (AXI protocol To APB protocol)
//Function: APB Agent
//Author:  Phan Van Tien, Nguyen Hoang Tam,...
//Page:    VLSI Technology
//--------------------------------------

class cApbSlaveSequencer extends uvm_sequencer#(cApbTransaction);
	//Register to Factory
	`uvm_component_utils(cApbSlaveSequencer)
  
  //Constructor
	function new (string name = "cApbSlaveSequencer", uvm_component parent = null);
		super.new(name,parent);
	endfunction
endclass