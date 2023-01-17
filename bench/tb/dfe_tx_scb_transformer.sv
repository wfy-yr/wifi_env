class dfe_tx_scb_transformer extends asr_base_scb_transformer #(wifi_fifo_trans, asr_base_scb_item);
    `uvm_component_utils(dfe_tx_scb_transformer)

    function new (string name = "dfe_tx_scb_transformer", uvm_component parent);
        super.new(name, parent);
    endfunction : new

    //transaction -> scb item
    extern virtual function void T2SCBT(wifi_fifo_trans in_pkt, output asr_base_scb_item scb_item[]);
endclass: dfe_tx_scb_transformer

function void dfe_tx_scb_transformer::T2SCBT(wifi_fifo_trans in_pkt, output asr_base_scb_item scb_item[]);
    //TODO: transform wifi_fifo_trans -> asr_base_scb_item 
    //scb_item: stream_id, addr, data, rw_type
    //scb_item=new[1];
    //scb_item[0]=new("scb_item");
    //scb_item[0].addr=in_pkt.addr;
    //scb_item[0].rw_type = asr_base_scb_item::READ; 
    //scb_item[0].data = in_pkt.rdata; 
endfunction
