// =========================================================================== //
// Author       : fengyang.wu - ASR
// Last modified: 2020-07-10 18:49
// Filename     : asr_src_fifo_monitor.sv
// Description  : 
// =========================================================================== //
`ifndef ASR_SRC_FIFO_MONITOR__SV
`define ASR_SRC_FIFO_MONITOR__SV

class asr_src_fifo_monitor extends uvm_monitor;
    virtual asr_src_fifo_intf vif;
    int num_col = 0;

    asr_src_fifo_agent_cfg   cfg;
    asr_src_fifo_coverage    cg;

    int bit_num;
    string cov_name;

    uvm_analysis_port #(asr_src_fifo_trans)  mon_port;

    `uvm_component_utils_begin(asr_src_fifo_monitor)
        `uvm_field_int(num_col, UVM_ALL_ON)
    `uvm_component_utils_end


    extern function new (string name, uvm_component parent);
    extern virtual function void build_phase(uvm_phase phase);
    extern virtual protected task collect_transfer(uvm_phase phase);
    extern virtual task run_phase(uvm_phase phase);
    extern virtual function void report_phase(uvm_phase phase);
endclass: asr_src_fifo_monitor

function asr_src_fifo_monitor::new (string name, uvm_component parent);
    super.new(name, parent);
    mon_port = new("mon_port", this);
endfunction : new

function void asr_src_fifo_monitor::build_phase(uvm_phase phase); //{{{
    super.build_phase(phase);
    if(!uvm_config_db#(virtual asr_src_fifo_intf)::get(this, "", "vif", vif)) begin
       `uvm_fatal(get_full_name(), $psprintf("Can not get vif !"))
    end

    if(!uvm_config_db#(asr_src_fifo_agent_cfg)::get(this, "", "cfg", cfg)) begin
       `uvm_fatal(get_full_name(), $psprintf("Can not get cfg !"))
    end
    if(cfg.coverage_enable) begin
        cg = new($sformatf({get_full_name(), "_cg"}));   
    end
endfunction : build_phase //}}}


task asr_src_fifo_monitor::run_phase(uvm_phase phase); //{{{
    bit bit_stream[];
    asr_src_fifo_trans    mon_tr;

    mon_tr = asr_src_fifo_trans::type_id::create("mon_tr", this);
    void'(mon_tr.pack(bit_stream, default_packer));
    bit_num = bit_stream.size();

    forever begin
        collect_transfer(phase);
    end
endtask : run_phase //}}}

task asr_src_fifo_monitor::collect_transfer(uvm_phase phase); //{{{
    bit bit_stream[];
    asr_src_fifo_trans mon_tr;
    mon_tr = asr_src_fifo_trans::type_id::create("mon_tr", this);
    bit_stream = new[bit_num];
    @(vif.moncb iff vif.moncb.valid);
    `uvm_info(get_full_name(), $sformatf("\nReport: src fifo monitor valid signal"), UVM_MEDIUM)

    foreach(bit_stream[ii])begin
        bit_stream[ii] = vif.node[ii];
    end
    cfg.mon_busy = 1;

    //send mon_tr to scb_transformer or scoreboard
    void'(mon_tr.unpack(bit_stream, default_packer));
    //mon_tr.stream_id = cfg.stream_id;
    //mon_tr.ch_id = cfg.ch_id;
    mon_port.write(mon_tr);

    if(cfg.coverage_enable) begin
        cg.sample_tr(mon_tr);
        cg.sample_cfg(cfg);
    end

    num_col++;
    cfg.mon_busy = 0;

endtask : collect_transfer //}}}

function void asr_src_fifo_monitor::report_phase(uvm_phase phase); //{{{
    `uvm_info($sformatf("%25s", get_full_name()), $sformatf("\nReport: register database monitor collected %0d transfers", num_col), UVM_LOW)
endfunction : report_phase //}}}

`endif
