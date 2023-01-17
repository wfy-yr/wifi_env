`ifndef DFE_TX_COVERAGE__SV
`define DFE_TX_COVERAGE__SV 

class dfe_tx_coverage;
    
    virtual dfe_tx_top_intf  vif;
    //`include "covgrp_def.sv"

    function new(string name);
    //`include "covgrp_new.sv"
    endfunction

    virtual function void sample();
    //`include "covgrp_sample.sv"
    endfunction
endclass

`endif
