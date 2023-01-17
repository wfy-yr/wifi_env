+define+UVM_PACKER_MAX_BYTES=1500000 
+define+UVM_DISABLE_AUTO_ITEM_RECORDING -timescale=1ns/1fs 
+define+SVT_UVM_TECHNOLOGY
//+define+SVT_APB_PWDATA_WIDTH=32
//+define+SVT_APB_DISCONNECT_TOP_LEVEL_APB_IF_SIGNALS
//+define+SVT_AHB_DISABLE_IMPLICIT_BUS_CONNECTION
+define+UVM_NO_DPI
+define+UDLY=#0
+define+EDA_SIM

//include
+incdir+/tools/Synopsys/verdi_vK-2015.09-SP2/etc/uvm-1.1/src
//+incdir+/home/pingli/vip_2018/ahb/include/sverilog
//+incdir+/home/pingli/vip_2018/apb/include/sverilog
//+incdir+/home/pingli/vip_2018/ahb/src/sverilog/vcs
//+incdir+/home/pingli/vip_2018/apb/src/sverilog/vcs

//uvm_pkg
/tools/Synopsys/verdi_vK-2015.09-SP2/etc/uvm-1.1/src/uvm.sv
///home/pingli/vip_2018/ahb/include/sverilog/svt_ahb.uvm.pkg
///home/pingli/vip_2018/apb/include/sverilog/svt_apb.uvm.pkg
///home/pingli/vip_2018/apb/include/sverilog/svt_apb_defines.svi
///home/pingli/vip_2018/apb/src/sverilog/vcs/svt_apb_system_configuration.sv

//=========================rtl====================================================
//-f $PROJ_PATH/flist/rtl/srclist.common
//-f $PROJ_PATH/flist/lib/srclist.mem
//-f $PROJ_PATH/flist/lib/srclist.model.release
//-v /memgen/guoweishi/tsmc_tsmc22ulp/sc2_z2/sc2.0730.v02/VERILOG/uhdsr1psh208x24m2wp1b_tt0p9v85c.v
-f $PROJ_PATH/flist/lib/srclist.tsmc 
-f $PROJ_PATH/flist/lib/srclist.std_lib
-f $PROJ_PATH/sim/verification/WPHY_IPs/WPHY4x/WPHY40/sim/wlan_phy/dfe_tx/src/wphy_dfe_tx_wrapper.f

//======================= top env path ===================================
+incdir+$PROJ_PATH/sim/verification/WPHY_IPs/WPHY4x/WPHY40/sim/wlan_phy/dfe_tx/bench/bin
+incdir+$PROJ_PATH/sim/verification/WPHY_IPs/WPHY4x/WPHY40/sim/wlan_phy/dfe_tx/bench/tb/
+incdir+$PROJ_PATH/sim/verification/WPHY_IPs/WPHY4x/WPHY40/sim/wlan_phy/dfe_tx/bench/top
+incdir+$PROJ_PATH/sim/verification/WPHY_IPs/WPHY4x/WPHY40/sim/wlan_phy/dfe_tx/bench/test
+incdir+$PROJ_PATH/sim/verification/WPHY_IPs/WPHY4x/WPHY40/sim/wlan_phy/dfe_tx/bench/env_common

//======================  commom   ========================================
+incdir+$PROJ_PATH/sim/verification/WPHY_IPs/common/asr_uvm
+incdir+$PROJ_PATH/sim/verification/WPHY_IPs/common/asr_uvm/tv_proc
+incdir+$PROJ_PATH/sim/verification/WPHY_IPs/common/env_common

$PROJ_PATH/sim/verification/WPHY_IPs/WPHY4x/WPHY40/sim/wlan_phy/dfe_tx/bench/top/tb_top.sv
$PROJ_PATH/sim/verification/WPHY_IPs/WPHY4x/WPHY40/sim/wlan_phy/dfe_tx/bench/top/hw_top.sv
