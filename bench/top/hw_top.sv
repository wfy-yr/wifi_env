// =========================================================================== //
// Author       : fengyangwu - ASR
// Last modified: 2020-07-09 15:14
// Filename     : hw_top.sv
// Description  : 
// =========================================================================== //
`ifndef HW_TOP_V
`define HW_TOP_V

module hw_top;

    wphy_dfe_tx_wrapper dut();

    `DFE_TX_TOP_IF_RTL(dfe_tx_top_if, dut, 1)
endmodule

`endif
