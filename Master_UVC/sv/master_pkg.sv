package master_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
 typedef uvm_config_db#(virtual axi4lite_intf) axi4_lite_config;
    `include "master_seq_item.sv"
    `include "master_monitor.sv"
    `include "master_sequencer.sv"
    `include "master_seqs.sv"
    `include "master_driver.sv"
    `include "master_agent.sv"
    `include "master_env.sv"
endpackage
