//----------------------------------------------------------------------
//File name   : wphy_tx_top_reg_hw_reset_test.sv
//Project     : Jupiter
//Author      : wufengyang
//Created     : fengyangwu@asrmicro.com
//Build time  : 2020-7-14
//----------------------------------------------------------------------

`ifndef WPHY_TX_TOP_REG_HW_RESET_TEST__SV
`define WPHY_TX_TOP_REG_HW_RESET_TEST__SV



class wphy_tx_top_reg_hw_reset_test extends uvm_test;


    `uvm_component_utils(wphy_tx_top_reg_hw_reset_test);

    wphy_tx_top_env                    env;
    wphy_tx_top_env_cfg                env_cfg;

    wphy_tx_top_vseqr                  vseqr;

    wphy_tx_top_init_regbus_seq        m_regbus_reset_sequence;
    uvm_reg_hw_reset_seq               reg_reset_seq;

    int     drain_time = 10; //drain time after all seq done/checking done


    extern function new(string name="wphy_tx_top_reg_hw_reset_test", uvm_component parent=null);

    extern virtual function void build_phase(uvm_phase phase);
    extern virtual function void connect_phase(uvm_phase phase);

    extern virtual function void start_of_simulation_phase(uvm_phase phase);
    extern virtual function void end_of_elaboration_phase(uvm_phase phase);
    extern virtual function void final_phase(uvm_phase phase);

    extern virtual task main_phase(uvm_phase phase); //to start vseq
    extern virtual task post_main_phase(uvm_phase phase); //to check traffic end
    extern virtual task shutdown_phase(uvm_phase phase); //to check dut status

    extern virtual task end_objection_check(uvm_phase phase);
    extern virtual task end_of_test_objection(uvm_phase phase); 
    extern virtual task end_of_test_check(uvm_phase phase); 
    extern virtual function void callback_set_reg(uvm_reg_block regmodel,
                                                  string          reg_name,
                                                  string          reg_set_name); 
    extern virtual function void callback_clr_reg(uvm_reg_block regmodel,
                                                  string          reg_name,
                                                  string          reg_set_name); 
    extern function void add_ral_callback(uvm_reg_block regmodel); 
    //extern function void set_axis_latency(uvm_axi_slv_default_cb cb); 
    //extern function void set_axis_latency_severe(uvm_axi_slv_default_cb cb); 
endclass : wphy_tx_top_reg_hw_reset_test

function wphy_tx_top_reg_hw_reset_test::new(string name="wphy_tx_top_reg_hw_reset_test", uvm_component parent=null);
    super.new(name, parent);
endfunction



function void wphy_tx_top_reg_hw_reset_test::build_phase(uvm_phase phase);
    super.build_phase(phase);

    env = wphy_tx_top_env::type_id::create("env",this);
    env_cfg = wphy_tx_top_env_cfg::type_id::create("env_cfg",this);
    uvm_config_db#(wphy_tx_top_env_cfg)::set(this, "env", "m_wphy_tx_top_env_cfg", env_cfg);
    assert(env_cfg.randomize()) else
        `uvm_fatal(get_type_name(), "env_cfg randomize failed")
     env_cfg.m_tx_path_top_env_cfg.mode_set(tx_path_top_env_cfg::MODE_TX_TOP);
     env_cfg.mode_set(wphy_tx_top_env_cfg::MODE_PHY_TOP);
    `uvm_info(get_type_name(), $sformatf("env_cfg org\n%s", env_cfg.sprint()), UVM_LOW)

    vseqr = wphy_tx_top_vseqr::type_id::create("vseqr", this);
    uvm_config_db#(wphy_tx_top_env_cfg)::set(this, "vseqr", "m_wphy_tx_top_env_cfg", env_cfg);
endfunction: build_phase

function void wphy_tx_top_reg_hw_reset_test::callback_set_reg(uvm_reg_block regmodel,
                                                 string        reg_name,
                                                 string        reg_set_name);
endfunction: callback_set_reg


function void wphy_tx_top_reg_hw_reset_test::callback_clr_reg(uvm_reg_block regmodel,
                                                 string        reg_name,
                                                 string        reg_set_name);
endfunction: callback_clr_reg

function void wphy_tx_top_reg_hw_reset_test::add_ral_callback(uvm_reg_block regmodel);
    //TODO: Add ral callback file include which auto-gen by regquery
    //eg : `include "wphy_tx_top_rf_callback.sv"
endfunction: add_ral_callback

