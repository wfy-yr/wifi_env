class dfe_tx_ref_model extends uvm_component;
    virtual dfe_tx_top_intf top_vif;

    dfe_tx_env_cfg     m_dfe_tx_env_cfg;

    wifi_tv_proc   tv_proc;

    //expect port to scb
    uvm_analysis_port#(wifi_fifo_trans)      exp_ap;
    
    `uvm_component_utils(dfe_tx_ref_model)

    extern function new(input string name, input uvm_component parent=null);

    extern virtual function void build_phase(uvm_phase phase);
    extern virtual function void connect_phase(uvm_phase phase);
    extern virtual function void read_2_col_tv(input string file_name, ref bit [11:0] col_q[2][$]);

    extern virtual task run_phase(uvm_phase phase);
    extern virtual task read_dfe_iq_ch0_tv(input string file_name, WIFI_SCB_STREAM_ID_T stream_id_t, wifi_tv_dir_trans tr);
    extern virtual task read_dfe_iq_ch1_tv(input string file_name, WIFI_SCB_STREAM_ID_T stream_id_t, wifi_tv_dir_trans tr);
endclass : dfe_tx_ref_model 


function dfe_tx_ref_model::new(input string name, input uvm_component parent=null);
    super.new(name,parent);
    //tb_cmd_fifo_port = new("tb_cmd_fifo_port", this); 
    exp_ap = new("exp_ap", this); 
endfunction : new

function void dfe_tx_ref_model::build_phase(uvm_phase phase); // {{{
    super.build_phase(phase);

    `uvm_info($sformatf("%25s", get_name()), $sformatf("build_phase begin"), UVM_LOW)
    
    if(!uvm_config_db#(virtual dfe_tx_top_intf)::get(this, "", "vif", top_vif)) begin
        `uvm_fatal("NOCFG", $sformatf("[%s] Cannot get dfe_tx_top_vif", get_full_name()))
    end      


    if(!uvm_config_db#(dfe_tx_env_cfg)::get(this, "", "m_dfe_tx_env_cfg", m_dfe_tx_env_cfg)) begin
        `uvm_fatal("NOCFG", $sformatf("[%s] Cannot get dfe_tx_env_cfg", get_full_name()))
    end

    tv_proc = new();

    `uvm_info($sformatf("%25s", get_name()), $sformatf("build_phase end"), UVM_LOW)
endfunction : build_phase // }}}


function void dfe_tx_ref_model::connect_phase(uvm_phase phase); // {{{
    super.connect_phase(phase);
endfunction : connect_phase // }}}


task dfe_tx_ref_model::run_phase(uvm_phase phase); // {{{
    wifi_tv_dir_trans dir_q[$];

    tv_proc.set_default();
    tv_proc.parse_wifi_case_dir(dir_q,`CASE_NUM);
    for(int ii=0; ii<dir_q.size(); ii++) begin
        fork
            read_dfe_iq_ch0_tv("dfe_tx_cfr_din_ch_0.txt",DFE_TX_CFR_DIN_CH0_CHK,dir_q[ii]);
            read_dfe_iq_ch1_tv("dfe_tx_cfr_din_ch_1.txt",DFE_TX_CFR_DIN_CH1_CHK,dir_q[ii]);
            read_dfe_iq_ch0_tv("dfe_tx_cfr_qout_ch_0.txt",DFE_TX_CFR_QOUT_CH0_CHK,dir_q[ii]);
            read_dfe_iq_ch1_tv("dfe_tx_cfr_qout_ch_1.txt",DFE_TX_CFR_QOUT_CH1_CHK,dir_q[ii]);
            read_dfe_iq_ch0_tv("dfe_tx_nco4_din_ch_0.txt",DFE_TX_NCO4_DIN_CH0_CHK,dir_q[ii]);
            read_dfe_iq_ch1_tv("dfe_tx_nco4_din_ch_1.txt",DFE_TX_NCO4_DIN_CH1_CHK,dir_q[ii]);
            read_dfe_iq_ch0_tv("dfe_tx_dgain_qout_ch_0.txt",DFE_TX_DGAIN_QOUT_CH0_CHK,dir_q[ii]);
            read_dfe_iq_ch1_tv("dfe_tx_dgain_qout_ch_1.txt",DFE_TX_DGAIN_QOUT_CH1_CHK,dir_q[ii]);
            read_dfe_iq_ch0_tv("dfe_tx_dpd_qout_ch_0.txt",DFE_TX_DPD_QOUT_CH0_CHK,dir_q[ii]);
            read_dfe_iq_ch1_tv("dfe_tx_dpd_qout_ch_1.txt",DFE_TX_DPD_QOUT_CH1_CHK,dir_q[ii]);
            read_dfe_iq_ch0_tv("dfe_tx_iqcomp_qout_ch_0.txt",DFE_TX_IQCOMP_QOUT_CH0_CHK,dir_q[ii]);
            read_dfe_iq_ch1_tv("dfe_tx_iqcomp_qout_ch_1.txt",DFE_TX_IQCOMP_QOUT_CH1_CHK,dir_q[ii]);
            read_dfe_iq_ch0_tv("dfe_tx_up3fir2_qout_ch_0.txt",DFE_TX_UP3FIR2_QOUT_CH0_CHK,dir_q[ii]);
            read_dfe_iq_ch1_tv("dfe_tx_up3fir2_qout_ch_1.txt",DFE_TX_UP3FIR2_QOUT_CH1_CHK,dir_q[ii]);
            read_dfe_iq_ch0_tv("dfe_tx_up2fir3_qout_ch_0.txt",DFE_TX_UP2FIR3_QOUT_CH0_CHK,dir_q[ii]);
            read_dfe_iq_ch1_tv("dfe_tx_up2fir3_qout_ch_1.txt",DFE_TX_UP2FIR3_QOUT_CH1_CHK,dir_q[ii]);
            read_dfe_iq_ch0_tv("dfe_tx_loft_qout_ch_0.txt",DFE_TX_LOFT_QOUT_CH0_CHK,dir_q[ii]);
            read_dfe_iq_ch1_tv("dfe_tx_loft_qout_ch_1.txt",DFE_TX_LOFT_QOUT_CH1_CHK,dir_q[ii]);
            read_dfe_iq_ch0_tv("dfe_tx_iqswap_qout_ch_0.txt",DFE_TX_IQSWAP_QOUT_CH0_CHK,dir_q[ii]);
            read_dfe_iq_ch1_tv("dfe_tx_iqswap_qout_ch_1.txt",DFE_TX_IQSWAP_QOUT_CH1_CHK,dir_q[ii]);
        join_any
    end
