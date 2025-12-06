module master_top;
    // import the UVM library
    import uvm_pkg::*;
    // include the UVM macros  
    `include "uvm_macros.svh"  
    
    // import the YAPP package
    import master_pkg::*;
    
    // Include testbench and test
    `include "master_tb.sv"
    `include "master_testlib.sv"  // Contains base_test
  
    hw_top hw_top_inst();  
    initial begin
      axi4_lite_config::set(
            null,
            "*.tx_agent*",
            "axi",
            hw_top_inst.intf
        );
        run_test("write_test");  // Start UVM phasing with base_test
    end

endmodule 
