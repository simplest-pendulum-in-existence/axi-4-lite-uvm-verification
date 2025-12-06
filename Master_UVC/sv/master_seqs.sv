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

class basic_seq extends master_seqs;
  `uvm_object_utils(basic_seq)
  
  
  function new(string name="basic_seq");
    super.new(name);
  endfunction
  
  virtual task body();
    `uvm_info(get_type_name(), "Executing write_seq_packets sequence", UVM_LOW)
    repeat(5)
      `uvm_do(req)
  endtask
endclass
