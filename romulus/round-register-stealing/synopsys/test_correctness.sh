#!/bin/tcsh
setenv SNPSLMD_LICENSE_FILE 27000@ielsrv01.epfl.ch

setenv VCS_HOME /softs/synopsys/vcs-mx/N-2017.12-SP2-1

set path= ( $path $VCS_HOME/bin )

vlogan -nc -full64 /dkits/tsmc/90nm/cmn90lp/stclib/9-track/tcbn90lphp/Front_End/verilog/tcbn90lphp_150j/tcbn90lphp.v

#vlogan -full64 /cell_libs/cmos090_50a/CORE90GPSVT_SNPS-AVT_2.1/VERILOG_LD/CORE90GPSVT.v
#vlogan -full64 /cell_libs/cmos090_50a/CORE90GPHVT_SNPS-AVT_2.1.a/VERILOG_LD/CORE90GPHVT.v
vlogan -nc -full64 aead-syn.v
vhdlan -nc -full64 ./../test/romulus_tb.vhd
vcs -nc -full64 -debug -sdf typ:romulus_tb/mut:aead-syn.sdf romulus_tb +neg_tchk +sdfverbose
./simv -nc -ucli -include ../synopsys/saif.cmd
dve -full64 -toolexe simv
