package slave_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
 typedef enum bit {WRITE, READ} trans_kind_e;
 //typedef uvm_config_db#(virtual axi4lite_intf) axi4_lite_config;
    `include "slave_seq_item.sv"
    `include "slave_monitor.sv"
    `include "slave_sequencer.sv"
    `include "slave_seqs.sv"
    `include "slave_driver.sv"
    `include "slave_agent.sv"
    `include "slave_env.sv"
endpackage
