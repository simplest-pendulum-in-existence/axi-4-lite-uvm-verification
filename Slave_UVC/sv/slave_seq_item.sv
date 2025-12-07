class slave_seq_item #(parameter DATA_WIDTH = 32, parameter ADDR_WIDTH = 32) extends uvm_sequence_item;


    // The Slave driver uses these to determine how long to wait before    
    rand int awready_delay; // Delay before asserting AWREADY
    rand int wready_delay;  // Delay before asserting WREADY
    rand int bvalid_delay;  // Delay before asserting BVALID (Response)
    
    rand int arready_delay; // Delay before asserting ARREADY
    rand int rvalid_delay;  // Delay before asserting RVALID (Read Data)

    // from the interface and stores them here for the monitor/scoreboard.
    
    trans_kind_e           trans_kind; // Set by Driver based on channel activity
    bit [ADDR_WIDTH-1:0]   AWADDR;
    bit [2:0]              AWPROT;
    bit [DATA_WIDTH-1:0]   WDATA;
    bit [DATA_WIDTH/8-1:0] WSTRB;
    
    bit [ADDR_WIDTH-1:0]   ARADDR;
    bit [2:0]              ARPROT;

    // RESPONSE FIELDS (Randomized Outputs to Master)
    
    rand bit [1:0]            BRESP; // Write Response Status (OKAY, DECERR, etc.)
    rand bit [DATA_WIDTH-1:0] RDATA; // Read Data content
    rand bit [1:0]            RRESP; // Read Response Status

    // CONSTRAINTS (Protocol Rules & Defaults)

    constraint c_slave_default {
        // 1. Default to "OKAY" (2'b00) but allow errors via inline constraints
        soft BRESP == 2'b00;
        soft RRESP == 2'b00;

        // 2. Default Delays (Fast Slave behavior)
        // We use soft constraints so a test can force a "Slow Slave" scenario
        soft awready_delay inside {[0:5]};
        soft wready_delay  inside {[0:5]};
        soft bvalid_delay  inside {[0:5]};
        
        soft arready_delay inside {[0:5]};
        soft rvalid_delay  inside {[0:5]};
    }

    // UVM AUTOMATION

    `uvm_object_param_utils_begin(slave_seq_item #(DATA_WIDTH, ADDR_WIDTH))
        `uvm_field_enum(trans_kind_e, trans_kind, UVM_ALL_ON)
        
        // Delays printed in Decimal for readability
        `uvm_field_int(awready_delay, UVM_ALL_ON | UVM_DEC)
        `uvm_field_int(wready_delay,  UVM_ALL_ON | UVM_DEC)
        `uvm_field_int(bvalid_delay,  UVM_ALL_ON | UVM_DEC)
        `uvm_field_int(arready_delay, UVM_ALL_ON | UVM_DEC)
        `uvm_field_int(rvalid_delay,  UVM_ALL_ON | UVM_DEC)

        // Inputs (Hex default)
        `uvm_field_int(AWADDR, UVM_ALL_ON)
        `uvm_field_int(AWPROT, UVM_ALL_ON)
        `uvm_field_int(WDATA,  UVM_ALL_ON)
        `uvm_field_int(WSTRB,  UVM_ALL_ON)
        `uvm_field_int(ARADDR, UVM_ALL_ON)
        `uvm_field_int(ARPROT, UVM_ALL_ON)

        // Outputs (Hex default)
        `uvm_field_int(BRESP,  UVM_ALL_ON)
        `uvm_field_int(RDATA,  UVM_ALL_ON)
        `uvm_field_int(RRESP,  UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name = "slave_seq_item");
        super.new(name);
    endfunction
    
endclass