class slave_monitor extends uvm_monitor;

    // Virtual Interface Handle
    virtual axi4lite_intf vif;

    // Analysis Port (Broadcaster)
    // Broadcasting 'slave_seq_item' to the scoreboard
    uvm_analysis_port #(slave_seq_item) monitor_port;

    `uvm_component_utils(slave_monitor)

    function new(string name, uvm_component parent);
        super.new(name, parent);
        monitor_port = new("monitor_port", this);
    endfunction

    // Build Phase
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        // Using "axi" key to match your Top Module and Drivers
        if(!uvm_config_db#(virtual axi4lite_intf)::get(this, "", "axi", vif)) begin
            `uvm_fatal("NO_VIF", "Virtual interface not set for slave_monitor")
        end
    endfunction

    // Run Phase
    task run_phase(uvm_phase phase);
        `uvm_info("SLV_MON", "Slave Monitor Started", UVM_LOW)
        
        // Wait for Reset
        wait(vif.resetn == 1);

        // Run independent threads for Read and Write channels
        fork
            monitor_write_channel();
            monitor_read_channel();
        join
    endtask

    // -------------------------------------------------------
    //  Thread A: Monitor Write Transactions
    // -------------------------------------------------------
    task monitor_write_channel();
        forever begin
            slave_seq_item pkt = slave_seq_item::type_id::create("slave_captured_write");
            pkt.trans_kind = WRITE;

            // 1. Capture Write Address (Handshake)
            do begin
                @(posedge vif.clk);
            end while (!(vif.AWVALID && vif.AWREADY));
            
            pkt.AWADDR = vif.AWADDR;
            pkt.AWPROT = vif.AWPROT;

            // 2. Capture Write Data (Handshake)
            do begin
                @(posedge vif.clk);
            end while (!(vif.WVALID && vif.WREADY));

            pkt.WDATA = vif.WDATA;
            pkt.WSTRB = vif.WSTRB;

            // 3. Capture Write Response (Handshake)
            do begin
                @(posedge vif.clk);
            end while (!(vif.BVALID && vif.BREADY));

            pkt.BRESP = vif.BRESP;

            // Print and Publish
            `uvm_info("SLV_MON_PKT", $sformatf("Slave Monitor Captured Packet:\n%s", pkt.sprint()), UVM_MEDIUM)
            monitor_port.write(pkt);
        end
    endtask

    // -------------------------------------------------------
    //  Thread B: Monitor Read Transactions
    // -------------------------------------------------------
    task monitor_read_channel();
        forever begin
            slave_seq_item pkt = slave_seq_item::type_id::create("slave_captured_read");
            pkt.trans_kind = READ;

            // 1. Capture Read Address (Handshake)
            do begin
                @(posedge vif.clk);
            end while (!(vif.ARVALID && vif.ARREADY));

            pkt.ARADDR = vif.ARADDR;
            pkt.ARPROT = vif.ARPROT;

            // 2. Capture Read Data/Resp (Handshake)
            do begin
                @(posedge vif.clk);
            end while (!(vif.RVALID && vif.RREADY));

            pkt.RDATA = vif.RDATA;
            pkt.RRESP = vif.RRESP;

            // Print and Publish
            `uvm_info("SLV_MON_PKT", $sformatf("Slave Monitor Captured Packet:\n%s", pkt.sprint()), UVM_MEDIUM)
            monitor_port.write(pkt);
        end
    endtask

endclass