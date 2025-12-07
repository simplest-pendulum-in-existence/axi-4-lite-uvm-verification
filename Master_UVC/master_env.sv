class master_env extends uvm_env;
    
    // Component utility macro
    `uvm_component_utils(master_env)
    
    // Handle for the yapp_tx_agent
    master_agent tx_agent;
    
    // Component constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    // Build phase method
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
        // Constructing the agent
        tx_agent = master_agent::type_id::create("tx_agent", this);
    endfunction

      virtual function void start_of_simulation_phase(uvm_phase phase);
        `uvm_info("Environment_START_SIM", "Start of simulation phase in yapp_Environment", UVM_HIGH)
     endfunction

endclass



