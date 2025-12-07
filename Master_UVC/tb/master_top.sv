module master_top;
    // import the UVM library
    import uvm_pkg::*;
    // include the UVM macros  
    `include "uvm_macros.svh"  
    
    // import the YAPP package
    import master_pkg::*;
    import slave_pkg::*;

    // Include testbench and test
    `include "master_tb.sv"
    `include "master_testlib.sv"  // Contains base_test
    `include "slave_tb.sv"
    `include "slave_testlib.sv"
  
    hw_top hw_top_inst();  
    initial begin
      axi4_lite_config::set(
            null,
            "*.tx_agent*",
            "axi",
            hw_top_inst.intf
        );
     axi4_lite_config::set(
            null,
            "*.rx_agent*",  
            "axi",          
            hw_top_inst.intf 
        );
        run_test("write_test");  // Start UVM phasing with base_test
    end

endmodule 
