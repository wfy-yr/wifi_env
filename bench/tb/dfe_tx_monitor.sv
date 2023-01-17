// =========================================================================== //
// Author       : fengyang.wu - ASR
// Last modified: 2020-07-10 18:49
// Filename     : dfe_tx_monitor.sv
// Description  : 
// =========================================================================== //
`ifndef DFE_TX_MONITOR__SV
`define DFE_TX_MONITOR__SV

class dfe_tx_monitor extends uvm_monitor;
    virtual dfe_tx_top_intf vif;
    int dfe_tx_qout_ch0_num_col = 0;
    int dfe_tx_qout_ch1_num_col = 0;
    int cfr_din_ch0_num_col = 0;
    int cfr_din_ch1_num_col = 0;
    int cfr_qout_ch0_num_col = 0;
    int cfr_qout_ch1_num_col = 0;
    int nco4_din_ch0_num_col = 0;
    int nco4_din_ch1_num_col = 0;
    int dgain_qout_ch0_num_col = 0;
    int dgain_qout_ch1_num_col = 0;
    int dpd_qout_ch0_num_col = 0;
    int dpd_qout_ch1_num_col = 0;
    int iqcomp_qout_ch0_num_col = 0;
    int iqcomp_qout_ch1_num_col = 0;
    int up3fir3_qout_ch0_num_col = 0;
    int up3fir3_qout_ch1_num_col = 0;
    int up2fir2_qout_ch0_num_col = 0;
    int up2fir2_qout_ch1_num_col = 0;
    int iqloft_qout_ch0_num_col = 0;
    int iqloft_qout_ch1_num_col = 0;

    dfe_tx_env_cfg     cfg;
    dfe_tx_coverage    cg;

    wifi_tv_proc   tv_proc;

    uvm_analysis_port #(wifi_fifo_trans)    mon_port;
    uvm_analysis_port #(wifi_fifo_trans)    mon_port_base;

    `uvm_component_utils_begin(dfe_tx_monitor)
        `uvm_field_int(dfe_tx_qout_ch0_num_col, UVM_ALL_ON)
        `uvm_field_int(dfe_tx_qout_ch1_num_col, UVM_ALL_ON)
        `uvm_field_int(cfr_din_ch0_num_col, UVM_ALL_ON)
        `uvm_field_int(cfr_din_ch1_num_col, UVM_ALL_ON)
        `uvm_field_int(cfr_qout_ch0_num_col, UVM_ALL_ON)
        `uvm_field_int(cfr_qout_ch1_num_col, UVM_ALL_ON)
        `uvm_field_int(nco4_din_ch0_num_col, UVM_ALL_ON)
        `uvm_field_int(nco4_din_ch1_num_col, UVM_ALL_ON)
        `uvm_field_int(dgain_qout_ch0_num_col, UVM_ALL_ON)
        `uvm_field_int(dgain_qout_ch1_num_col, UVM_ALL_ON)
        `uvm_field_int(dpd_qout_ch0_num_col, UVM_ALL_ON)
        `uvm_field_int(dpd_qout_ch1_num_col, UVM_ALL_ON)
        `uvm_field_int(iqcomp_qout_ch0_num_col, UVM_ALL_ON)
        `uvm_field_int(iqcomp_qout_ch1_num_col, UVM_ALL_ON)
        `uvm_field_int(up3fir3_qout_ch0_num_col, UVM_ALL_ON)
        `uvm_field_int(up3fir3_qout_ch1_num_col, UVM_ALL_ON)
        `uvm_field_int(up2fir2_qout_ch0_num_col, UVM_ALL_ON)
        `uvm_field_int(up2fir2_qout_ch1_num_col, UVM_ALL_ON)
        `uvm_field_int(iqloft_qout_ch0_num_col, UVM_ALL_ON)
        `uvm_field_int(iqloft_qout_ch1_num_col, UVM_ALL_ON)
    `uvm_component_utils_end


    extern function new (string name, uvm_component parent);
    extern virtual function void build_phase(uvm_phase phase);
    extern virtual protected task collect_cfr_din_ch0_transfer(WIFI_SCB_STREAM_ID_T stream_id_t);
    extern virtual protected task collect_cfr_din_ch1_transfer(WIFI_SCB_STREAM_ID_T stream_id_t);
    extern virtual protected task collect_cfr_qout_ch0_transfer(WIFI_SCB_STREAM_ID_T stream_id_t);
    extern virtual protected task collect_cfr_qout_ch1_transfer(WIFI_SCB_STREAM_ID_T stream_id_t);
    extern virtual protected task collect_nco4_din_ch0_transfer(WIFI_SCB_STREAM_ID_T stream_id_t);
    extern virtual protected task collect_nco4_din_ch1_transfer(WIFI_SCB_STREAM_ID_T stream_id_t);
    extern virtual protected task collect_dgain_qout_ch0_transfer(WIFI_SCB_STREAM_ID_T stream_id_t);
    extern virtual protected task collect_dgain_qout_ch1_transfer(WIFI_SCB_STREAM_ID_T stream_id_t);
    extern virtual protected task collect_dpd_qout_ch0_transfer(WIFI_SCB_STREAM_ID_T stream_id_t);
    extern virtual protected task collect_dpd_qout_ch1_transfer(WIFI_SCB_STREAM_ID_T stream_id_t);
    extern virtual protected task collect_iqcomp_qout_ch0_transfer(WIFI_SCB_STREAM_ID_T stream_id_t);
    extern virtual protected task collect_iqcomp_qout_ch1_transfer(WIFI_SCB_STREAM_ID_T stream_id_t);
    extern virtual protected task collect_up3fir3_qout_ch0_transfer(WIFI_SCB_STREAM_ID_T stream_id_t);
    extern virtual protected task collect_up3fir3_qout_ch1_transfer(WIFI_SCB_STREAM_ID_T stream_id_t);
    extern virtual protected task collect_up2fir2_qout_ch0_transfer(WIFI_SCB_STREAM_ID_T stream_id_t);
    extern virtual protected task collect_up2fir2_qout_ch1_transfer(WIFI_SCB_STREAM_ID_T stream_id_t);
    extern virtual protected task collect_iqloft_qout_ch0_transfer(WIFI_SCB_STREAM_ID_T stream_id_t);
    extern virtual protected task collect_iqloft_qout_ch1_transfer(WIFI_SCB_STREAM_ID_T stream_id_t);
    extern virtual protected task collect_dfe_qout_ch0_transfer(WIFI_SCB_STREAM_ID_T stream_id_t);
    extern virtual protected task collect_dfe_qout_ch1_transfer(WIFI_SCB_STREAM_ID_T stream_id_t);

    extern virtual task run_phase(uvm_phase phase);
    extern virtual function void report_phase(uvm_phase phase);
