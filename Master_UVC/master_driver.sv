 class master_driver extends uvm_driver #(master_seq_item);

    // Virtual Interface Handle (The connection to the DUT)
    virtual axi4lite_intf vif; 

    `uvm_component_utils(master_driver) 
    master_seq_item expected_reads[$];
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction
    
    //  Build Phase: Get the Interface from Config DB
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        // Check if the interface was passed from the Top module
      if(!uvm_config_db#(virtual axi4lite_intf)::get(this, "", "axi", vif)) begin
            `uvm_fatal("NO_VIF", "Virtual interface not set for master_driver")
        end
    endfunction
    
    //  Run Phase: Reset -> Loop
    task run_phase(uvm_phase phase);
        // A. Reset Phase (Initialize signals)
        reset_signals();
       wait(vif.resetn == 1); // Wait for simulation to actually start!
       `uvm_info("DRV", "Reset Dropped, Starting Pipeling Threads", UVM_MEDIUM)
       fork
            drive_req_thread(); // Sends Addresses
            drive_rsp_thread(); // Receives Data
        join
    endtask
   
    
    // Dispatcher: Decide if it is Read or Write
    task send_to_dut(master_seq_item pkt);
        `uvm_info("Master_DRIVER", $sformatf("Packet is \n%s", pkt.sprint()), UVM_HIGH)
      if (pkt.trans_kind == WRITE) begin
            drive_write(pkt);
        end
        else begin
            drive_read(pkt);
        end
      
    endtask

   task drive_req_thread();
        forever begin
            master_seq_item pkt;
            // Get Request
            seq_item_port.get_next_item(pkt);

            if (pkt.trans_kind == READ) begin
                // --- Drive Address ---
              `uvm_info("Master_DRIVER", $sformatf("Packet is \n%s", pkt.sprint()), UVM_HIGH)
                repeat(pkt.addr_delay) @(posedge vif.clk);
                vif.ARADDR  <= pkt.ARADDR;
                vif.ARPROT  <= pkt.ARPROT;
                vif.ARVALID <= 1'b1;

                do @(posedge vif.clk); while(!vif.ARREADY);
                vif.ARVALID <= 1'b0;

                // --- Push to Queue & Finish Request ---
                expected_reads.push_back(pkt);
                seq_item_port.item_done(); // Allow Sequencer to send next Addr immediately!
            end
            else begin
                 // Write Logic 
                 send_to_dut(pkt); 
                 seq_item_port.item_done();
            end
        end
    endtask

    // --- The Responder (Receives Data) ---
    task drive_rsp_thread();
        forever begin
            master_seq_item pkt;

            // Wait for Valid Data on Bus
            do @(posedge vif.clk); while(!vif.RVALID);

            // Get the oldest matching request
            wait(expected_reads.size() > 0);
            pkt = expected_reads.pop_front();

            // Accept Data (Handshake)
            vif.RREADY <= 1;
            // Capture Data here if you want to verify it in driver
            pkt.RDATA = vif.RDATA; 
            @(posedge vif.clk);
            vif.RREADY <= 0;
        end
    endtask
    //  AXI WRITE LOGIC (Address + Data + Response)

    task drive_write(master_seq_item pkt);
        
        
        // --- A. Write Address Channel ---
        // Use the "addr_delay" knob from the item
        repeat(pkt.addr_delay) @(posedge vif.clk);

        //  Drive Signals
        vif.AWADDR  <= pkt.AWADDR;
        vif.AWPROT  <= pkt.AWPROT;
        vif.AWVALID <= 1'b1;

        // Wait for Handshake (VALID=1 and READY=1)
        do begin
            @(posedge vif.clk);
        end while(vif.AWREADY == 0);
        
        // Deassert Valid
        vif.AWVALID <= 1'b0;

        // --- B. Write Data Channel ---
        // Use the "data_delay" knob
        repeat(pkt.data_delay) @(posedge vif.clk);

        vif.WDATA   <= pkt.WDATA;
        vif.WSTRB   <= pkt.WSTRB;
        vif.WVALID  <= 1'b1;

        // Wait for Handshake
        do begin
            @(posedge vif.clk);
        end while(vif.WREADY == 0);

        vif.WVALID  <= 1'b0;

        // --- C. Write Response Channel ---
        vif.BREADY <= 1'b1; // Master is ready to accept response

        // Wait for Slave to send Valid Response
        do begin
            @(posedge vif.clk);
        end while(vif.BVALID == 0);

        // Capture the response back into the packet!
        pkt.BRESP = vif.BRESP; 
        
        vif.BREADY <= 1'b0;
    endtask

    // -----------------------------------------------------------
    //  AXI READ LOGIC (Address + Data)
    // -----------------------------------------------------------
    task drive_read(master_seq_item pkt);
        

        // --- Read Address Channel ---
        repeat(pkt.addr_delay) @(posedge vif.clk);

        vif.ARADDR  <= pkt.ARADDR;
        vif.ARPROT  <= pkt.ARPROT;
        vif.ARVALID <= 1'b1;

        // Wait for Handshake
        do begin
            @(posedge vif.clk);
        end while(vif.ARREADY == 0);

        vif.ARVALID <= 1'b0;

        // -Read Data Channel ---
        vif.RREADY <= 1'b1; // Master is ready to receive data

        // Wait for Slave to send Valid Data
        do begin
            @(posedge vif.clk);
        end while(vif.RVALID == 0);

        // Capture Data and Response back into the packet
        pkt.RDATA = vif.RDATA;
        pkt.RRESP = vif.RRESP;

        vif.RREADY <= 1'b0;
    endtask

    // Initialize signals to 0 to avoid X-propagation 
    task reset_signals();
        wait(vif.resetn === 0);
        vif.AWVALID <= 0;
        vif.WVALID  <= 0;
        vif.BREADY  <= 0;
        vif.ARVALID <= 0;
        vif.RREADY  <= 0;
        // Don't need to drive Addr/Data to 0, but good practice
        vif.AWADDR <= 0;
        vif.WDATA  <= 0;
    endtask

endclass