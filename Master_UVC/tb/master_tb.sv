class master_tb extends uvm_env;                     //extending class from uvm_env
    `uvm_component_utils(master_tb)                  //registering this component in UVM Factory
    master_env env1;
    
    function new(string name, uvm_component parent);  //Constructor along with parent and component name
        super.new(name, parent);
    endfunction
    
    function void build_phase(uvm_phase phase);      //used to construct and configure the testbench hierarchy        
        super.build_phase(phase);
        env1=master_env::type_id::create("env1",this);
       
        `uvm_info("Router_tb_BUILD", "Build phase of testbench is being executed", UVM_HIGH) //macro for printing information
    endfunction

   function void start_of_simulation_phase(uvm_phase phase);
        `uvm_info("Router_START_SIM", "Start of simulation phase in yapp_router", UVM_HIGH)
     endfunction

endclass
