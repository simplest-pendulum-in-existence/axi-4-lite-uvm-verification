class master_sequencer extends uvm_sequencer #(master_seq_item);
    
    // Component utility macro
    `uvm_component_utils(master_sequencer)
    
    // Component constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

endclass
