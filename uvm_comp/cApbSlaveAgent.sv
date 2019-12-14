//--------------------------------------
//Project: The UVM environemnt for X2P (AXI protocol To APB protocol)
//Function: APB Agent
//Author:  Phan Van Tien, Nguyen Hoang Tam,...
//Page:    VLSI Technology
//--------------------------------------
class cApbSlaveAgent extends uvm_agent;
  //Register to Factory
  `uvm_component_utils(cApbSlaveAgent)
  //Declare Sequencer, Driver and Monitor
  cApbSlaveDriver    coApbSlaveDriver;
  cApbSlaveSequencer coApbSlaveSequencer;
  cApbSlaveMonitor   coApbSlaveMonitor;
  //Constructor
  function new(string name = "cApbSlaveAgent", uvm_component parent);
      super.new(name, parent);
  endfunction
  //Build objects
  function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      coApbSlaveDriver    = cApbSlaveDriver::type_id::create("coApbSlaveDriver",this);
      coApbSlaveSequencer = cApbSlaveSequencer::type_id::create("coApbSlaveSequencer",this);
      coApbSlaveMonitor   = cApbSlaveMonitor::type_id::create("coApbSlaveMonitor",this);
  endfunction
  //Connect Driver and Sequencer
  function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      coApbSlaveDriver.seq_item_port.connect(coApbSlaveSequencer.seq_item_export);
  endfunction
    
endclass