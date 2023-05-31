CASE_PATH := /digital/work_area/fengyangwu/wifi4_tx/tx_link/${CASE_NAME}/${CASE_ID}/output/TV
CASE_NAME ?= soc_case_tx_0423
CASE_NAME_OFDM ?= case_finished_r6588_230511_183639_LM
CASE_ID_OFDM := ${shell ls /digital/work_area/fengyangwu/wifi4_tx/tx_link/${CASE_NAME_OFDM}}
CASE_ID_OFDM := ${basename ${patsubst /digital/work_area/fengyangwu/wifi4_tx/tx_link/${CASE_NAME_OFDM}/%,%,${CASE_ID_OFDM}}}
TVLIST_OFDM := ${foreach n,${CASE_ID_OFDM},/digital/work_area/fengyangwu/wifi4_tx/tx_link/${CASE_NAME_OFDM}/${n}/output/TV}
CASE_NAME_DSSS ?= soc_case_dsss_tx_20230512_2
CASE_ID_DSSS := ${shell ls /digital/work_area/fengyangwu/wifi4_tx/dsss/${CASE_NAME_DSSS}}
CASE_ID_DSSS := ${basename ${patsubst /digital/work_area/fengyangwu/wifi4_tx/dsss/${CASE_NAME_DSSS}/%,%,${CASE_ID_DSSS}}}
TVLIST_DSSS := ${foreach n,${CASE_ID_DSSS},/digital/work_area/fengyangwu/wifi4_tx/dsss/${CASE_NAME_DSSS}/${n}/output/TV}
CASE_NAME_LOOPBACK ?= case_finished_r6538_230509_155126
CASE_ID_LOOPBACK := ${shell ls /digital/work_area/fengyangwu/wifi4_tx/loopback/${CASE_NAME_LOOPBACK}}
CASE_ID_LOOPBACK := ${basename ${patsubst /digital/work_area/fengyangwu/wifi4_tx/loopback/${CASE_NAME_LOOPBACK}/%,%,${CASE_ID_LOOPBACK}}}
TVLIST_LOOPBACK := ${foreach n,${CASE_ID_LOOPBACK},/digital/work_area/fengyangwu/wifi4_tx/loopback/${CASE_NAME_LOOPBACK}/${n}/output/TV}
SEED ?= 123
CASE_NUM ?= 1

verdi:
	psv wphy_tx_top -sgq -mix -v &
direct:
	psv wphy_tx_top -c -x -full -t tx_path_top_direct_tc -fsdb -sgq -seed=${SEED} -mix -define VSEQ=wphy_tx_top_direct_vseq -define CASE_NUM=${CASE_NUM} -vcsplus TV_PATH=${CASE_PATH}
tx_link:
	psv wphy_tx_top -c -x -full -t tx_link_direct_tc -fsdb -sgq -seed=${SEED} -mix -define VSEQ=wphy_tx_top_direct_vseq -define CASE_NUM=${CASE_NUM} -vcsplus TV_PATH=${CASE_PATH}
loopback:
	psv wphy_tx_top -c -x -full -t trx_loop_direct_tc -fsdb -sgq -seed=${SEED} -mix -define VSEQ=trx_phy_loop_direct_vseq -define CASE_NUM=${CASE_NUM} -vcsplus TV_PATH=/digital/work_area/fengyangwu/wifi4_tx/loopback/${CASE_NAME}/${CASE_ID}/output/TV
dsss:
	psv wphy_tx_top -c -x -full -t tx_11b_direct_tc -fsdb -sgq -seed=${SEED} -mix -define VSEQ=wphy_tx_top_direct_vseq -define CASE_NUM=${CASE_NUM} -vcsplus TV_PATH=/digital/work_area/fengyangwu/wifi4_tx/dsss/${CASE_NAME}/${CASE_ID}/output/TV
soc_dsss_regr:
	psv wphy_tx_top -c -x -full -t tx_11b_direct_tc -sgq -seed=1 -mix -define VSEQ=wphy_tx_top_direct_vseq -define CASE_NUM=${CASE_NUM} -tvlist="${TVLIST_DSSS}"
soc_ofdm_regr:
	psv wphy_tx_top -c -x -full -coverage -t tx_link_direct_tc -sgq -seed=1 -mix -define VSEQ=wphy_tx_top_direct_vseq -define CASE_NUM=${CASE_NUM} -tvlist="${TVLIST_OFDM}"
loopback_regr:
	psv wphy_tx_top -c -x -full -t trx_loop_direct_tc -sgq -seed=1 -mix -define VSEQ=trx_phy_loop_direct_vseq -define CASE_NUM=${CASE_NUM} -tvlist="${TVLIST_LOOPBACK}"
soc_regr:
	make soc_ofdm_regr
	make soc_dsss_regr
