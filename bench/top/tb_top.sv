// =========================================================================== //
// Author       : fengyangwu - ASR
// Last modified: 2020-07-09 15:14
// Filename     : tb_top.sv
// Description  : 
// =========================================================================== //
`ifndef TB_TOP_SV
`define TB_TOP_SV

`timescale 1ns/1ps

//common defines
`include "uvm_macros.svh" 

//top env defines
`include "dfe_tx_tb_top_define.svi"
`include "dfe_tx_intf_define.svi"
`include "dfe_tx_map_define.svi"

//common pkg
`include "asr_common_pkg.svi"
`include "asr_tv_proc_pkg.svi"
`include "wphy4x_env_common_pkg.svi"

//top env pkg
`include "dfe_tx_env_pkg.svi"

module tb_top;
    import uvm_pkg::*;

    import asr_common_pkg::*;
    import asr_tv_proc_pkg::*;
    import wphy4x_env_common_pkg::*;
    import dfe_tx_env_pkg::*;

    `include "dfe_tx_test_include.svi"

    `DFE_TX_DUT_CLK_RST_SRC(`HWTOP_HIER);

    
    `DFE_TX_FSDB_DUMP_MACRO;

    initial begin
       `uvm_info("tb_top", $sformatf("tb_top interface setup begin"),UVM_LOW);         

       `DFE_TX_TOP_IF_TB(`HWTOP_HIER.dfe_tx_top_if, "uvm_test_top*")

       uvm_config_db#(bit)::set(uvm_root::get(), "uvm_test_top*", "no_activity_check", 1'b0);

       `uvm_info("tb_top", $sformatf("tb_top interface setup end"),UVM_LOW);         

       $timeformat(-9, 1, "ns", 10);
       run_test();
    end

endmodule: tb_top

`endif
