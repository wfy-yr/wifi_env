// =========================================================================== //
// Author       : fengyang.wu - ASR
// Last modified: 2020-07-10 18:48
// Filename     : dfe_tx_driver.sv
// Description  : 
// =========================================================================== //
`ifndef DFE_TX_DRIVER_SV
`define DFE_TX_DRIVER_SV

//import "DPI-C" task txbf_main(int argc);

class dfe_tx_driver extends uvm_driver;

    virtual dfe_tx_top_intf           vif;

    dfe_tx_env_cfg                cfg;
    wifi_tv_proc                  tv_proc;

    // count trans sent
    int num_sent = 0;
    string case_path;


    `uvm_component_utils_begin(dfe_tx_driver)
        `uvm_field_int(num_sent, UVM_ALL_ON)
        `uvm_field_object(cfg, UVM_ALL_ON)
    `uvm_component_utils_end

    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    extern virtual function void build_phase(uvm_phase phase);

    extern virtual task reset_vif_sigs();
    extern virtual task run_phase(uvm_phase phase);
    extern virtual task req_drive(wifi_tv_dir_trans tr);
    extern virtual task common_cfg(ref bit [31:0] para_cfg[string], wifi_tv_dir_trans tr);
    extern virtual task drive_dfe_din_ch0(input mdm2riu_tx_sig_bw, wifi_tv_dir_trans tr);
    extern virtual task drive_dfe_din_ch1(input mdm2riu_tx_sig_bw, wifi_tv_dir_trans tr);
    extern virtual task drive_riu_reg(wifi_tv_dir_trans tr);
    extern virtual task drive_dpd_lut(wifi_tv_dir_trans tr);
    extern virtual task drive_rf_cali_lut(wifi_tv_dir_trans tr);
    extern virtual function void read_2_col_tv(input string file_name, ref bit [31:0] col_q[2][$]);

    //Timeout methods
    extern virtual task timeout_mon();

    //dynamic reset task
    //don't care if not need dynamic reset
    extern virtual task dynamic_rst(uvm_phase phase);
    extern virtual task reset_all(uvm_phase phase);
    extern virtual function void report_phase(uvm_phase phase);
endclass: dfe_tx_driver