endtask : run_phase // }}}

task dfe_tx_ref_model::read_dfe_iq_ch0_tv(input string file_name, WIFI_SCB_STREAM_ID_T stream_id_t, wifi_tv_dir_trans tr); // {{{
    bit [11:0] golden_data[2][$];
    dfe_tx_iq_trans qout_tr;
    integer file_ptr;
    string golden_file_name;
    golden_file_name = get_stream_name(stream_id_t);

    @(posedge top_vif.clk iff top_vif.mdm2riu_tx0_en == 1 && top_vif.packet == tr.packet_idx);
    read_2_col_tv($sformatf("%0s/pkt%0d/RIU_DFE/%0s",tr.case_path,tr.packet_idx,file_name),golden_data);
    file_ptr = $fopen($sformatf("%0s_packet%04d_GOLDEN.txt",golden_file_name,tr.packet_idx), "a+");
    for(int ii=0; ii<golden_data[0].size(); ii++)begin
        qout_tr = dfe_tx_iq_trans::type_id::create("qout_tr", this);
        qout_tr.i   = golden_data[1][ii];
        qout_tr.q   = golden_data[0][ii];
        qout_tr.chk_en     = 1'b1;
        qout_tr.stream_id  = stream_id_t;
        qout_tr.packet_idx = tr.packet_idx;
        exp_ap.write(qout_tr);
        $fwrite(file_ptr,"%03h %03h\n",qout_tr.i,qout_tr.q);
    end
    $fclose(file_ptr);
endtask : read_dfe_iq_ch0_tv // }}}

task dfe_tx_ref_model::read_dfe_iq_ch1_tv(input string file_name, WIFI_SCB_STREAM_ID_T stream_id_t, wifi_tv_dir_trans tr); // {{{
    bit [11:0] golden_data[2][$];
    dfe_tx_iq_trans qout_tr;
    integer file_ptr;
    string golden_file_name;
    golden_file_name = get_stream_name(stream_id_t);

    @(posedge top_vif.clk iff top_vif.mdm2riu_tx1_en == 1 && top_vif.packet == tr.packet_idx);
    read_2_col_tv($sformatf("%0s/pkt%0d/RIU_DFE/%0s",tr.case_path,tr.packet_idx,file_name),golden_data);
    file_ptr = $fopen($sformatf("%0s_packet%04d_GOLDEN.txt",golden_file_name,tr.packet_idx), "a+");
    for(int ii=0; ii<golden_data[0].size(); ii++)begin
        qout_tr = dfe_tx_iq_trans::type_id::create("qout_tr", this);
        qout_tr.i   = golden_data[1][ii];
        qout_tr.q   = golden_data[0][ii];
        qout_tr.chk_en     = 1'b1;
        qout_tr.stream_id  = stream_id_t;
        qout_tr.packet_idx = tr.packet_idx;
        exp_ap.write(qout_tr);
        $fwrite(file_ptr,"%03h %03h\n",qout_tr.i,qout_tr.q);
    end
    $fclose(file_ptr);
endtask : read_dfe_iq_ch1_tv // }}}

function void dfe_tx_ref_model::read_2_col_tv(input string file_name, ref bit [11:0] col_q[2][$]);
   bit [11:0]  col_data[2];
   integer     data_file_ptr;
   int     data_line_flg=0;
   
   data_file_ptr = $fopen(file_name, "r");
   while(!$feof(data_file_ptr)) begin
      if($fscanf(data_file_ptr,"%0h %0h", col_data[0], col_data[1])>0) begin
      	  col_q[0][data_line_flg] = col_data[0];
      	  col_q[1][data_line_flg] = col_data[1];
          data_line_flg++;
      end
   end
   $fclose(data_file_ptr);
   `uvm_info("dfe_tx_tv_proc", $sformatf("col_q.size = %0d", col_q[0].size()), UVM_DEBUG);            
endfunction : read_2_col_tv
