class my_reg_bit_bash_seq extends uvm_reg_sequence #(uvm_sequence #(uvm_reg_item));

   // Variable: model
   //
   // The block to be tested. Declared in the base class.
   //
   //| uvm_reg_block model; 


   // Variable: reg_seq
   //
   // The sequence used to test one register
   //
   uvm_reg_single_bit_bash_seq reg_seq;
   
   `uvm_object_utils(my_reg_bit_bash_seq)

   function new(string name="my_reg_bit_bash_seq");
     super.new(name);
     reg_seq = uvm_reg_single_bit_bash_seq::type_id::create("reg_single_bit_bash_seq");
   endfunction


   // Task: body
   //
   // Executes the Register Bit Bash sequence.
   // Do not call directly. Use seq.start() instead.
   //
   virtual task body();
      
      if (model == null) begin
         `uvm_error("my_reg_bit_bash_seq", "No register model specified to run sequence on");
         return;
      end

      uvm_report_info("STARTING_SEQ",{"\n\nStarting ",get_name()," sequence...\n"},UVM_LOW);


      this.reset_blk(model);
      model.reset();

      do_block(model);
   endtask


   // Task: do_block
   //
   // Test all of the registers in a a given ~block~
   //
   protected virtual task do_block(uvm_reg_block blk);
      uvm_reg regs[$];

      if (uvm_resource_db#(bit)::get_by_name({"REG::",blk.get_full_name()},
                                             "NO_REG_TESTS", 0) != null ||
          uvm_resource_db#(bit)::get_by_name({"REG::",blk.get_full_name()},
                                             "NO_REG_BIT_BASH_TEST", 0) != null )
         return;

      // Iterate over all registers, checking accesses
      blk.get_registers(regs, UVM_NO_HIER);
      foreach (regs[i]) begin
         // Registers with some attributes are not to be tested
         if (uvm_resource_db#(bit)::get_by_name({"REG::",regs[i].get_full_name()},
                                                "NO_REG_TESTS", 0) != null ||
	     uvm_resource_db#(bit)::get_by_name({"REG::",regs[i].get_full_name()},
                                                "NO_REG_BIT_BASH_TEST", 0) != null )
            continue;
         
         reg_seq.rg = regs[i];
         reg_seq.start(null,this);
      end

      begin
         uvm_reg_block blks[$];
         
         blk.get_blocks(blks);
         foreach (blks[i]) begin
            do_block(blks[i]);
         end
      end
   endtask: do_block


   // Task: reset_blk
   //
   // Reset the DUT that corresponds to the specified block abstraction class.
   //
   // Currently empty.
   // Will rollback the environment's phase to the ~reset~
   // phase once the new phasing is available.
   //
   // In the meantime, the DUT should be reset before executing this
   // test sequence or this method should be implemented
   // in an extension to reset the DUT.
   //
   virtual task reset_blk(uvm_reg_block blk);
   endtask

endclass: my_reg_bit_bash_seq



class cene_reg_bit_bash_test extends cene_base_test;

    my_reg_bit_bash_seq  reg_bit_bash_seq;

	`uvm_component_utils(cene_reg_bit_bash_test)
	
	function new(string name = "cene_reg_bit_bash_test",uvm_component parent);
		super.new(name,parent); 
	endfunction : new
    
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
    endfunction : build_phase


	virtual task main_phase(uvm_phase phase);
	    reg_bit_bash_seq = my_reg_bit_bash_seq::type_id::create("reg_bit_bash_seq");
        //reg_bit_bash_seq.set_response_queue_depth(-1);
        reg_bit_bash_seq.set_response_queue_error_report_disabled(1);
        reg_bit_bash_seq.reg_seq.set_response_queue_error_report_disabled(1);
        reg_bit_bash_seq.model = m_riu_apb_regmodel;

		phase.raise_objection(this);
	    super.main_phase(phase);
		reg_bit_bash_seq.start(env.vsqr.m_riu_apb_seqr);
		phase.drop_objection(this);
	endtask

endclass : cene_reg_bit_bash_test
