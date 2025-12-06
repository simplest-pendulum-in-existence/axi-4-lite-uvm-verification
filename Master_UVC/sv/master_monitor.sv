class master_monitor extends uvm_monitor;
    
    // Component utility macro
    `uvm_component_utils(master_monitor )
    
    // Component constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    // Run phase task
    task run_phase(uvm_phase phase);
        `uvm_info("YAPP_TX_MONITOR", "You are in the monitor", UVM_LOW)
    endtask
   
    virtual function void start_of_simulation_phase(uvm_phase phase);
        `uvm_info("Monitor_START_SIM", "Start of simulation phase in yapp_tx_Monitor", UVM_HIGH)
     endfunction

endclass
