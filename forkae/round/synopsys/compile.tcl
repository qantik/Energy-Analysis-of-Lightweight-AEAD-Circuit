sh rm -rf WORK/*
remove_design -all

define_design_lib WORK -path ./WORK
analyze -library WORK -format vhdl {
  ./../src/core-generic/cg_xor.vhd
  ./../src/core-generic/ff.vhd
  ./../src/core-generic/rff.vhd
  ./../src/core-generic/cg_reg.vhd
  ./../src/core-generic/treg.vhd
  ./../src/core-generic/mux.vhd
  ./../src/core-generic/branchadd.vhd
  ./../src/core-generic/round_counter.vhd
  ./../src/core-generic/sbox.vhd
  ./../src/core-generic/shiftrows.vhd
  ./../src/core-generic/mixcolumns.vhd
  ./../src/core-generic/permutation.vhd
  ./../src/core-generic/keymixing.vhd
  ./../src/core-generic/controller.vhd
  ./../src/core-generic/keyexpansion.vhd
  ./../src/core-generic/roundfunction.vhd
  ./../src/core-generic/forkskinny.vhd
  ./../src/cg_xreg.vhd
  ./../src/xreg.vhd
  ./../src/aead_controller.vhd
  ./../src/aead.vhd
}

elaborate cg_xor -architecture behaviour -library WORK
    compile
    set_dont_touch [find design cg_xor]


elaborate aead -architecture behaviour -library WORK
create_clock -name "clk" -period 100 -waveform { 0 50 } { clk }

#compile -exact_map -area_effort high
compile_ultra
uplevel #0 { report_timing -path full > ./timing.txt}
uplevel #0 { report_area -hierarchy > ./area.txt}

write -hierarchy -format verilog -output ./aead-syn.v
write_sdf ./aead-syn.sdf
