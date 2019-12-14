
class cApbSlaveDriver extends uvm_driver #(cApbTransaction);
  //1. Declare the virtual interface
  virtual ifApbSlave vifApbSlave;
  cApbTransaction ApbPacket;
  //2. Register to the factory
  //`uvm_component_utils is for non-parameterized classes
  `uvm_component_utils(cApbSlaveDriver)
  //3. Class constructor with two arguments
  // - A string "name"
  // - A class object with data type uvm_component
  function new (string name, uvm_component parent);
    //Call the function new of the base class "uvm_driver"
    super.new(name, parent);
  endfunction: new
  //4. Build phase
  // - super.build_phase is called and executed first
  // - Configure the component before creating it
  // - Create the UVM component
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    //All of the functions in uvm_config_db are static, using :: to call them
    //If the call "get" is unsuccessful, the fatal is triggered
    if (!uvm_config_db#(virtual interface ifApbSlave)::get(.cntxt(this),
          .inst_name(""),
          .field_name("vifApbSlave"))) begin
       //`uvm_fatal(ID, MSG)
       //ID: message tag
       //MSG message text
       //get_full_name returns the full hierarchical name of the driver object
       `uvm_fatal("NON-APBIF", {"A virtual interface must be set for: ", get_full_name(), ".vifApbSlave"})
     end
      //
      `uvm_info(get_full_name(), "Build phase completed.", UVM_LOW)
  endfunction
  //5. Run phase
  //Call 2 tasks for parallel execution
  virtual task run_phase (uvm_phase phase);
    fork
      reset_all ();
      get_seq_and_drive ();
	  drive_2_slave ();
    join
  endtask
  //
  //Methods
  //
  //Initiate all control signals when the reset is active
  //Run time: run until the end of the simulation
  virtual task reset_all();
    wait (~vifApbSlave.preset_n) begin
      vifApbSlave.psel    = 1'b0;
      vifApbSlave.penable = 1'b0;
    end
    //
    while (1) begin
      @ (negedge vifApbSlave.preset_n);
      //@ (posedge vifApbSlave.pclk); //Reset of DUT is synchronize reset
      //if (~vifApbSlave.preset_n) begin
        vifApbSlave.psel    = 1'b0;
        vifApbSlave.penable = 1'b0;
      //end
      //@ (posedge vifApbSlave.preset_n);
      //`uvm_info (get_type_name(), "END of reset", UVM_LOW)
    end
    //
  endtask: reset_all
  //Initiate the communication with the sequencer to get a sequence (a transaction)
  //in non-reset mode
  //Run time: run until the end of the simulation
  virtual task get_seq_and_drive();
    forever begin
      @ (posedge vifApbSlave.preset_n);
      while (vifApbSlave.preset_n) begin
        //if (vifApbSlave.preset_n) begin
          //The seq_item_port.get_next_item is used to get items from the sequencer
          seq_item_port.get_next_item(ApbPacket);
          //req is assigned to convert_seq2apb to drive the APB interface
          convert_seq2apb(ApbPacket);
          //Report the done execution
          seq_item_port.item_done();
        //end
      end
    end
  endtask: get_seq_and_drive
  //
  virtual task convert_seq2apb (cApbTransaction userApbTransaction);
    //Note:
    // 1. psel of cApbTransaction is used an valid flag of an APB packet
    // 2. penable of cApbTransaction is not used
    
    @ (posedge vifApbSlave.pclk);
      //SETUP state of APB protocol
      vifApbSlave.psel[`SLAVE_NUM:0] = 1;
      vifApbSlave.pwrite       = userApbTransaction.pwrite;
      vifApbSlave.paddr[31:0]  = userApbTransaction.paddr[31:0];
      vifApbSlave.pwdata[31:0] = userApbTransaction.pwdata[31:0];
      vifApbSlave.pstrb[3:0]   = userApbTransaction.pstrb[3:0];
	  
      //Hold one cycle before jumping to ACCESS phase of APB protocol
      repeat (1) @ (posedge vifApbSlave.pclk); 
      //ACCESS state of APB protocol
      vifApbSlave.penable = 1'b1;
	  vifApbSlave.pready = 1; 
      //Store read data if this is a read transaction
      if (~vifApbSlave.pwrite && vifApbSlave.pready) begin
         userApbTransaction.prdata[`SLAVE_NUM:0][31:0] = vifApbSlave.prdata[`SLAVE_NUM:0][31:0];
      end
      //Store pslverr
      userApbTransaction.pslverr[`SLAVE_NUM:0] = vifApbSlave.pslverr[`SLAVE_NUM:0];
      //ENABLE phase is hold in one cycle
      repeat (1) @ (posedge vifApbSlave.pclk);
      //Release psel and penable
      vifApbSlave.psel    = 1'b0;
      vifApbSlave.penable = 1'b0;
    end
    else begin
      vifApbSlave.psel    = 1'b0;
      vifApbSlave.penable = 1'b0;
    end
  endtask: convert_seq2apb
  
virtual task drive_2_slave();
    forever begin
	@ (posedge vifApbSlave.pclk);
      if (psel[1])
		pready[0] = 1'b1;
		prdata[0] [31:0] = userApbTransaction.prdata[31:0];
		pslverr[0] = 1'b0;
	  if (psel[0]) 
    end
  endtask: drive_2_slave
endclass