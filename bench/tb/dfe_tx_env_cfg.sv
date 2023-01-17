// =========================================================================== //
// Author       : fengyangwu - ASR
// Last modified: 2020-07-09 9:49
// Filename     : dfe_tx_env_cfg.sv
// Description  : 
// =========================================================================== //
`ifndef DFE_TX_ENV_CFG_SV
`define DFE_TX_ENV_CFG_SV

class dfe_tx_env_cfg extends uvm_object;

   WIFI_SCB_STREAM_ID_T stream_id[200];

   uvm_active_passive_enum is_active = UVM_ACTIVE;

   bit    checks_enable        = 1;
   bit    coverage_enable      = 1;
   bit    drv_timeout_chk      = 1;
   int    drv_timeout_ns       = 1000_0000;
   bit    drv_busy             = 0;  //for end of test objection
   bit    mon_busy             = 0;  //for end of test objection
   bit    transformer_enable   = 0;

   bit    timeout_en =1;


   bit                    dfe_tx_mon_en;
   bit                    scb_en;
   bit                    ref_model_en;
   bit                    scb_conn_en;

   `uvm_object_utils_begin(dfe_tx_env_cfg)
       `uvm_field_enum(uvm_active_passive_enum, is_active, UVM_DEFAULT)
       `uvm_field_int(coverage_enable, UVM_DEFAULT)
       `uvm_field_int(drv_timeout_chk, UVM_DEFAULT)
       `uvm_field_int(drv_timeout_ns, UVM_DEFAULT)
       `uvm_field_int(drv_busy, UVM_DEFAULT)
       `uvm_field_int(mon_busy, UVM_DEFAULT)
       `uvm_field_int(dfe_tx_mon_en, UVM_DEFAULT)
       `uvm_field_int(scb_en, UVM_DEFAULT)
       `uvm_field_int(ref_model_en, UVM_DEFAULT)
       `uvm_field_int(scb_conn_en, UVM_DEFAULT)
   `uvm_object_utils_end                   

   //new
   extern function new(string name = "dfe_tx_env_cfg");
   extern virtual function void mode_set();
   
endclass: dfe_tx_env_cfg

function dfe_tx_env_cfg::new(string name = "dfe_tx_env_cfg"); //{{{
      super.new(name);
endfunction: new //}}}

function void dfe_tx_env_cfg::mode_set(); //{{{
     is_active = UVM_ACTIVE;
     dfe_tx_mon_en  = 1;
     scb_en         = 1;
     ref_model_en   = 1;
     scb_conn_en    = 1;
     stream_id[0]   = DFE_TX_CFR_DIN_CH0_CHK;
     stream_id[1]   = DFE_TX_CFR_DIN_CH1_CHK;
     stream_id[2]   = DFE_TX_CFR_QOUT_CH0_CHK;
     stream_id[3]   = DFE_TX_CFR_QOUT_CH1_CHK;
     stream_id[4]   = DFE_TX_NCO4_DIN_CH0_CHK;
     stream_id[5]   = DFE_TX_NCO4_DIN_CH1_CHK;
     stream_id[6]   = DFE_TX_DGAIN_QOUT_CH0_CHK;
     stream_id[7]   = DFE_TX_DGAIN_QOUT_CH1_CHK;
     stream_id[8]   = DFE_TX_DPD_QOUT_CH0_CHK;
     stream_id[9]   = DFE_TX_DPD_QOUT_CH1_CHK;
     stream_id[10]  = DFE_TX_IQCOMP_QOUT_CH0_CHK;
     stream_id[11]  = DFE_TX_IQCOMP_QOUT_CH1_CHK;
     stream_id[12]  = DFE_TX_UP3FIR2_QOUT_CH0_CHK;
     stream_id[13]  = DFE_TX_UP3FIR2_QOUT_CH1_CHK;
     stream_id[14]  = DFE_TX_UP2FIR3_QOUT_CH0_CHK;
     stream_id[15]  = DFE_TX_UP2FIR3_QOUT_CH1_CHK;
     stream_id[16]  = DFE_TX_LOFT_QOUT_CH0_CHK;
     stream_id[17]  = DFE_TX_LOFT_QOUT_CH1_CHK;
     stream_id[18]  = DFE_TX_IQSWAP_QOUT_CH0_CHK;
     stream_id[19]  = DFE_TX_IQSWAP_QOUT_CH1_CHK;
endfunction: mode_set //}}}

`endif