function void dfe_tx_driver::build_phase(uvm_phase phase); //{{{
    super.build_phase(phase);

    if(!uvm_config_db#(virtual dfe_tx_top_intf)::get(this, "", "vif", vif)) begin
       `uvm_fatal(get_full_name(), $psprintf("Can not get vif !"))
    end

    if(!uvm_config_db#(dfe_tx_env_cfg)::get(this, "", "m_dfe_tx_env_cfg", cfg)) begin
       `uvm_fatal(get_full_name(), $psprintf("Can not get cfg !"))
    end
    tv_proc = new();
endfunction : build_phase //}}}

task dfe_tx_driver::reset_vif_sigs(); //{{{
    `uvm_info($sformatf("%25s", get_full_name()), $sformatf("Reset dfe_tx signal"), UVM_MEDIUM)
    vif.drvcb.mac2riu_tx_en           <= 'h0;
    vif.drvcb.scan_mode               <= 'h0;
    vif.drvcb.mem_ema_cfg             <= 'h5945_4000_0003_5102;
    vif.drvcb.phy_cfg_tx_ch_bw        <= 'h0;
    vif.drvcb.phy_cfg_tx_fdac         <= 'h0;
    vif.drvcb.phy_cfg_tx_p20_pos      <= 'h0;
    vif.drvcb.paddr_riu               <= 'h0;
    vif.drvcb.pwdata_riu              <= 'h0;
    vif.drvcb.psel_riu                <= 'h0;
    vif.drvcb.penable_riu             <= 'h0;
    vif.drvcb.pwrite_riu              <= 'h0;
    vif.drvcb.mdm2riu_tx0_re          <= 'h0;
    vif.drvcb.mdm2riu_tx0_im          <= 'h0;
    vif.drvcb.mdm2riu_tx0_vld         <= 'h0;
    vif.drvcb.mdm2riu_tx1_re          <= 'h0;
    vif.drvcb.mdm2riu_tx1_im          <= 'h0;
    vif.drvcb.mdm2riu_tx1_vld         <= 'h0;
    vif.drvcb.mdm2riu_tx_err          <= 'h0; 
    vif.drvcb.mdm2riu_tx0_en          <= 'h0;
    vif.drvcb.mdm2riu_tx1_en          <= 'h0;
    vif.drvcb.mdm2riu_tx_format       <= 'h0;
    vif.drvcb.mdm2riu_tx_mcs          <= 'h0;
    vif.drvcb.mdm2riu_tx_sig_bw       <= 'h0;
    vif.drvcb.mdm2riu_tx_vld_end      <= 'h0;
    vif.drvcb.mdm2riu_dsss_tx0_vld    <= 'h0;
    vif.drvcb.mdm2riu_dsss_tx0_re     <= 'h0;
    vif.drvcb.mdm2riu_dsss_tx0_im     <= 'h0;
    vif.drvcb.mpif_tx0_rf_gain_idx    <= 'h0;
    vif.drvcb.mpif_tx1_rf_gain_idx    <= 'h0;
    vif.drvcb.mpif_tx0_target_pwridx  <= 'h0;
    vif.drvcb.mpif_tx1_target_pwridx  <= 'h0;
    vif.drvcb.mpif_tx0_dig_gain       <= 'h0;
    vif.drvcb.mpif_tx1_dig_gain       <= 'h0;
    vif.drvcb.ad_pll_locked           <= 'h0;
    vif.drvcb.mac2riu_tb_mode         <= 'h0;
    vif.drvcb.obss_pd_level           <= 'h0;


    wait(vif.rst);
    repeat(10) @(vif.drvcb); 
endtask : reset_vif_sigs //}}}

task dfe_tx_driver::run_phase(uvm_phase phase); //{{{
    wifi_tv_dir_trans dir_q[$];
    //reset dut
    phase.raise_objection(this);
    tv_proc.set_default();
    tv_proc.parse_wifi_case_dir(dir_q,`CASE_NUM);
    reset_vif_sigs();
    if(cfg.drv_timeout_chk) timeout_mon();
    //fork 
        //forever begin
        //    fork
        //        req_drive();
        //    join_none
        //    dynamic_rst(phase);
        //    disable fork;
        //end
    //join
    foreach(dir_q[ii]) begin
        req_drive(dir_q[ii]);
    end
    phase.drop_objection(this);
    `uvm_info($sformatf("%25s", get_full_name()), $sformatf("run_phase end"), UVM_LOW)
endtask : run_phase //}}}

task dfe_tx_driver::req_drive(wifi_tv_dir_trans tr); //{{{
     bit [31:0] para_cfg[string];
           
     num_sent++;
    
     `uvm_info($sformatf("%25s", get_full_name()), $sformatf("Item %0d Sent ...", num_sent), UVM_MEDIUM)
     cfg.drv_busy = 1;
     common_cfg(para_cfg,tr);
     drive_riu_reg(tr); 
     drive_dpd_lut(tr); 
     drive_rf_cali_lut(tr); 
     @(vif.drvcb);
     vif.drvcb.mdm2riu_tx0_en    <= para_cfg["mdm2riu_tx0_en"];
     vif.drvcb.mdm2riu_tx1_en    <= para_cfg["mdm2riu_tx1_en"];
     repeat(100) @(vif.drvcb);
     vif.drvcb.mac2riu_tx_en     <= 'h1;
     repeat(480) @(vif.drvcb);
     fork
         if(para_cfg["mdm2riu_tx0_en"] == 'h1) drive_dfe_din_ch0(para_cfg["mdm2riu_tx_sig_bw"],tr); 
         if(para_cfg["mdm2riu_tx1_en"] == 'h1) drive_dfe_din_ch1(para_cfg["mdm2riu_tx_sig_bw"],tr); 
     join
     repeat(100) @(vif.drvcb);
     cfg.drv_busy = 0;
     `uvm_info($sformatf("%25s", get_full_name()), $sformatf("Item %0d Sent end", num_sent), UVM_HIGH)
endtask : req_drive // }}}

task dfe_tx_driver::common_cfg(ref bit [31:0] para_cfg[string], wifi_tv_dir_trans tr); //{{{
     tv_proc.read_reg_cfg_tv($sformatf("%0s/pkt%0d/RIU_DFE/dfe_tx_para.txt",tr.case_path,tr.packet_idx),para_cfg);
     @(vif.drvcb);
     vif.drvcb.phy_cfg_tx_ch_bw          <= para_cfg["phy_tx_ch_bw"];
     vif.drvcb.phy_cfg_tx_fdac           <= para_cfg["phy_tx_fdac"];
     vif.drvcb.phy_cfg_tx_p20_pos        <= para_cfg["tx_pri20_pos"];
     vif.drvcb.mdm2riu_tx_format         <= para_cfg["mdm2riu_tx_format"];
     vif.drvcb.mdm2riu_tx_mcs            <= para_cfg["mdm2riu_tx_mcs"];
     vif.drvcb.mdm2riu_tx_sig_bw         <= para_cfg["mdm2riu_tx_sig_bw"];
     vif.drvcb.mpif_tx0_rf_gain_idx      <= para_cfg["mpif_tx0_rf_gain_idx"];
     vif.drvcb.mpif_tx1_rf_gain_idx      <= para_cfg["mpif_tx1_rf_gain_idx"];
     vif.drvcb.mpif_tx0_target_pwridx    <= para_cfg["mpif_tx0_target_pwr_idx"];
     vif.drvcb.mpif_tx1_target_pwridx    <= para_cfg["mpif_tx1_target_pwr_idx"];
     vif.drvcb.mpif_tx0_dig_gain         <= para_cfg["mpif_tx0_dig_gain"];
     vif.drvcb.mpif_tx1_dig_gain         <= para_cfg["mpif_tx1_dig_gain"];
     vif.packet                          <= tr.packet_idx;
endtask : common_cfg // }}}

task dfe_tx_driver::drive_riu_reg(wifi_tv_dir_trans tr); //{{{
     bit [31:0] data_queue[2][$];
     
     read_2_col_tv($sformatf("%0s/pkt%0d/RIU_Top/riu_reg.txt",tr.case_path,tr.packet_idx),data_queue);
     @(vif.drvcb);
     vif.drvcb.paddr_riu     <= 'h3c;
     vif.drvcb.pwdata_riu    <= 'h1;
     vif.drvcb.psel_riu      <= 1'b1;
     vif.drvcb.penable_riu   <= 1'b1;
     vif.drvcb.pwrite_riu    <= 1'b1;
     @(vif.drvcb);
     vif.drvcb.paddr_riu     <= 'h0;
     vif.drvcb.pwdata_riu    <= 'h0;
     vif.drvcb.psel_riu      <= 'h0;
     vif.drvcb.penable_riu   <= 'h0;
     vif.drvcb.pwrite_riu    <= 'h0;

     foreach(data_queue[0][ii]) begin
         //@(vif.drvcb iff vif.drvcb.pready_riu == 'b1);
         @(vif.drvcb);
         vif.drvcb.paddr_riu     <= data_queue[0][ii];
         vif.drvcb.pwdata_riu    <= data_queue[1][ii];
         vif.drvcb.psel_riu      <= 1'b1;
         vif.drvcb.penable_riu   <= 1'b1;
         vif.drvcb.pwrite_riu    <= 1'b1;
         @(vif.drvcb);
         vif.drvcb.paddr_riu     <= 'h0;
         vif.drvcb.pwdata_riu    <= 'h0;
         vif.drvcb.psel_riu      <= 'h0;
         vif.drvcb.penable_riu   <= 'h0;
         vif.drvcb.pwrite_riu    <= 'h0;
     end
endtask : drive_riu_reg // }}}

task dfe_tx_driver::drive_dpd_lut(wifi_tv_dir_trans tr); //{{{
     bit [31:0] data_queue[$];
     
     tv_proc.read_single_col_tv($sformatf("%0s/pkt%0d/RIU_DFE/dpd_comp/inner_lut_reg.txt",tr.case_path,tr.packet_idx),data_queue);
     foreach(data_queue[ii]) begin
         @(vif.drvcb);
         vif.drvcb.paddr_riu     <= 'h4000+4*ii;
         vif.drvcb.pwdata_riu    <= data_queue[ii];
         vif.drvcb.psel_riu      <= 1'b1;
         vif.drvcb.penable_riu   <= 1'b1;
         vif.drvcb.pwrite_riu    <= 1'b1;
         @(vif.drvcb);
         vif.drvcb.paddr_riu     <= 'h0;
         vif.drvcb.pwdata_riu    <= 'h0;
         vif.drvcb.psel_riu      <= 'h0;
         vif.drvcb.penable_riu   <= 'h0;
         vif.drvcb.pwrite_riu    <= 'h0;
     end
endtask : drive_dpd_lut // }}}

task dfe_tx_driver::drive_dfe_din_ch0(input mdm2riu_tx_sig_bw, wifi_tv_dir_trans tr); //{{{
     bit [31:0] data_queue[2][$];
     
     read_2_col_tv($sformatf("%0s/pkt%0d/RIU_DFE/dfe_tx_din_ch_0.txt",tr.case_path,tr.packet_idx),data_queue);
     foreach(data_queue[0][ii])begin
         repeat(5) @(vif.drvcb);
         if(mdm2riu_tx_sig_bw == 0)begin
             repeat(6) @(vif.drvcb);
         end
         vif.drvcb.mdm2riu_tx0_re         <= data_queue[1][ii];
         vif.drvcb.mdm2riu_tx0_im         <= data_queue[0][ii];
         vif.drvcb.mdm2riu_tx0_vld        <= 1'b1;
         if(ii == data_queue[0].size()-1) vif.drvcb.mdm2riu_tx_vld_end     <= 1'b1;
         @(vif.drvcb);
         vif.drvcb.mdm2riu_tx0_vld        <= 1'b0;
         vif.drvcb.mdm2riu_tx_vld_end     <= 1'b0;
     end
endtask : drive_dfe_din_ch0 // }}}

task dfe_tx_driver::drive_dfe_din_ch1(input mdm2riu_tx_sig_bw, wifi_tv_dir_trans tr); //{{{
     bit [31:0] data_queue[2][$];
     
     read_2_col_tv($sformatf("%0s/pkt%0d/RIU_DFE/dfe_tx_din_ch_1.txt",tr.case_path,tr.packet_idx),data_queue);
     foreach(data_queue[0][ii])begin
         repeat(5) @(vif.drvcb);
         if(mdm2riu_tx_sig_bw == 0)begin
             repeat(6) @(vif.drvcb);
         end
         vif.drvcb.mdm2riu_tx1_re         <= data_queue[1][ii];
         vif.drvcb.mdm2riu_tx1_im         <= data_queue[0][ii];
         vif.drvcb.mdm2riu_tx1_vld        <= 1'b1;
         @(vif.drvcb);
         vif.drvcb.mdm2riu_tx1_vld        <= 1'b0;
     end
endtask : drive_dfe_din_ch1 // }}}

task dfe_tx_driver::drive_rf_cali_lut(wifi_tv_dir_trans tr); //{{{
     bit [31:0] data_queue[$];
     
     tv_proc.read_single_col_tv($sformatf("%0s/pkt%0d/RIU_DFE/RF_Comp/Tx_dfe_comp_coef_cfg.txt",tr.case_path,tr.packet_idx),data_queue);
     foreach(data_queue[ii]) begin
         //@(vif.drvcb iff vif.drvcb.pready_riu == 'b1);
         @(vif.drvcb);
         vif.drvcb.paddr_riu     <= 'h1000+4*ii;
         vif.drvcb.pwdata_riu    <= data_queue[ii];
         vif.drvcb.psel_riu      <= 1'b1;
         vif.drvcb.penable_riu   <= 1'b1;
         vif.drvcb.pwrite_riu    <= 1'b1;
         @(vif.drvcb);
         vif.drvcb.paddr_riu     <= 'h0;
         vif.drvcb.pwdata_riu    <= 'h0;
         vif.drvcb.psel_riu      <= 'h0;
         vif.drvcb.penable_riu   <= 'h0;
         vif.drvcb.pwrite_riu    <= 'h0;
     end
     @(vif.drvcb);
     vif.drvcb.paddr_riu     <= 'h3c;
     vif.drvcb.pwdata_riu    <= 'h0;
     vif.drvcb.psel_riu      <= 1'b1;
     vif.drvcb.penable_riu   <= 1'b1;
     vif.drvcb.pwrite_riu    <= 1'b1;
     @(vif.drvcb);
     vif.drvcb.paddr_riu     <= 'h0;
     vif.drvcb.pwdata_riu    <= 'h0;
     vif.drvcb.psel_riu      <= 'h0;
     vif.drvcb.penable_riu   <= 'h0;
     vif.drvcb.pwrite_riu    <= 'h0;     
endtask : drive_rf_cali_lut // }}}

function void dfe_tx_driver::read_2_col_tv(input string file_name, ref bit [31:0] col_q[2][$]);
   bit [31:0]  col_data[2];
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

task dfe_tx_driver::timeout_mon(); //{{{
    fork
        forever begin
            wait(cfg.drv_busy == 1);
            fork
                begin
                    #(cfg.drv_timeout_ns*1ns);
                    if(cfg.timeout_en)
                        `uvm_fatal(get_full_name(), $sformatf("trans sending started before, but no further actions for %0d ns", cfg.drv_timeout_ns))
                end
                wait(cfg.drv_busy == 0);
            join_any
            disable fork;
        end
    join_none
endtask : timeout_mon //}}}

task dfe_tx_driver::dynamic_rst(uvm_phase phase); //{{{
    wait(vif.rst);
    wait(!vif.rst);
    //reset interface and properties in driver
    reset_all(phase);
endtask : dynamic_rst //}}}

task dfe_tx_driver::reset_all(uvm_phase phase); //{{{
    reset_vif_sigs();
endtask : reset_all //}}}

function void dfe_tx_driver::report_phase(uvm_phase phase); //{{{
    `uvm_info($sformatf("%25s", get_full_name()), $sformatf("\nReport: dfe_tx driver sent %0d transfers", num_sent), UVM_LOW)
endfunction : report_phase //}}}
`endif
