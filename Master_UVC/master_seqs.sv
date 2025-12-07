class master_seqs extends uvm_sequence #(master_seq_item );
  
  // Required macro for sequences automation
  `uvm_object_utils(master_seqs)

  // Constructor
  function new(string name="base_seq");
    super.new(name);
  endfunction

  task pre_body();
    uvm_phase phase;
    `ifdef UVM_VERSION_1_2
      // in UVM1.2, get starting phase from method
      phase = get_starting_phase();
    `else
      phase = starting_phase;
    `endif
    if (phase != null) begin
      phase.raise_objection(this, get_type_name());
      `uvm_info(get_type_name(), "raise objection", UVM_MEDIUM)
    end
  endtask : pre_body

  task post_body();
    uvm_phase phase;
    `ifdef UVM_VERSION_1_2
      // in UVM1.2, get starting phase from method
      phase = get_starting_phase();
    `else
      phase = starting_phase;
    `endif
    if (phase != null) begin
      phase.drop_objection(this, get_type_name());
      `uvm_info(get_type_name(), "drop objection", UVM_MEDIUM)
    end
  endtask : post_body


    virtual function void start_of_simulation_phase(uvm_phase phase);
        `uvm_info("Seqeuncer_START_SIM", "Start of simulation phase in yapp_sequencer", UVM_HIGH)
     endfunction

endclass : master_seqs

class m_basic_seq extends master_seqs;
  `uvm_object_utils(m_basic_seq)
  
  
  function new(string name="basic_seq");
    super.new(name);
  endfunction
  
  virtual task body();
    `uvm_info(get_type_name(), "Executing write_seq_packets sequence", UVM_LOW)
    repeat(5)
      `uvm_do(req)
  endtask
endclass
      
      
class master_simple_seq extends master_seqs;
    
    `uvm_object_utils(master_simple_seq)

    function new(string name="master_simple_seq");
        super.new(name);
    endfunction

    virtual task body();
        // WRITE (Addr=0x100, Data=0x12345678)
        `uvm_do_with(req, { 
            trans_kind == WRITE; 
            AWADDR     == 32'h100; 
            WDATA      == 32'h12345678; 
        })

        // READ (Addr=0x100)
        `uvm_do_with(req, { 
            trans_kind == READ; 
            ARADDR     == 32'h100; 
        })
        
    endtask

endclass   
    
    
 class master_pipeline_seq extends master_seqs;
    
    `uvm_object_utils(master_pipeline_seq)

    function new(string name="master_pipeline_seq");
        super.new(name);
    endfunction

    virtual task body();
        master_seq_item req;

        `uvm_info("PIPE_SEQ", "Starting Pipelined Traffic: W4 -> W5 -> R4 -> R5", UVM_LOW)

        `uvm_do_with(req, { 
            trans_kind == WRITE; 
            AWADDR     == 32'h4; 
            WDATA      == 32'hAA; 
            addr_delay == 0;  
            data_delay == 5;  
        })

        `uvm_do_with(req, { 
            trans_kind == WRITE; 
            AWADDR     == 32'h5; 
            WDATA      == 32'hBB; 
            addr_delay == 0;
            data_delay == 2;
        })

        `uvm_do_with(req, { 
            trans_kind == READ; 
            ARADDR     == 32'h4; 
            addr_delay == 0;
        })

        `uvm_do_with(req, { 
            trans_kind == READ; 
            ARADDR     == 32'h5; 
            addr_delay == 0;
        })
        
    endtask

endclass
