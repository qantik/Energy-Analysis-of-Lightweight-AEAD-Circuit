power -gate_level on
power mut
power -enable
run 1 s
power -disable
power -report  aead_timing.saif 1e-09 mut
quit

