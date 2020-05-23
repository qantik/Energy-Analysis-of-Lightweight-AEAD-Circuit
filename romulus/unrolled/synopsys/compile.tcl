sh rm -rf WORK/*
remove_design -all

define_design_lib WORK -path ./WORK
analyze -library WORK -format vhdl {
  ./../src/core/delayer.vhd        
  ./../src/core/sbox.vhd
  ./../src/core/shiftrows.vhd
  ./../src/core/mixcolumns.vhd
  ./../src/core/permutation.vhd
  ./../src/core/keymixing.vhd
  ./../src/core/roundfunction.vhd
  ./../src/core/keyexpansion.vhd
  ./../src/core/controller.vhd
  ./../src/core/skinny.vhd
  ./../src/g_mul.vhd
  ./../src/rho.vhd
  ./../src/lfsr56.vhd
  ./../src/endian_change.vhd
  ./../src/ff.vhd
  ./../src/cg_xor.vhd
  ./../src/cg_reg.vhd
  ./../src/treg.vhd
  ./../src/aead_controller.vhd
  ./../src/aead.vhd
}

#elaborate delayer -architecture parallel -library WORK
#    set_min_delay 1.5 -from clk -to dclk
#    compile -exact_map
#    set_dont_touch [find design delayer]

elaborate cg_xor -architecture behaviour -library WORK
    compile
    set_dont_touch [find design cg_xor]

elaborate aead -architecture behaviour -library WORK
create_clock -name "clk" -period 200 -waveform { 0 100 } { clk }
create_clock -name "iclk" -period 200 -waveform { 0 100 } { iclk }

compile -exact_map -area_effort high
#compile_ultra
uplevel #0 { report_timing -path full > ./timing.txt}
uplevel #0 { report_area -hierarchy > ./area.txt}

write -hierarchy -format verilog -output ./aead-syn.v
write_sdf ./aead-syn.sdf
