class master_agent extends uvm_agent;
    
    // Component utility macro with is_active field
    `uvm_component_utils_begin(master_agent )
        `uvm_field_enum(uvm_active_passive_enum, is_active, UVM_ALL_ON)
    `uvm_component_utils_end
    
    // Declare handles for sub-components
    master_monitor    monitor;
    master_driver     driver;
    master_sequencer  sequencer;
    
    // Component constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    // Build phase method
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
        // Monitor is always constructed
        monitor = master_monitor::type_id::create("monitor", this);
        
        // Driver and sequencer only constructed if active
        if (is_active == UVM_ACTIVE) begin
            driver = master_driver::type_id::create("driver", this);
            sequencer = master_sequencer::type_id::create("sequencer", this);
        end
    endfunction

    // Connect phase method
    function void connect_phase(uvm_phase phase);
                                                                                 // Connect driver to sequencer only if active
        if (is_active == UVM_ACTIVE) begin
            driver.seq_item_port.connect(sequencer.seq_item_export);             // communication channel between the sequencer and driver:
        end
    endfunction


    virtual function void start_of_simulation_phase(uvm_phase phase);
        `uvm_info("Agent_START_SIM", "Start of simulation phase in yapp_tx_Agent", UVM_HIGH)
     endfunction

endclass
