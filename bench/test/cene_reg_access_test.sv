class my_reg_single_access_seq extends uvm_reg_sequence #(uvm_sequence #(uvm_reg_item));

   // Variable: rg
   // The register to be tested
   uvm_reg rg;

   `uvm_object_utils(my_reg_single_access_seq)

   function new(string name="my_reg_single_access_seq");
     super.new(name);
   endfunction

   virtual task body();
      uvm_reg_map maps[$];
`ifdef UVM_REG_FIELD_LEVEL_ATTRIBUTE
        uvm_check_e fields_to_suppress[uvm_reg_field];
`endif

      `uvm_info(get_type_name(),"body debug\n",UVM_LOW);

      if (rg == null) begin
         `uvm_error("my_reg_access_seq", "No register specified to run sequence on")
         return;
      end

      // Registers with some attributes are not to be tested
      if (uvm_resource_db#(bit)::get_by_name({"REG::",rg.get_full_name()},
                                             "NO_REG_TESTS", 0) != null || 
          uvm_resource_db#(bit)::get_by_name({"REG::",rg.get_full_name()},
                                             "NO_REG_ACCESS_TEST", 0) != null )
            return;

      // Can only deal with registers with backdoor access
      if (rg.get_backdoor() == null && !rg.has_hdl_path()) begin
         `uvm_error("my_reg_access_seq", {"Register '",rg.get_full_name(),
         "' does not have a backdoor mechanism available"})
         return;
      end

      // Registers may be accessible from multiple physical interfaces (maps)
      rg.get_maps(maps);

      // Cannot test access if register contains RO or OTHER fields
      begin
         uvm_reg_field fields[$];

         rg.get_fields(fields);
         foreach (fields[j]) begin
            foreach (maps[k]) begin
               if (fields[j].get_access(maps[k]) == "RO") begin
                  //`uvm_warning("my_reg_access_seq", {"Register '",
                  //             rg.get_full_name(),"' has RO fields"})
                  return;
               end
               if (!fields[j].is_known_access(maps[k])) begin
                  //`uvm_warning("my_reg_access_seq", {"Register '",rg.get_full_name(),
                  //  "' has field with unknown access type '",
                  //  fields[j].get_access(maps[k]),"'"})
                  return;
               end
            end
         end
`ifdef UVM_REG_FIELD_LEVEL_ATTRIBUTE
          // Need to iterate over fields to mark fields for not comparing
          foreach (fields[k]) begin
              if (uvm_resource_db#(bit)::get_by_name({"REG::",fields[k].get_full_name()},
                                               {fields[k].get_full_name(), "_NO_REG_TESTS"}, 0) != null ||
                     uvm_resource_db#(bit)::get_by_name({"REG::",fields[k].get_full_name()},
                                               { fields[k].get_full_name(), "_NO_REG_ACCESS_TEST"}, 0) != null ) begin
                  fields_to_suppress[fields[k]] = fields[k].get_compare();
                  fields[k].set_compare(UVM_NO_CHECK);
              end
          end
`endif
      end
      
      // Access each register:
      // - Write complement of reset value via front door
      // - Read value via backdoor and compare against mirror
      // - Write reset value via backdoor
      // - Read via front door and compare against mirror
      foreach (maps[j]) begin
         uvm_status_e status;
         uvm_reg_data_t  v, exp;
         
         `uvm_info("my_reg_access_seq", {"Verifying access of register '",
             rg.get_full_name(),"' in map '", maps[j].get_full_name(),
             "' ..."}, UVM_LOW)
         
         v = rg.get();
         
         rg.write(status, ~v, UVM_FRONTDOOR, maps[j], this);

         if (status != UVM_IS_OK) begin
            `uvm_error("my_reg_access_seq", {"Status was '",status.name(),
                                 "' when writing '",rg.get_full_name(),
                                 "' through map '",maps[j].get_full_name(),"'"})
         end
         #1;
         
         //rg.mirror(status, UVM_CHECK, UVM_BACKDOOR, uvm_reg_map::backdoor(), this);
         rg.mirror(status, UVM_CHECK, UVM_FRONTDOOR, maps[j], this);
         if (status != UVM_IS_OK) begin
            `uvm_error("my_reg_access_seq", {"Status was '",status.name(),
                                 "' when reading reset value of register '",
                                 rg.get_full_name(), "' through frontdoor"})
         end
         
         rg.write(status, v, UVM_FRONTDOOR, maps[j], this);
         if (status != UVM_IS_OK) begin
            `uvm_error("my_reg_access_seq", {"Status was '",status.name(),
                                 "' when writing '",rg.get_full_name(),
                                 "' through frontdoor"})
         end
         
         rg.mirror(status, UVM_CHECK, UVM_FRONTDOOR, maps[j], this);
         if (status != UVM_IS_OK) begin
            `uvm_error("my_reg_access_seq", {"Status was '",status.name(),
                                 "' when reading reset value of register '",
                                 rg.get_full_name(), "' through map '",
                                 maps[j].get_full_name(),"'"})
         end
      end
`ifdef UVM_REG_FIELD_LEVEL_ATTRIBUTE
          //Reverting to old compare policy for suppressed fields
          foreach (fields_to_suppress[k]) begin
              k.set_compare(fields_to_suppress[k]);
          end

          fields_to_suppress.delete();
    
