class slave_driver extends uvm_driver #(slave_seq_item);

    // Virtual Interface Handle
    virtual axi4lite_intf vif; 
  	bit [31:0] internal_mem [int];

    `uvm_component_utils(slave_driver) 
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction
    
    // Build Phase
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        // Using "axi" key to match your Master Driver setup
        if(!uvm_config_db#(virtual axi4lite_intf)::get(this, "", "axi", vif)) begin
            `uvm_fatal("NO_VIF", "Virtual interface not set for slave_driver")
        end
    endfunction
    
    // Run Phase
    task run_phase(uvm_phase phase);
        //  Reset Phase
        reset_signals();
        wait(vif.resetn == 1);
        `uvm_info("SLV_DRV", "Reset Dropped", UVM_MEDIUM)

        // Main Reactive Loop
        forever begin
            slave_seq_item pkt;
            
            //  Get the "Rules" (Delays/Responses) from the Sequencer
            seq_item_port.get_next_item(pkt); 
          `uvm_info("SLAVE_DRIVER", $sformatf("Slave Driver Packet:\n%s", pkt.sprint()), UVM_HIGH)
            //  React to the Bus
            respond_to_master(pkt);
            
            // 3. Done
            seq_item_port.item_done(); 
        end
    endtask
    
    // Dispatcher
    // Dispatcher
    task respond_to_master(slave_seq_item pkt);
        
        // 1. Wait for ANY request from the Master
        // We sit here until the Master asserts AWVALID (Write) or ARVALID (Read)
        wait(vif.AWVALID == 1 || vif.ARVALID == 1);

        // 2. Decide based on the BUS signals, not the randomized packet
        if (vif.AWVALID == 1) begin
            // Master wants to Write
            pkt.trans_kind = WRITE; // Force packet to match reality
            respond_write(pkt);
        end
        else if (vif.ARVALID == 1) begin
            // Master wants to Read
            pkt.trans_kind = READ;  // Force packet to match reality
            respond_read(pkt);
        end
        
    endtask


    //  AXI WRITE RESPONSE LOGIC

    task respond_write(slave_seq_item pkt);
        
        // --- A. Write Address Channel (Slave accepts Address) ---
        // Wait for Master to send Valid Address
        while(vif.AWVALID === 0) @(posedge vif.clk);

        // Insert Randomized Delay (Simulate Busy Slave)
        repeat(pkt.awready_delay) @(posedge vif.clk);

        // Assert Ready
        vif.AWREADY <= 1'b1;

        // Handshake (Capture Address)
        @(posedge vif.clk); // Transaction happens here
        pkt.AWADDR = vif.AWADDR; // Capture input for debug
        pkt.AWPROT = vif.AWPROT;
        
        vif.AWREADY <= 1'b0;

        // Write Data Channel (Slave accepts Data) ---
        // 1. Wait for Master to send Valid Data
        while(vif.WVALID === 0) @(posedge vif.clk);

        // Insert Randomized Delay
        repeat(pkt.wready_delay) @(posedge vif.clk);

        // Assert Ready
        vif.WREADY <= 1'b1;

        // 4. Handshake (Capture Data)
        @(posedge vif.clk);
        pkt.WDATA = vif.WDATA; // Capture data for storage/debug
        pkt.WSTRB = vif.WSTRB;
        
        vif.WREADY <= 1'b0;
      
        internal_mem[pkt.AWADDR] = pkt.WDATA;
		`uvm_info("SLV_MEM", $sformatf("Stored: Addr=0x%0h Data=0x%0h", pkt.AWADDR, pkt.WDATA), UVM_HIGH)
      
        // --- Write Response Channel (Slave sends Status) ---
        // Insert Randomized Output Latency
        repeat(pkt.bvalid_delay) @(posedge vif.clk);

        //  Drive Response (From Randomized Packet)
        vif.BRESP  <= pkt.BRESP; 
        vif.BVALID <= 1'b1;

        // Wait for Master to accept (BREADY)
        do begin
            @(posedge vif.clk);
        end while(vif.BREADY == 0);

        vif.BVALID <= 1'b0;
    endtask

    // -----------------------------------------------------------
    //  AXI READ RESPONSE LOGIC
    // -----------------------------------------------------------
    task respond_read(slave_seq_item pkt);

        // --- A. Read Address Channel (Slave accepts Address) ---
        while(vif.ARVALID === 0) @(posedge vif.clk);

        repeat(pkt.arready_delay) @(posedge vif.clk);

        vif.ARREADY <= 1'b1;

        @(posedge vif.clk);
        pkt.ARADDR = vif.ARADDR; // Capture Address
        
        vif.ARREADY <= 1'b0;
         if (internal_mem.exists(pkt.ARADDR)) begin
    		pkt.RDATA = internal_mem[pkt.ARADDR]; // Overwrite randomized data with memory data
		end else begin
    		pkt.RDATA = 32'hDEADBEEF; // Default value for empty addresses
		end
		`uvm_info("SLV_MEM", $sformatf("Read: Addr=0x%0h Data=0x%0h", pkt.ARADDR, pkt.RDATA), UVM_HIGH)

        // --- B. Read Data Channel (Slave sends Data) ---
        //Insert Randomized Output Latency
        repeat(pkt.rvalid_delay) @(posedge vif.clk);

        // 2. Drive Data & Response (From Randomized Packet)
        vif.RDATA  <= pkt.RDATA;
        vif.RRESP  <= pkt.RRESP;
        vif.RVALID <= 1'b1;

        // Wait for Master to accept (RREADY)
        do begin
            @(posedge vif.clk);
        end while(vif.RREADY == 0);

        vif.RVALID <= 1'b0;
    endtask

    // Initialize signals
    task reset_signals();
        wait(vif.resetn === 0);
        vif.AWREADY <= 0;
        vif.WREADY  <= 0;
        vif.BVALID  <= 0;
        vif.ARREADY <= 0;
        vif.RVALID  <= 0;
        vif.BRESP   <= 0;
        vif.RDATA   <= 0;
        vif.RRESP   <= 0;
    endtask

endclass