function void wphy_tx_top_reg_hw_reset_test::connect_phase(uvm_phase phase);
    //vseqr connection
    if(env_cfg.m_reg_agent_en) begin
        vseqr.m_reg_cfg_seqr = env.m_reg_agent.seqr;
    end

    if(env_cfg.mac_tx_agent_en) begin
        vseqr.m_mac_tx_seqr = env.m_mac_tx_agent.sqr;
    end

endfunction : connect_phase

function void wphy_tx_top_reg_hw_reset_test::start_of_simulation_phase(uvm_phase phase);
    uvm_root    test_manager = uvm_root::get();   
    uvm_factory test_factory = uvm_factory::get();
    super.start_of_simulation_phase(phase);

    //test_manager.print_topology(uvm_default_tree_printer);
    test_factory.print();
endfunction: start_of_simulation_phase

function void wphy_tx_top_reg_hw_reset_test::end_of_elaboration_phase(uvm_phase phase);
    uvm_phase post_main_phase = phase.find_by_name("post_main", 0);
    post_main_phase.phase_done.set_drain_time(this, drain_time);
endfunction : end_of_elaboration_phase

task wphy_tx_top_reg_hw_reset_test::main_phase(uvm_phase phase);
    `uvm_info($sformatf("%s", get_full_name()), "===main_phase begin===", UVM_NONE);

    reg_reset_seq = uvm_reg_hw_reset_seq::type_id::create("reg_reset_seq");
    m_regbus_reset_sequence = wphy_tx_top_init_regbus_seq::type_id::create("m_regbus_reset_sequence");
	reg_reset_seq.set_response_queue_error_report_disabled(1);
    reg_reset_seq.model = env.m_wphy_reg_model;

	phase.raise_objection(this);
	super.main_phase(phase);
    m_regbus_reset_sequence.start(vseqr.m_reg_cfg_seqr);
	reg_reset_seq.start(vseqr.m_reg_cfg_seqr);
	phase.drop_objection(this);

    `uvm_info($sformatf("%s", get_full_name()), "===main_phase end=====", UVM_NONE);

endtask : main_phase

task wphy_tx_top_reg_hw_reset_test::post_main_phase(uvm_phase phase);
    end_of_test_objection(phase);
endtask : post_main_phase

task wphy_tx_top_reg_hw_reset_test::end_of_test_objection(uvm_phase phase);
    phase.raise_objection(this, "Start waiting activities end");
    // decide when to end main traffic 
    // according to info from drv/mon/model etc..
    // wait(env_cfg.dma_agent_cfg.drv_busy == 0 && env_cfg.dma_agent_cfg.mon_busy == 0)
    // wait(env_cfg.dma_agent_cfg.refmdl_busy == 0 )
    phase.drop_objection(this, "Finish waiting activities end");
endtask : end_of_test_objection

task wphy_tx_top_reg_hw_reset_test::end_of_test_check(uvm_phase phase);
    //wphy_tx_top_eot_check_seq check_seq;
    phase.raise_objection(this, "Start end_of_test check");
    //check_seq = wphy_tx_top_eot_check_seq::type_id::create("check_seq");
    //check_seq.start(vseqr);
    phase.drop_objection(this, "Finish end_of_test check");
endtask : end_of_test_check

task wphy_tx_top_reg_hw_reset_test::shutdown_phase(uvm_phase phase);
    end_of_test_check(phase);
endtask : shutdown_phase

task wphy_tx_top_reg_hw_reset_test::end_objection_check(uvm_phase phase);
    uvm_object     object[$];
    uvm_objection  objection;
    objection = phase.get_objection();
    objection.get_objectors(object);

    `uvm_info(get_type_name(), $sformatf("ENV total objections %0d not dropped", objection.get_objection_total(this)), UVM_NONE)
    foreach(object[i]) begin
        `uvm_info(get_type_name(), $sformatf("Component %s has %0d objectipn not dropped", object[i].get_full_name(), objection.get_objection_count(object[i])), UVM_NONE)
    end
endtask : end_objection_check


function void wphy_tx_top_reg_hw_reset_test::final_phase(uvm_phase phase);
    uvm_report_server m_report;
    super.final_phase(phase);
    m_report = uvm_report_server::get_server();
    if((m_report.get_severity_count(uvm_severity'(UVM_ERROR)) > 0) ||
       (m_report.get_severity_count(uvm_severity'(UVM_FATAL)) > 0)) begin
        `uvm_info("TEST", "\n++++++++++++++++++++Simulation Fail++++++++++++++++++++++++", UVM_NONE)    
    end
    else begin
        `uvm_info("TEST", "\n++++++++++++++++++++Simulation Pass++++++++++++++++++++++++", UVM_NONE)    
    end
endfunction : final_phase


`endif
