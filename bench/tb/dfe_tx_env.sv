// =========================================================================== //
// Author       : fengyangwu - ASR
// Last modified: 2020-07-09 19:00
// Filename     : dfe_tx_env.sv
// Description  : 
// =========================================================================== //
`ifndef DFE_TX_ENV_SV
`define DFE_TX_ENV_SV


class dfe_tx_env extends uvm_env;
    virtual dfe_tx_top_intf        dfe_tx_top_vif;

    //env_cfg
    dfe_tx_env_cfg               m_dfe_tx_env_cfg;

    //cov
    dfe_tx_coverage              m_dfe_tx_coverage;

    //drv
    dfe_tx_driver                m_dfe_tx_driver;

    //mon
    dfe_tx_monitor               m_dfe_tx_monitor;

    //mon transformer
    dfe_tx_scb_transformer       transformer;

    //scoreboard
    dfe_tx_scb                   m_dfe_tx_scb;

    //ref model
    dfe_tx_ref_model             m_dfe_tx_ref_model;


    `uvm_component_utils_begin(dfe_tx_env)
        `uvm_field_object(m_dfe_tx_env_cfg, UVM_DEFAULT)
    `uvm_component_utils_end    
    // function and task

    function new(string name = "dfe_tx_env", uvm_component parent);
        super.new(name,parent);
    endfunction

    extern virtual function void build_phase(uvm_phase phase);
    extern virtual function void connect_phase(uvm_phase phase);
    extern virtual function void end_of_elaboration_phase(uvm_phase phase);
endclass

function void dfe_tx_env::build_phase(uvm_phase phase); // {{{
    super.build_phase(phase);

    `uvm_info($sformatf("%25s", get_name()), $sformatf("build_phase begin"), UVM_LOW)

    if(!uvm_config_db#(virtual dfe_tx_top_intf)::get(this, "", "vif", dfe_tx_top_vif)) begin
        `uvm_fatal("NOCFG", $sformatf("[%s] Cannot get dfe_tx_top_vif", get_full_name()))
    end      


    if(!uvm_config_db#(dfe_tx_env_cfg)::get(this, "", "m_dfe_tx_env_cfg", m_dfe_tx_env_cfg)) begin
        `uvm_fatal("IP.dfe_tx", $sformatf("[%s] Cannot get dfe_tx_env_cfg", get_full_name()))
    end      

    uvm_config_db#(dfe_tx_env_cfg)::set(this, "*", "m_dfe_tx_env_cfg", m_dfe_tx_env_cfg);
    uvm_config_db#(virtual dfe_tx_top_intf)::set(this, "*", "vif", dfe_tx_top_vif);

    //build coverage
    m_dfe_tx_coverage = new("m_dfe_tx_coverage");
    uvm_config_db#(dfe_tx_coverage)::set(this,     "*",     "m_dfe_tx_coverage", m_dfe_tx_coverage);

    //build drv
    if(m_dfe_tx_env_cfg.is_active == UVM_ACTIVE) begin
        m_dfe_tx_driver = dfe_tx_driver::type_id::create("m_dfe_tx_driver", this);
    end
    
    //build mon
    if(m_dfe_tx_env_cfg.dfe_tx_mon_en) begin
        m_dfe_tx_monitor = dfe_tx_monitor::type_id::create("m_dfe_tx_monitor",this);
    end

    if(m_dfe_tx_env_cfg.transformer_enable)begin
        transformer = dfe_tx_scb_transformer::type_id::create("transformer", this);
    end

    if(m_dfe_tx_env_cfg.scb_en) begin
        int unsigned stream_id[$];
        string name[$];

        m_dfe_tx_scb = dfe_tx_scb::type_id::create("m_dfe_tx_scb", this);
        m_dfe_tx_scb.set_scb_property(dfe_tx_scb::BI_DIR, dfe_tx_scb::IN_ORDER, dfe_tx_scb::EXACT_CHK);

        traverse_stream_name(stream_id, name);
        foreach(stream_id[ii]) begin
            m_dfe_tx_scb.set_stream_name(stream_id[ii], name[ii]);
        end
    end

    //build ref_model
    if(m_dfe_tx_env_cfg.ref_model_en) begin
        m_dfe_tx_ref_model = dfe_tx_ref_model::type_id::create("m_dfe_tx_ref_model", this);
    end
    dfe_tx_top_vif.is_active = m_dfe_tx_env_cfg.is_active;
    dfe_tx_top_vif.cfg_toggle = ~dfe_tx_top_vif.cfg_toggle;
    `uvm_info($sformatf("%25s", get_name()), $sformatf("build_phase end"), UVM_LOW)
endfunction : build_phase // }}}

function void dfe_tx_env::connect_phase(uvm_phase phase); // {{{
    super.connect_phase(phase);

    if(m_dfe_tx_env_cfg.transformer_enable)begin
        m_dfe_tx_monitor.mon_port.connect(transformer.transform_export);
    end

    //connect with scb
    if(m_dfe_tx_env_cfg.scb_en && m_dfe_tx_env_cfg.scb_conn_en) begin

        if(m_dfe_tx_env_cfg.dfe_tx_mon_en) begin
            m_dfe_tx_monitor.mon_port.connect(m_dfe_tx_scb.insert_export);
        end

        if(m_dfe_tx_env_cfg.ref_model_en) begin
            m_dfe_tx_ref_model.exp_ap.connect(m_dfe_tx_scb.expect_export);
        end
    end

    //connect with ref model
    //if(m_dfe_tx_env_cfg.ref_model_en && m_dfe_tx_env_cfg.ref_model_conn_en) begin
        //eg: if(m_dfe_tx_env_cfg.dfe_tx_in_agent_en) begin
        //        m_dfe_tx_in_agent.mon.mon_port.connect(m_dfe_tx_ref_model.mac_in_fifo.analysis_export);
        //    end
    //end
endfunction : connect_phase // }}}

function void dfe_tx_env::end_of_elaboration_phase(uvm_phase phase); // {{{
    super.end_of_elaboration_phase(phase);

endfunction : end_of_elaboration_phase //}}}

`endif
