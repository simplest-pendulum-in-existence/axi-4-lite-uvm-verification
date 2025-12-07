class master_monitor extends uvm_monitor;

    virtual axi4lite_intf vif;

    //Analysis Port (Broadcaster)
    uvm_analysis_port #(master_seq_item) monitor_port;

    `uvm_component_utils(master_monitor)
    master_seq_item pending_reads[$];

    function new(string name, uvm_component parent);
        super.new(name, parent);
        monitor_port = new("monitor_port", this);
    endfunction

    // Build Phase
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if(!uvm_config_db#(virtual axi4lite_intf)::get(this, "", "axi", vif)) begin
            `uvm_fatal("NO_VIF", "Virtual interface not set for master_monitor")
        end
    endfunction

    // Run Phase
    task run_phase(uvm_phase phase);
        `uvm_info("MON", "Master Monitor Started", UVM_LOW)
        
        // Wait for Reset (Using your name 'resetn')
        wait(vif.resetn == 1);

        // Run independent threads for Read and Write channels
        fork
            monitor_write_channel();
            monitor_read_channel();
        join
    endtask

    //   Monitor Write Transactions

    task monitor_write_channel();
        forever begin
            master_seq_item pkt = master_seq_item::type_id::create("captured_write_pkt");
            pkt.trans_kind = WRITE;

            // Capture Write Address
            // Using your name 'clk'
            do begin
                @(posedge vif.clk);
            end while (!(vif.AWVALID && vif.AWREADY));
            
            pkt.AWADDR = vif.AWADDR;
            pkt.AWPROT = vif.AWPROT;

            // Capture Write Data
            do begin
                @(posedge vif.clk);
            end while (!(vif.WVALID && vif.WREADY));

            pkt.WDATA = vif.WDATA;
            pkt.WSTRB = vif.WSTRB;

            // Capture Write Response
            do begin
                @(posedge vif.clk);
            end while (!(vif.BVALID && vif.BREADY));

            pkt.BRESP = vif.BRESP;
          
            `uvm_info("MON_PKT", $sformatf("Master Monitor Captured Packet:\n%s", pkt.sprint()), UVM_MEDIUM)
            //Publish
            monitor_port.write(pkt);
        end
    endtask
  
  task monitor_read_channel();
        fork
            collect_read_addr(); // Thread A: Pushes to Queue
            collect_read_data(); // Thread B: Pops from Queue
        join
    endtask

    // --- Thread A: Address Collector ---
    task collect_read_addr();
        forever begin
            master_seq_item pkt = master_seq_item::type_id::create("pkt");
            pkt.trans_kind = READ;

            // 1. Capture Address Handshake
            do @(posedge vif.clk); while (!(vif.ARVALID && vif.ARREADY));
            pkt.ARADDR = vif.ARADDR;
            pkt.ARPROT = vif.ARPROT;

            // 2. PUSH to Queue (Back of line)
            pending_reads.push_back(pkt);
        end
    endtask

    // --- Thread B: Data Collector ---
    task collect_read_data();
        forever begin
            master_seq_item pkt;

            // 1. Wait for Data Handshake
            do @(posedge vif.clk); while (!(vif.RVALID && vif.RREADY));

            // 2. POP from Queue (Front of line - FIFO Order)
            // AXI-Lite is ordered, so the first Data always matches the first Address
            wait(pending_reads.size() > 0);
            pkt = pending_reads.pop_front();

            // 3. Capture Data
            pkt.RDATA = vif.RDATA;
            pkt.RRESP = vif.RRESP;

            `uvm_info("MON_PKT", $sformatf("Master Monitor Captured Packet:\n%s", pkt.sprint()), UVM_MEDIUM)
            // 4. Publish
            monitor_port.write(pkt);
        end
    endtask

    virtual function void start_of_simulation_phase(uvm_phase phase);
       `uvm_info("MON", "Start of simulation phase in Monitor", UVM_HIGH)
    endfunction

endclass