endclass: dfe_tx_monitor

function dfe_tx_monitor::new (string name, uvm_component parent);
    super.new(name, parent);
    mon_port = new("mon_port", this);
    mon_port_base = new("mon_port_base", this);
    tv_proc = new();
endfunction : new

function void dfe_tx_monitor::build_phase(uvm_phase phase); //{{{
    super.build_phase(phase);
    if(!uvm_config_db#(virtual dfe_tx_top_intf)::get(this, "", "vif", vif)) begin
       `uvm_fatal(get_full_name(), $psprintf("Can not get vif !"))
    end

    if(!uvm_config_db#(dfe_tx_env_cfg)::get(this, "", "m_dfe_tx_env_cfg", cfg)) begin
       `uvm_fatal(get_full_name(), $psprintf("Can not get cfg !"))
    end
    if(cfg.coverage_enable) begin
        cg = new($sformatf({get_full_name(), "_cg"}));   
    end
endfunction : build_phase //}}}


task dfe_tx_monitor::run_phase(uvm_phase phase); //{{{
    wifi_tv_dir_trans dir_q[$];
    $system("rm DFE_TX_*.txt");
    tv_proc.set_default();
    tv_proc.parse_wifi_case_dir(dir_q,`CASE_NUM);
    fork
        forever begin
            collect_cfr_din_ch0_transfer(cfg.stream_id[0]);
        end
        forever begin
            collect_cfr_din_ch1_transfer(cfg.stream_id[1]);
        end
        forever begin
            collect_cfr_qout_ch0_transfer(cfg.stream_id[2]);
        end
        forever begin
            collect_cfr_qout_ch1_transfer(cfg.stream_id[3]);
        end
        forever begin
            collect_nco4_din_ch0_transfer(cfg.stream_id[4]);
        end
        forever begin
            collect_nco4_din_ch1_transfer(cfg.stream_id[5]);
        end
        forever begin
            collect_dgain_qout_ch0_transfer(cfg.stream_id[6]);
        end
        forever begin
            collect_dgain_qout_ch1_transfer(cfg.stream_id[7]);
        end
        forever begin
            collect_dpd_qout_ch0_transfer(cfg.stream_id[8]);
        end
        forever begin
            collect_dpd_qout_ch1_transfer(cfg.stream_id[9]);
        end
        forever begin
            collect_iqcomp_qout_ch0_transfer(cfg.stream_id[10]);
        end
        forever begin
            collect_iqcomp_qout_ch1_transfer(cfg.stream_id[11]);
        end
        forever begin
            collect_up3fir3_qout_ch0_transfer(cfg.stream_id[12]);
        end
        forever begin
            collect_up3fir3_qout_ch1_transfer(cfg.stream_id[13]);
        end
        forever begin
            collect_up2fir2_qout_ch0_transfer(cfg.stream_id[14]);
        end
        forever begin
            collect_up2fir2_qout_ch1_transfer(cfg.stream_id[15]);
        end
        forever begin
            collect_iqloft_qout_ch0_transfer(cfg.stream_id[16]);
        end
        forever begin
            collect_iqloft_qout_ch1_transfer(cfg.stream_id[17]);
        end
        forever begin
            collect_dfe_qout_ch0_transfer(cfg.stream_id[18]);
        end
        forever begin
            collect_dfe_qout_ch1_transfer(cfg.stream_id[19]);
        end
    join
endtask : run_phase //}}}

task dfe_tx_monitor::collect_iqloft_qout_ch0_transfer(WIFI_SCB_STREAM_ID_T stream_id_t); //{{{
    dfe_tx_iq_trans mon_qout_tr;
    integer file_ptr;
    string file_name;
    file_name = get_stream_name(stream_id_t);
    @(vif.moncb iff vif.moncb.iqloft_qout_vld_0 == 1'b1);
    file_ptr = $fopen($sformatf("%0s_packet%04d_DUT.txt",file_name,vif.packet), "a+");
    mon_qout_tr = dfe_tx_iq_trans::type_id::create("mon_qout_tr", this);
    mon_qout_tr.stream_id = stream_id_t;
    mon_qout_tr.i   = vif.moncb.iqloft_qout_re_0;
    mon_qout_tr.q   = vif.moncb.iqloft_qout_im_0;
    mon_qout_tr.packet_idx = vif.packet;
    mon_qout_tr.chk_en = 1'b1;
    mon_port.write(mon_qout_tr);
    mon_port_base.write(mon_qout_tr);
    $fwrite(file_ptr,"%03h %03h\n",mon_qout_tr.i,mon_qout_tr.q);
    $fclose(file_ptr);
    `uvm_info($sformatf("%25s", get_full_name()), $sformatf("test_debug: monitor collected %0d iqloft_qout_ch0 transfers", iqloft_qout_ch0_num_col), UVM_DEBUG)
    iqloft_qout_ch0_num_col++;
    cfg.mon_busy = 0;
endtask : collect_iqloft_qout_ch0_transfer //}}}

task dfe_tx_monitor::collect_iqloft_qout_ch1_transfer(WIFI_SCB_STREAM_ID_T stream_id_t); //{{{
    dfe_tx_iq_trans mon_qout_tr;
    integer file_ptr;
    string file_name;
    file_name = get_stream_name(stream_id_t);
    @(vif.moncb iff vif.moncb.iqloft_qout_vld_1 == 1'b1);
    file_ptr = $fopen($sformatf("%0s_packet%04d_DUT.txt",file_name,vif.packet), "a+");
    mon_qout_tr = dfe_tx_iq_trans::type_id::create("mon_qout_tr", this);
    mon_qout_tr.stream_id = stream_id_t;
    mon_qout_tr.i   = vif.moncb.iqloft_qout_re_1;
    mon_qout_tr.q   = vif.moncb.iqloft_qout_im_1;
    mon_qout_tr.packet_idx = vif.packet;
    mon_qout_tr.chk_en = 1'b1;
    mon_port.write(mon_qout_tr);
    mon_port_base.write(mon_qout_tr);
    $fwrite(file_ptr,"%03h %03h\n",mon_qout_tr.i,mon_qout_tr.q);
    $fclose(file_ptr);
    `uvm_info($sformatf("%25s", get_full_name()), $sformatf("test_debug: monitor collected %0d iqloft_qout_ch1 transfers", iqloft_qout_ch1_num_col), UVM_DEBUG)
    iqloft_qout_ch1_num_col++;
    cfg.mon_busy = 0;
endtask : collect_iqloft_qout_ch1_transfer //}}}

task dfe_tx_monitor::collect_up2fir2_qout_ch0_transfer(WIFI_SCB_STREAM_ID_T stream_id_t); //{{{
    dfe_tx_iq_trans mon_qout_tr;
    integer file_ptr;
    string file_name;
    file_name = get_stream_name(stream_id_t);
    @(vif.moncb iff vif.moncb.up2fir2_qout_vld_0 == 1'b1);
    file_ptr = $fopen($sformatf("%0s_packet%04d_DUT.txt",file_name,vif.packet), "a+");
    mon_qout_tr = dfe_tx_iq_trans::type_id::create("mon_qout_tr", this);
    mon_qout_tr.stream_id = stream_id_t;
    mon_qout_tr.i   = vif.moncb.up2fir2_qout_re_0;
    mon_qout_tr.q   = vif.moncb.up2fir2_qout_im_0;
    mon_qout_tr.packet_idx = vif.packet;
    mon_qout_tr.chk_en = 1'b1;
    mon_port.write(mon_qout_tr);
    mon_port_base.write(mon_qout_tr);
    $fwrite(file_ptr,"%03h %03h\n",mon_qout_tr.i,mon_qout_tr.q);
    $fclose(file_ptr);
    `uvm_info($sformatf("%25s", get_full_name()), $sformatf("test_debug: monitor collected %0d up2fir2_qout_ch0 transfers", up2fir2_qout_ch0_num_col), UVM_DEBUG)
    up2fir2_qout_ch0_num_col++;
    cfg.mon_busy = 0;
endtask : collect_up2fir2_qout_ch0_transfer //}}}

task dfe_tx_monitor::collect_up2fir2_qout_ch1_transfer(WIFI_SCB_STREAM_ID_T stream_id_t); //{{{
    dfe_tx_iq_trans mon_qout_tr;
    integer file_ptr;
    string file_name;
    file_name = get_stream_name(stream_id_t);
    @(vif.moncb iff vif.moncb.up2fir2_qout_vld_1 == 1'b1);
    file_ptr = $fopen($sformatf("%0s_packet%04d_DUT.txt",file_name,vif.packet), "a+");
    mon_qout_tr = dfe_tx_iq_trans::type_id::create("mon_qout_tr", this);
    mon_qout_tr.stream_id = stream_id_t;
    mon_qout_tr.i   = vif.moncb.up2fir2_qout_re_1;
    mon_qout_tr.q   = vif.moncb.up2fir2_qout_im_1;
    mon_qout_tr.packet_idx = vif.packet;
    mon_qout_tr.chk_en = 1'b1;
    mon_port.write(mon_qout_tr);
    mon_port_base.write(mon_qout_tr);
    $fwrite(file_ptr,"%03h %03h\n",mon_qout_tr.i,mon_qout_tr.q);
    $fclose(file_ptr);
    `uvm_info($sformatf("%25s", get_full_name()), $sformatf("test_debug: monitor collected %0d up2fir2_qout_ch1 transfers", up2fir2_qout_ch1_num_col), UVM_DEBUG)
    up2fir2_qout_ch1_num_col++;
    cfg.mon_busy = 0;
endtask : collect_up2fir2_qout_ch1_transfer //}}}

task dfe_tx_monitor::collect_up3fir3_qout_ch0_transfer(WIFI_SCB_STREAM_ID_T stream_id_t); //{{{
    dfe_tx_iq_trans mon_qout_tr;
    integer file_ptr;
    string file_name;
    file_name = get_stream_name(stream_id_t);
    @(vif.moncb iff vif.moncb.up3fir3_qout_vld_0 == 1'b1);
    file_ptr = $fopen($sformatf("%0s_packet%04d_DUT.txt",file_name,vif.packet), "a+");
    mon_qout_tr = dfe_tx_iq_trans::type_id::create("mon_qout_tr", this);
    mon_qout_tr.stream_id = stream_id_t;
    mon_qout_tr.i   = vif.moncb.up3fir3_qout_re_0;
    mon_qout_tr.q   = vif.moncb.up3fir3_qout_im_0;
    mon_qout_tr.packet_idx = vif.packet;
    mon_qout_tr.chk_en = 1'b1;
    mon_port.write(mon_qout_tr);
    mon_port_base.write(mon_qout_tr);
    $fwrite(file_ptr,"%03h %03h\n",mon_qout_tr.i,mon_qout_tr.q);
    $fclose(file_ptr);
    `uvm_info($sformatf("%25s", get_full_name()), $sformatf("test_debug: monitor collected %0d up3fir3_qout_ch0 transfers", up3fir3_qout_ch0_num_col), UVM_DEBUG)
    up3fir3_qout_ch0_num_col++;
    cfg.mon_busy = 0;
endtask : collect_up3fir3_qout_ch0_transfer //}}}

task dfe_tx_monitor::collect_up3fir3_qout_ch1_transfer(WIFI_SCB_STREAM_ID_T stream_id_t); //{{{
    dfe_tx_iq_trans mon_qout_tr;
    integer file_ptr;
    string file_name;
    file_name = get_stream_name(stream_id_t);
    @(vif.moncb iff vif.moncb.up3fir3_qout_vld_1 == 1'b1);
    file_ptr = $fopen($sformatf("%0s_packet%04d_DUT.txt",file_name,vif.packet), "a+");
    mon_qout_tr = dfe_tx_iq_trans::type_id::create("mon_qout_tr", this);
    mon_qout_tr.stream_id = stream_id_t;
    mon_qout_tr.i   = vif.moncb.up3fir3_qout_re_1;
    mon_qout_tr.q   = vif.moncb.up3fir3_qout_im_1;
    mon_qout_tr.packet_idx = vif.packet;
    mon_qout_tr.chk_en = 1'b1;
    mon_port.write(mon_qout_tr);
    mon_port_base.write(mon_qout_tr);
    $fwrite(file_ptr,"%03h %03h\n",mon_qout_tr.i,mon_qout_tr.q);
    $fclose(file_ptr);
    `uvm_info($sformatf("%25s", get_full_name()), $sformatf("test_debug: monitor collected %0d up3fir3_qout_ch1 transfers", up3fir3_qout_ch1_num_col), UVM_DEBUG)
    up3fir3_qout_ch1_num_col++;
    cfg.mon_busy = 0;
endtask : collect_up3fir3_qout_ch1_transfer //}}}

task dfe_tx_monitor::collect_iqcomp_qout_ch0_transfer(WIFI_SCB_STREAM_ID_T stream_id_t); //{{{
    dfe_tx_iq_trans mon_qout_tr;
    integer file_ptr;
    string file_name;
    file_name = get_stream_name(stream_id_t);
    @(vif.moncb iff vif.moncb.iqcomp_qout_vld_0 == 1'b1);
    file_ptr = $fopen($sformatf("%0s_packet%04d_DUT.txt",file_name,vif.packet), "a+");
    mon_qout_tr = dfe_tx_iq_trans::type_id::create("mon_qout_tr", this);
    mon_qout_tr.stream_id = stream_id_t;
    mon_qout_tr.i   = vif.moncb.iqcomp_qout_re_0;
    mon_qout_tr.q   = vif.moncb.iqcomp_qout_im_0;
    mon_qout_tr.packet_idx = vif.packet;
    mon_qout_tr.chk_en = 1'b1;
    mon_port.write(mon_qout_tr);
    mon_port_base.write(mon_qout_tr);
    $fwrite(file_ptr,"%03h %03h\n",mon_qout_tr.i,mon_qout_tr.q);
    $fclose(file_ptr);
    `uvm_info($sformatf("%25s", get_full_name()), $sformatf("test_debug: monitor collected %0d iqcomp_qout_ch0 transfers", iqcomp_qout_ch0_num_col), UVM_DEBUG)
    iqcomp_qout_ch0_num_col++;
    cfg.mon_busy = 0;
endtask : collect_iqcomp_qout_ch0_transfer //}}}

task dfe_tx_monitor::collect_iqcomp_qout_ch1_transfer(WIFI_SCB_STREAM_ID_T stream_id_t); //{{{
    dfe_tx_iq_trans mon_qout_tr;
    integer file_ptr;
    string file_name;
    file_name = get_stream_name(stream_id_t);
    @(vif.moncb iff vif.moncb.iqcomp_qout_vld_1 == 1'b1);
    file_ptr = $fopen($sformatf("%0s_packet%04d_DUT.txt",file_name,vif.packet), "a+");
    mon_qout_tr = dfe_tx_iq_trans::type_id::create("mon_qout_tr", this);
    mon_qout_tr.stream_id = stream_id_t;
    mon_qout_tr.i   = vif.moncb.iqcomp_qout_re_1;
    mon_qout_tr.q   = vif.moncb.iqcomp_qout_im_1;
    mon_qout_tr.packet_idx = vif.packet;
    mon_qout_tr.chk_en = 1'b1;
    mon_port.write(mon_qout_tr);
    mon_port_base.write(mon_qout_tr);
    $fwrite(file_ptr,"%03h %03h\n",mon_qout_tr.i,mon_qout_tr.q);
    $fclose(file_ptr);
    `uvm_info($sformatf("%25s", get_full_name()), $sformatf("test_debug: monitor collected %0d iqcomp_qout_ch1 transfers", iqcomp_qout_ch1_num_col), UVM_DEBUG)
    iqcomp_qout_ch1_num_col++;
    cfg.mon_busy = 0;
endtask : collect_iqcomp_qout_ch1_transfer //}}}

task dfe_tx_monitor::collect_dpd_qout_ch0_transfer(WIFI_SCB_STREAM_ID_T stream_id_t); //{{{
    dfe_tx_iq_trans mon_qout_tr;
    integer file_ptr;
    string file_name;
    file_name = get_stream_name(stream_id_t);
    @(vif.moncb iff vif.moncb.dpd_qout_vld_0 == 1'b1);
    file_ptr = $fopen($sformatf("%0s_packet%04d_DUT.txt",file_name,vif.packet), "a+");
    mon_qout_tr = dfe_tx_iq_trans::type_id::create("mon_qout_tr", this);
    mon_qout_tr.stream_id = stream_id_t;
    mon_qout_tr.i   = vif.moncb.dpd_qout_re_0;
    mon_qout_tr.q   = vif.moncb.dpd_qout_im_0;
    mon_qout_tr.packet_idx = vif.packet;
    mon_qout_tr.chk_en = 1'b1;
    mon_port.write(mon_qout_tr);
    mon_port_base.write(mon_qout_tr);
    $fwrite(file_ptr,"%03h %03h\n",mon_qout_tr.i,mon_qout_tr.q);
    $fclose(file_ptr);
    `uvm_info($sformatf("%25s", get_full_name()), $sformatf("test_debug: monitor collected %0d dpd_qout_ch0 transfers", dpd_qout_ch0_num_col), UVM_DEBUG)
    dpd_qout_ch0_num_col++;
    cfg.mon_busy = 0;
endtask : collect_dpd_qout_ch0_transfer //}}}

task dfe_tx_monitor::collect_dpd_qout_ch1_transfer(WIFI_SCB_STREAM_ID_T stream_id_t); //{{{
    dfe_tx_iq_trans mon_qout_tr;
    integer file_ptr;
    string file_name;
    file_name = get_stream_name(stream_id_t);
    @(vif.moncb iff vif.moncb.dpd_qout_vld_1 == 1'b1);
    file_ptr = $fopen($sformatf("%0s_packet%04d_DUT.txt",file_name,vif.packet), "a+");
    mon_qout_tr = dfe_tx_iq_trans::type_id::create("mon_qout_tr", this);
    mon_qout_tr.stream_id = stream_id_t;
    mon_qout_tr.i   = vif.moncb.dpd_qout_re_1;
    mon_qout_tr.q   = vif.moncb.dpd_qout_im_1;
    mon_qout_tr.packet_idx = vif.packet;
    mon_qout_tr.chk_en = 1'b1;
    mon_port.write(mon_qout_tr);
    mon_port_base.write(mon_qout_tr);
    $fwrite(file_ptr,"%03h %03h\n",mon_qout_tr.i,mon_qout_tr.q);
    $fclose(file_ptr);
    `uvm_info($sformatf("%25s", get_full_name()), $sformatf("test_debug: monitor collected %0d dpd_qout_ch1 transfers", dpd_qout_ch1_num_col), UVM_DEBUG)
    dpd_qout_ch1_num_col++;
    cfg.mon_busy = 0;
endtask : collect_dpd_qout_ch1_transfer //}}}

task dfe_tx_monitor::collect_dgain_qout_ch0_transfer(WIFI_SCB_STREAM_ID_T stream_id_t); //{{{
    dfe_tx_iq_trans mon_qout_tr;
    integer file_ptr;
    string file_name;
    file_name = get_stream_name(stream_id_t);
    @(vif.moncb iff vif.moncb.dgain_qout_vld_0 == 1'b1);
    file_ptr = $fopen($sformatf("%0s_packet%04d_DUT.txt",file_name,vif.packet), "a+");
    mon_qout_tr = dfe_tx_iq_trans::type_id::create("mon_qout_tr", this);
    mon_qout_tr.stream_id = stream_id_t;
    mon_qout_tr.i   = vif.moncb.dgain_qout_re_0;
    mon_qout_tr.q   = vif.moncb.dgain_qout_im_0;
    mon_qout_tr.packet_idx = vif.packet;
    mon_qout_tr.chk_en = 1'b1;
    mon_port.write(mon_qout_tr);
    mon_port_base.write(mon_qout_tr);
    $fwrite(file_ptr,"%03h %03h\n",mon_qout_tr.i,mon_qout_tr.q);
    $fclose(file_ptr);
    `uvm_info($sformatf("%25s", get_full_name()), $sformatf("test_debug: monitor collected %0d dgain_qout_ch0 transfers", dgain_qout_ch0_num_col), UVM_DEBUG)
    dgain_qout_ch0_num_col++;
    cfg.mon_busy = 0;
endtask : collect_dgain_qout_ch0_transfer //}}}

task dfe_tx_monitor::collect_dgain_qout_ch1_transfer(WIFI_SCB_STREAM_ID_T stream_id_t); //{{{
    dfe_tx_iq_trans mon_qout_tr;
    integer file_ptr;
    string file_name;
    file_name = get_stream_name(stream_id_t);
    @(vif.moncb iff vif.moncb.dgain_qout_vld_1 == 1'b1);
    file_ptr = $fopen($sformatf("%0s_packet%04d_DUT.txt",file_name,vif.packet), "a+");
    mon_qout_tr = dfe_tx_iq_trans::type_id::create("mon_qout_tr", this);
    mon_qout_tr.stream_id = stream_id_t;
    mon_qout_tr.i   = vif.moncb.dgain_qout_re_1;
    mon_qout_tr.q   = vif.moncb.dgain_qout_im_1;
    mon_qout_tr.packet_idx = vif.packet;
    mon_qout_tr.chk_en = 1'b1;
    mon_port.write(mon_qout_tr);
    mon_port_base.write(mon_qout_tr);
    $fwrite(file_ptr,"%03h %03h\n",mon_qout_tr.i,mon_qout_tr.q);
    $fclose(file_ptr);
    `uvm_info($sformatf("%25s", get_full_name()), $sformatf("test_debug: monitor collected %0d dgain_qout_ch1 transfers", dgain_qout_ch1_num_col), UVM_DEBUG)
    dgain_qout_ch1_num_col++;
    cfg.mon_busy = 0;
endtask : collect_dgain_qout_ch1_transfer //}}}

task dfe_tx_monitor::collect_nco4_din_ch0_transfer(WIFI_SCB_STREAM_ID_T stream_id_t); //{{{
    dfe_tx_iq_trans mon_din_tr;
    integer file_ptr;
    string file_name;
    file_name = get_stream_name(stream_id_t);
    @(vif.moncb iff vif.moncb.nco4_din_vld_0 == 1'b1);
    file_ptr = $fopen($sformatf("%0s_packet%04d_DUT.txt",file_name,vif.packet), "a+");
    mon_din_tr = dfe_tx_iq_trans::type_id::create("mon_din_tr", this);
    mon_din_tr.stream_id = stream_id_t;
    mon_din_tr.i   = vif.moncb.nco4_din_re_0;
    mon_din_tr.q   = vif.moncb.nco4_din_im_0;
    mon_din_tr.packet_idx = vif.packet;
    mon_din_tr.chk_en = 1'b1;
    mon_port.write(mon_din_tr);
    mon_port_base.write(mon_din_tr);
    $fwrite(file_ptr,"%03h %03h\n",mon_din_tr.i,mon_din_tr.q);
    $fclose(file_ptr);
    `uvm_info($sformatf("%25s", get_full_name()), $sformatf("test_debug: monitor collected %0d nco4_din_ch0 transfers", nco4_din_ch0_num_col), UVM_DEBUG)
    nco4_din_ch0_num_col++;
    cfg.mon_busy = 0;
endtask : collect_nco4_din_ch0_transfer //}}}

task dfe_tx_monitor::collect_nco4_din_ch1_transfer(WIFI_SCB_STREAM_ID_T stream_id_t); //{{{
    dfe_tx_iq_trans mon_din_tr;
    integer file_ptr;
    string file_name;
    file_name = get_stream_name(stream_id_t);
    @(vif.moncb iff vif.moncb.nco4_din_vld_1 == 1'b1);
    file_ptr = $fopen($sformatf("%0s_packet%04d_DUT.txt",file_name,vif.packet), "a+");
    mon_din_tr = dfe_tx_iq_trans::type_id::create("mon_din_tr", this);
    mon_din_tr.stream_id = stream_id_t;
    mon_din_tr.i   = vif.moncb.nco4_din_re_1;
    mon_din_tr.q   = vif.moncb.nco4_din_im_1;
    mon_din_tr.packet_idx = vif.packet;
    mon_din_tr.chk_en = 1'b1;
    mon_port.write(mon_din_tr);
    mon_port_base.write(mon_din_tr);
    $fwrite(file_ptr,"%03h %03h\n",mon_din_tr.i,mon_din_tr.q);
    $fclose(file_ptr);
    `uvm_info($sformatf("%25s", get_full_name()), $sformatf("test_debug: monitor collected %0d nco4_din_ch1 transfers", nco4_din_ch1_num_col), UVM_DEBUG)
    nco4_din_ch1_num_col++;
    cfg.mon_busy = 0;
endtask : collect_nco4_din_ch1_transfer //}}}

task dfe_tx_monitor::collect_cfr_qout_ch0_transfer(WIFI_SCB_STREAM_ID_T stream_id_t); //{{{
    dfe_tx_iq_trans mon_qout_tr;
    integer file_ptr;
    string file_name;
    file_name = get_stream_name(stream_id_t);
    @(vif.moncb iff vif.moncb.cfr_dout_vld_0 == 1'b1);
    file_ptr = $fopen($sformatf("%0s_packet%04d_DUT.txt",file_name,vif.packet), "a+");
    mon_qout_tr = dfe_tx_iq_trans::type_id::create("mon_qout_tr", this);
    mon_qout_tr.stream_id = stream_id_t;
    mon_qout_tr.i   = vif.moncb.cfr_dout_i_0;
    mon_qout_tr.q   = vif.moncb.cfr_dout_q_0;
    mon_qout_tr.packet_idx = vif.packet;
    mon_qout_tr.chk_en = 1'b1;
    mon_port.write(mon_qout_tr);
    mon_port_base.write(mon_qout_tr);
    $fwrite(file_ptr,"%03h %03h\n",mon_qout_tr.i,mon_qout_tr.q);
    $fclose(file_ptr);
    `uvm_info($sformatf("%25s", get_full_name()), $sformatf("test_debug: monitor collected %0d cfr_qout_ch0 transfers", cfr_qout_ch0_num_col), UVM_DEBUG)
    cfr_qout_ch0_num_col++;
    cfg.mon_busy = 0;
endtask : collect_cfr_qout_ch0_transfer //}}}

task dfe_tx_monitor::collect_cfr_qout_ch1_transfer(WIFI_SCB_STREAM_ID_T stream_id_t); //{{{
    dfe_tx_iq_trans mon_qout_tr;
    integer file_ptr;
    string file_name;
    file_name = get_stream_name(stream_id_t);
    @(vif.moncb iff vif.moncb.cfr_dout_vld_1 == 1'b1);
    file_ptr = $fopen($sformatf("%0s_packet%04d_DUT.txt",file_name,vif.packet), "a+");
    mon_qout_tr = dfe_tx_iq_trans::type_id::create("mon_qout_tr", this);
    mon_qout_tr.stream_id = stream_id_t;
    mon_qout_tr.i   = vif.moncb.cfr_dout_i_1;
    mon_qout_tr.q   = vif.moncb.cfr_dout_q_1;
    mon_qout_tr.packet_idx = vif.packet;
    mon_qout_tr.chk_en = 1'b1;
    mon_port.write(mon_qout_tr);
    mon_port_base.write(mon_qout_tr);
    $fwrite(file_ptr,"%03h %03h\n",mon_qout_tr.i,mon_qout_tr.q);
    $fclose(file_ptr);
    `uvm_info($sformatf("%25s", get_full_name()), $sformatf("test_debug: monitor collected %0d cfr_qout_ch1 transfers", cfr_qout_ch1_num_col), UVM_DEBUG)
    cfr_qout_ch1_num_col++;
    cfg.mon_busy = 0;
endtask : collect_cfr_qout_ch1_transfer //}}}

task dfe_tx_monitor::collect_cfr_din_ch0_transfer(WIFI_SCB_STREAM_ID_T stream_id_t); //{{{
    dfe_tx_iq_trans mon_din_tr;
    integer file_ptr;
    string file_name;
    file_name = get_stream_name(stream_id_t);
    @(vif.moncb iff vif.moncb.cfr_din_vld_0 == 1'b1);
    file_ptr = $fopen($sformatf("%0s_packet%04d_DUT.txt",file_name,vif.packet), "a+");
    mon_din_tr = dfe_tx_iq_trans::type_id::create("mon_din_tr", this);
    mon_din_tr.stream_id = stream_id_t;
    mon_din_tr.i   = vif.moncb.cfr_din_i_0;
    mon_din_tr.q   = vif.moncb.cfr_din_q_0;
    mon_din_tr.packet_idx = vif.packet;
    mon_din_tr.chk_en = 1'b1;
    mon_port.write(mon_din_tr);
    mon_port_base.write(mon_din_tr);
    $fwrite(file_ptr,"%03h %03h\n",mon_din_tr.i,mon_din_tr.q);
    $fclose(file_ptr);
    `uvm_info($sformatf("%25s", get_full_name()), $sformatf("test_debug: monitor collected %0d cfr_din_ch0 transfers", cfr_din_ch0_num_col), UVM_DEBUG)
    cfr_din_ch0_num_col++;
    cfg.mon_busy = 0;
endtask : collect_cfr_din_ch0_transfer //}}}

task dfe_tx_monitor::collect_cfr_din_ch1_transfer(WIFI_SCB_STREAM_ID_T stream_id_t); //{{{
    dfe_tx_iq_trans mon_din_tr;
    integer file_ptr;
    string file_name;
    file_name = get_stream_name(stream_id_t);
    @(vif.moncb iff vif.moncb.cfr_din_vld_1 == 1'b1);
    file_ptr = $fopen($sformatf("%0s_packet%04d_DUT.txt",file_name,vif.packet), "a+");
    mon_din_tr = dfe_tx_iq_trans::type_id::create("mon_din_tr", this);
    mon_din_tr.stream_id = stream_id_t;
    mon_din_tr.i   = vif.moncb.cfr_din_i_1;
    mon_din_tr.q   = vif.moncb.cfr_din_q_1;
    mon_din_tr.packet_idx = vif.packet;
    mon_din_tr.chk_en = 1'b1;
    mon_port.write(mon_din_tr);
    mon_port_base.write(mon_din_tr);
    $fwrite(file_ptr,"%03h %03h\n",mon_din_tr.i,mon_din_tr.q);
    $fclose(file_ptr);
    `uvm_info($sformatf("%25s", get_full_name()), $sformatf("test_debug: monitor collected %0d cfr_din_ch1 transfers", cfr_din_ch1_num_col), UVM_DEBUG)
    cfr_din_ch1_num_col++;
    cfg.mon_busy = 0;
endtask : collect_cfr_din_ch1_transfer //}}}

task dfe_tx_monitor::collect_dfe_qout_ch0_transfer(WIFI_SCB_STREAM_ID_T stream_id_t); //{{{
    dfe_tx_iq_trans mon_qout_tr;
    integer file_ptr;
    string file_name;
    file_name = get_stream_name(stream_id_t);
    @(vif.moncb iff vif.moncb.dfe_tx_qout_vld_0 == 1'b1);
    file_ptr = $fopen($sformatf("%0s_packet%04d_DUT.txt",file_name,vif.packet), "a+");
    mon_qout_tr = dfe_tx_iq_trans::type_id::create("mon_qout_tr", this);
    mon_qout_tr.stream_id = stream_id_t;
    mon_qout_tr.i   = vif.moncb.dfe_tx_qout_re_0;
    mon_qout_tr.q   = vif.moncb.dfe_tx_qout_im_0;
    mon_qout_tr.packet_idx = vif.packet;
    mon_qout_tr.chk_en = 1'b1;
    mon_port.write(mon_qout_tr);
    mon_port_base.write(mon_qout_tr);
    $fwrite(file_ptr,"%03h %03h\n",mon_qout_tr.i,mon_qout_tr.q);
    $fclose(file_ptr);
    `uvm_info($sformatf("%25s", get_full_name()), $sformatf("test_debug: monitor collected %0d dfe_tx_qout_ch0 transfers", dfe_tx_qout_ch0_num_col), UVM_DEBUG)
    dfe_tx_qout_ch0_num_col++;
    cfg.mon_busy = 0;
endtask : collect_dfe_qout_ch0_transfer //}}}

task dfe_tx_monitor::collect_dfe_qout_ch1_transfer(WIFI_SCB_STREAM_ID_T stream_id_t); //{{{
    dfe_tx_iq_trans mon_qout_tr;
    integer file_ptr;
    string file_name;
    file_name = get_stream_name(stream_id_t);
    @(vif.moncb iff vif.moncb.dfe_tx_qout_vld_1 == 1'b1);
    file_ptr = $fopen($sformatf("%0s_packet%04d_DUT.txt",file_name,vif.packet), "a+");
    mon_qout_tr = dfe_tx_iq_trans::type_id::create("mon_qout_tr", this);
    mon_qout_tr.stream_id = stream_id_t;
    mon_qout_tr.i   = vif.moncb.dfe_tx_qout_re_1;
    mon_qout_tr.q   = vif.moncb.dfe_tx_qout_im_1;
    mon_qout_tr.packet_idx = vif.packet;
    mon_qout_tr.chk_en = 1'b1;
    mon_port.write(mon_qout_tr);
    mon_port_base.write(mon_qout_tr);
    $fwrite(file_ptr,"%03h %03h\n",mon_qout_tr.i,mon_qout_tr.q);
    $fclose(file_ptr);
    `uvm_info($sformatf("%25s", get_full_name()), $sformatf("test_debug: monitor collected %0d dfe_tx_qout_ch1 transfers", dfe_tx_qout_ch1_num_col), UVM_DEBUG)
    dfe_tx_qout_ch1_num_col++;
    cfg.mon_busy = 0;
endtask : collect_dfe_qout_ch1_transfer //}}}

function void dfe_tx_monitor::report_phase(uvm_phase phase); //{{{
    //`uvm_info($sformatf("%25s", get_full_name()), $sformatf("\nReport: register database monitor collected %0d transfers", num_col), UVM_LOW)
endfunction : report_phase //}}}

`endif
