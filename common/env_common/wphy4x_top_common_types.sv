typedef enum {
    WLAN_PHY_TOP_STREAM_NONE = 0,
    DFE_TX_CFR_DIN_CH0_CHK = 10,
    DFE_TX_CFR_DIN_CH1_CHK = 11,
    DFE_TX_CFR_QOUT_CH0_CHK = 12,
    DFE_TX_CFR_QOUT_CH1_CHK = 13,
    DFE_TX_NCO4_DIN_CH0_CHK = 14,
    DFE_TX_NCO4_DIN_CH1_CHK = 15,
    DFE_TX_DGAIN_QOUT_CH0_CHK = 16,
    DFE_TX_DGAIN_QOUT_CH1_CHK = 17,
    DFE_TX_DPD_QOUT_CH0_CHK = 18,
    DFE_TX_DPD_QOUT_CH1_CHK = 19,
    DFE_TX_IQCOMP_QOUT_CH0_CHK = 20,
    DFE_TX_IQCOMP_QOUT_CH1_CHK = 21,
    DFE_TX_UP3FIR2_QOUT_CH0_CHK = 22,
    DFE_TX_UP3FIR2_QOUT_CH1_CHK = 23,
    DFE_TX_UP2FIR3_QOUT_CH0_CHK = 24,
    DFE_TX_UP2FIR3_QOUT_CH1_CHK = 25,
    DFE_TX_LOFT_QOUT_CH0_CHK = 26,
    DFE_TX_LOFT_QOUT_CH1_CHK = 27,
    DFE_TX_IQSWAP_QOUT_CH0_CHK = 28,
    DFE_TX_IQSWAP_QOUT_CH1_CHK = 29,
    WLAN_PHY_TOP_VAR = 1000,
    WLAN_PHY_TOP_VAR_END = 2000
} WIFI_SCB_STREAM_ID_T;

//basic SCB item
class wifi_base_trans extends uvm_sequence_item;
    WIFI_SCB_STREAM_ID_T stream_id;
    `uvm_object_utils_begin(wifi_base_trans)
        `uvm_field_enum(WIFI_SCB_STREAM_ID_T, stream_id, UVM_ALL_ON | UVM_NOCOMPARE | UVM_NOPACK)
    `uvm_object_utils_end
    function new(string name="wifi_base_trans");
        super.new(name);
    endfunction : new
endclass : wifi_base_trans

class wifi_fifo_trans extends wifi_base_trans;
    rand int delay;
    rand int packet_idx;
    rand bit chk_en;
    `uvm_object_utils_begin(wifi_fifo_trans)
        `uvm_field_int(delay, UVM_ALL_ON | UVM_NOCOMPARE | UVM_NOPACK)
        `uvm_field_int(chk_en, UVM_ALL_ON | UVM_NOCOMPARE | UVM_NOPACK)
        `uvm_field_int(packet_idx, UVM_ALL_ON | UVM_NOPACK)
    `uvm_object_utils_end
    function new(string name="wifi_fifo_trans");
        super.new(name);
    endfunction : new

    constraint delay_cons {delay inside {[1:10]};}
endclass : wifi_fifo_trans

class dfe_tx_iq_trans extends wifi_fifo_trans;
    rand bit [11:0] i;
    rand bit [11:0] q;
    `uvm_object_utils_begin(dfe_tx_iq_trans)
        if(chk_en == 1)begin
            `uvm_field_int(i, UVM_DEFAULT)
            `uvm_field_int(q, UVM_DEFAULT)
        end else begin
            `uvm_field_int(i, UVM_DEFAULT | UVM_NOCOMPARE)
            `uvm_field_int(q, UVM_DEFAULT | UVM_NOCOMPARE)
        end
    `uvm_object_utils_end
    function new(string name="dfe_tx_iq_trans");
        super.new(name);
    endfunction : new
endclass : dfe_tx_iq_trans

class default_packer_t extends uvm_packer;
    function new();
        super.new();
        super.big_endian = 0;
    endfunction : new
endclass : default_packer_t

static default_packer_t default_packer = new;

task traverse_stream_name(output int unsigned stream_id[$], output string name[$]);
    WIFI_SCB_STREAM_ID_T id = id.first();

    do begin
        stream_id.push_back(id);
        id = id.next();
    end while(id != id.first());

    for(int unsigned ii=WLAN_PHY_TOP_VAR; ii<=WLAN_PHY_TOP_VAR_END; ii++) begin
        stream_id.push_back(ii);
    end

    stream_id = stream_id.unique();

    foreach(stream_id[ii]) begin
        name.push_back(get_stream_name(stream_id[ii]));
    end
endtask: traverse_stream_name 

function string get_stream_name(WIFI_SCB_STREAM_ID_T stream_id);
    if(stream_id >= WLAN_PHY_TOP_VAR  && stream_id <= WLAN_PHY_TOP_VAR_END) begin
        return ($sformatf("WLAN_PHY_TOP_VAR%0d", stream_id-WLAN_PHY_TOP_VAR));
    end
    else begin
        return stream_id.name();
    end
endfunction : get_stream_name 

class wifi_tv_dir_trans extends asr_tv_dir_trans;
    rand int packet_idx;

    `ifdef USING_UVM_METH
    `uvm_object_utils_begin(wifi_tv_dir_trans)
        `uvm_field_int(packet_idx, UVM_ALL_ON + UVM_DEC)
    `uvm_object_utils_end
    `endif

    function new(string name="wifi_tv_dir_trans");
        super.new(name);
    endfunction : new

    virtual function string get_dir();//{{{
        string s = $sformatf("%s/", case_path);
        return {s,$psprintf("pkt%0d",packet_idx)};
    endfunction//}}}
endclass : wifi_tv_dir_trans

class wifi_tv_proc extends asr_tv_proc;
    
    function new(input string name="wifi_tv_proc");
        super.new(name);
    endfunction
    
    virtual function bit parse_wifi_case_dir(ref wifi_tv_dir_trans dir_q[$],input int tot_pkt=10);
        int _pkt_idx;
        if(sg_is_dir_legal(get_case_path())) begin
            for (_pkt_idx = 0; _pkt_idx < tot_pkt; _pkt_idx++) begin
                wifi_tv_dir_trans trans = new("wifi_tv_trans");
                trans.case_path  = get_case_path();
                trans.packet_idx = _pkt_idx;
                if(sg_is_dir_legal(trans.get_dir()))
                    dir_q.push_back(trans);
            end
            return (dir_q.size() > 0);
        end
        return 1'b0;
    endfunction
endclass
