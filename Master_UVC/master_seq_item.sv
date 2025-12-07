typedef enum bit {WRITE, READ} trans_kind_e;

class master_seq_item #(parameter DATA_WIDTH = 32, parameter ADDR_WIDTH = 32) extends uvm_sequence_item;

    // CONTROL KNOBS (Meta-Data)
    rand trans_kind_e trans_kind;     
    // Delays for verifying handshakes!
    rand int addr_delay;  // Cycles to wait before driving Address Valid
    rand int data_delay;  // Cycles to wait before driving Data Valid

    // Write Channel
    rand bit [ADDR_WIDTH-1:0]   AWADDR;
    rand bit [2:0]              AWPROT;
    rand bit [DATA_WIDTH-1:0]   WDATA;
    rand bit [DATA_WIDTH/8-1:0] WSTRB;
    bit      [1:0]              BRESP;  // Response (Captured, not randomized)

    // Read Channel
    rand bit [ADDR_WIDTH-1:0]   ARADDR;
    rand bit [2:0]              ARPROT;
    bit      [DATA_WIDTH-1:0]   RDATA;  // Data (Captured)
    bit      [1:0]              RRESP;  // Response (Captured)


  // CONSTRAINTS (Basic and Default)  
    constraint c_axi_lite_rules {
        // AXI Lite addresses must be aligned to data width.
        if (DATA_WIDTH == 32) {
            soft AWADDR[1:0] == 2'b00;
            soft ARADDR[1:0] == 2'b00;
        }
        else if (DATA_WIDTH == 64) {
            soft AWADDR[2:0] == 3'b000;
            soft ARADDR[2:0] == 3'b000;
        }


        soft addr_delay inside {[0:5]};
        soft data_delay inside {[0:5]};

        // Default to all bytes valid)
        soft WSTRB == 4'b1111; 
    }

    // Solve order
    constraint c_order { solve trans_kind before AWADDR, ARADDR; }

    // UVM AUTOMATION

    `uvm_object_param_utils_begin(master_seq_item #(DATA_WIDTH, ADDR_WIDTH))
        `uvm_field_enum(trans_kind_e, trans_kind, UVM_ALL_ON)
        `uvm_field_int(addr_delay, UVM_ALL_ON | UVM_DEC)
        `uvm_field_int(data_delay, UVM_ALL_ON | UVM_DEC)
        
  	    `uvm_field_int(AWADDR, UVM_ALL_ON )
        `uvm_field_int(AWPROT, UVM_ALL_ON )
        `uvm_field_int(WDATA,  UVM_ALL_ON )
        `uvm_field_int(WSTRB,  UVM_ALL_ON )
        `uvm_field_int(BRESP,  UVM_ALL_ON)

        `uvm_field_int(ARADDR, UVM_ALL_ON )
        `uvm_field_int(ARPROT, UVM_ALL_ON )
        `uvm_field_int(RDATA,  UVM_ALL_ON )
        `uvm_field_int(RRESP,  UVM_ALL_ON )
        `uvm_object_utils_end

    function new(string name = "master_seq_item");
        super.new(name);
    endfunction
    
endclass