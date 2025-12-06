class base_test extends uvm_test;
    `uvm_component_utils(base_test)
    
    master_tb tb;  // Handle for testbench
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        uvm_config_wrapper::set(this, "tb.env1.tx_agent.sequencer.run_phase",
                                "default_sequence", basic_seq::get_type());
          
       //Enables transaction recording for all components
       uvm_config_int::set(this, "*", "recording_detail", 1);    

        tb = master_tb::type_id::create("tb", this);  // Creating testbench instance
        `uvm_info("TEST_BUILD", "Build phase of test is being executed", UVM_HIGH)
    endfunction
    
    function void end_of_elaboration_phase(uvm_phase phase);
        uvm_top.print_topology();  // Print UVM hierarchy
    endfunction

     virtual function void start_of_simulation_phase(uvm_phase phase);
        `uvm_info("Router_START_SIM", "Start of simulation phase in yapp_base test", UVM_HIGH)
     endfunction
     
    task run_phase(uvm_phase phase);
      uvm_objection obj = phase.get_objection();
      obj.set_drain_time(this, 200ns);
    endtask

endclass

class write_test extends base_test;
 `uvm_component_utils(write_test)

  function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

  function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        uvm_config_int::set(this, "*", "recording_detail", 1); 
        uvm_config_wrapper::set(this, "tb.env1.tx_agent.sequencer.run_phase",
                                "default_sequence", basic_seq::get_type());
    endfunction
endclass