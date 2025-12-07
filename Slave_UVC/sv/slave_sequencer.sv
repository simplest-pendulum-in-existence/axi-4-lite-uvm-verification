class slave_sequencer extends uvm_sequencer #(slave_seq_item);
    
    // Component utility macro
    `uvm_component_utils(slave_sequencer)
    
    // Component constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

endclass
