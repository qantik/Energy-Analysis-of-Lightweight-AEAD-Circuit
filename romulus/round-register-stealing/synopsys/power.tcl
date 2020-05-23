reset_switching_activity

read_saif -verbose -input aead_timing.saif -instance STAT_AEAD/MUT -unit ns

report_power > powercon_lp.txt

report_power -hier > powerhier_lp.txt

#exit