`endif
   endtask: body
endclass: my_reg_single_access_seq


//------------------------------------------------------------------------------
//
// Class: my_reg_access_seq
//
// Verify the accessibility of all registers in a block
// by executing the <my_reg_single_access_seq> sequence on
// every register within it.
//
// If bit-type resource named
// "NO_REG_TESTS" or "NO_REG_ACCESS_TEST"
// in the "REG::" namespace
// matches the full name of the block,
// the block is not tested.
//
//| uvm_resource_db#(bit)::set({"REG::",regmodel.blk.get_full_name(),".*"},
//|                            "NO_REG_TESTS", 1, this);
//
//------------------------------------------------------------------------------

class my_reg_access_seq extends uvm_reg_sequence #(uvm_sequence #(uvm_reg_item));

   // Variable: model
   //
   // The block to be tested. Declared in the base class.
   //
   //| uvm_reg_block model; 


   // Variable: reg_seq
   //
   // The sequence used to test one register
   //
   protected my_reg_single_access_seq reg_seq;
   
   `uvm_object_utils(my_reg_access_seq)

   function new(string name="my_reg_access_seq");
     super.new(name);
   endfunction


   // Task: body
   //
   // Executes the Register Access sequence.
   // Do not call directly. Use seq.start() instead.
   //
   virtual task body();

      if (model == null) begin
         `uvm_error("my_reg_access_seq", "No register model specified to run sequence on")
         return;
      end

      uvm_report_info("STARTING_SEQ",{"\n\nStarting ",get_name()," sequence...\n"},UVM_LOW);
      
      reg_seq = my_reg_single_access_seq::type_id::create("single_reg_access_seq");

      this.reset_blk(model);
      model.reset();

      do_block(model);
   endtask: body


   // Task: do_block
   //
   // Test all of the registers in a block
   //
   protected virtual task do_block(uvm_reg_block blk);
      uvm_reg regs[$];
      
      if (uvm_resource_db#(bit)::get_by_name({"REG::",blk.get_full_name()},
                                             "NO_REG_TESTS", 0) != null ||
          uvm_resource_db#(bit)::get_by_name({"REG::",blk.get_full_name()},
                                             "NO_REG_ACCESS_TEST", 0) != null )
         return;

      // Iterate over all registers, checking accesses
      blk.get_registers(regs, UVM_NO_HIER);
      foreach (regs[i]) begin
         // Registers with some attributes are not to be tested
         if (uvm_resource_db#(bit)::get_by_name({"REG::",regs[i].get_full_name()},
                                                "NO_REG_TESTS", 0) != null ||
	     uvm_resource_db#(bit)::get_by_name({"REG::",regs[i].get_full_name()},
                                                "NO_REG_ACCESS_TEST", 0) != null )
              continue;
         
         // Can only deal with registers with backdoor access
         if (regs[i].get_backdoor() == null && !regs[i].has_hdl_path()) begin
            `uvm_warning("my_reg_access_seq", {"Register '",regs[i].get_full_name(),
                   "' does not have a backdoor mechanism available"})
            continue;
         end
         
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

endclass: my_reg_access_seq


class cene_reg_access_test extends cene_base_test;

    my_reg_access_seq  reg_access_seq;

	`uvm_component_utils(cene_reg_access_test)
	
	function new(string name = "cene_reg_access_test",uvm_component parent);
		super.new(name,parent); 
	endfunction : new
    
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
    endfunction : build_phase

	virtual task main_phase(uvm_phase phase);
	    reg_access_seq = my_reg_access_seq::type_id::create("reg_access_seq");
		//reg_access_seq.set_response_queue_error_report_disabled(1);
        //reg_access_seq.reg_seq.set_response_queue_error_report_disabled(1);
        reg_access_seq.model = m_riu_apb_regmodel;

		phase.raise_objection(this);
	    super.main_phase(phase);
		reg_access_seq.start(env.vsqr.m_riu_apb_seqr);
		phase.drop_objection(this);
	endtask

endclass : cene_reg_access_test
