library ieee;
use ieee.std_logic_1164.all;

entity aead is
    generic (r : integer := 1);
    port (clk   : in std_logic;
          reset : in std_logic; -- active low

          key                            : in std_logic_vector(127 downto 0);
          nonce1, nonce2, nonce3, nonce4 : in std_logic_vector(127 downto 0);

          -- A data block is either associated data or plaintext.
          -- last_block indicates whether the current ad or plaintext
          -- block is the last one with last_partial indicating whether
          -- said block is only partially filled.
          data1, data2, data3, data4 : in std_logic_vector(127 downto 0);
          last_block                 : in std_logic;
          last_partial               : in std_logic;

          empty_ad     : in std_logic; -- Constant, set at the beginning.
          empty_msg    : in std_logic; -- Constant, set at the beginning.

          ready_block  : out std_logic; -- Expecting new block at next rising edge.
          ready_full   : out std_logic; -- AEAD finished.

          -- Indication signals that tell whether current value on either
          -- the ciphertext or tag output pins is valid.
          cipher_ready : out std_logic;
          tag_ready    : out std_logic;

          ciphertext1, ciphertext2,ciphertext3, ciphertext4 : out std_logic_vector(127 downto 0);
          tag1, tag2, tag3, tag4                            : out std_logic_vector(127 downto 0));
end;

architecture structural of aead is

    -- Block cipher signals.
    constant b   : integer                      := 128;
    constant c   : integer                      := 6;
    constant cst : std_logic_vector(5 downto 0) := "000001";

    signal round_cst                                           : std_logic_vector(c-1 downto 0);
    signal round_key                                           : std_logic_vector(b-1 downto 0);
    signal round_state1,round_state2,round_state3,round_state4 : std_logic_vector(b-1 downto 0);

    signal csts                               : std_logic_vector((r+1)*c-1 downto 0);
    signal keys                               : std_logic_vector((r+1)*b-1 downto 0);
    signal states1, states2, states3, states4 : std_logic_vector((r+1)*b-1 downto 0);

    -- AEAD signals.
    signal core_load, core_gfunc, core_done                    : std_logic;
    signal core_output1,core_output2,core_output3,core_output4 : std_logic_vector(127 downto 0);
    signal delta_load, delta_save                              : std_logic;
    signal delta_mode                                          : std_logic_vector(3 downto 0);
    signal delta_in1, delta_out1, delta_state1                 : std_logic_vector(63 downto 0);
    signal delta_in2, delta_out2, delta_state2                 : std_logic_vector(63 downto 0);
    signal delta_in3, delta_out3, delta_state3                 : std_logic_vector(63 downto 0);
    signal delta_in4, delta_out4, delta_state4                 : std_logic_vector(63 downto 0);
    signal x1, x2, x3, x4                                      : std_logic_vector(127 downto 0);
    signal gfunc_out1,gfunc_out2,gfunc_out3,gfunc_out4         : std_logic_vector(127 downto 0);
    signal state_input1,state_input2,state_input3,state_input4 : std_logic_vector(127 downto 0);

    signal core_reset : std_logic;

begin

    cst_reg : entity work.reg
        generic map (size => c)
        port map (clk, core_reset, csts((r+1)*c-1 downto r*c), cst, csts(c-1 downto 0));
    key_reg : entity work.reg
        generic map (size => b)
        port map (clk, core_reset, keys((r+1)*b-1 downto r*b), key, keys(b-1 downto 0));

    state1_reg : entity work.reg
        generic map (size => b)
        port map (clk, core_load, state_input1, nonce1, states1(b-1 downto 0));
    state2_reg : entity work.reg
        generic map (size => b)
        port map (clk, core_load, state_input2, nonce2, states2(b-1 downto 0));
    state3_reg : entity work.reg
        generic map (size => b)
        port map (clk, core_load, state_input3, nonce3, states3(b-1 downto 0));
    state4_reg : entity work.reg
        generic map (size => b)
        port map (clk, core_load, state_input4, nonce4, states4(b-1 downto 0));

    input0 : if (40 mod r) = 0 generate
        state_input1 <= states1((r+1)*b-1 downto r*b);
        state_input2 <= states2((r+1)*b-1 downto r*b);
        state_input3 <= states3((r+1)*b-1 downto r*b);
        state_input4 <= states4((r+1)*b-1 downto r*b);
    end generate;
    --input1 : if (40 mod r) /= 0 generate
    --    muxr3 : entity work.muxr3
    --       port map(states((r+1)*b-1 downto r*b),
    --                states(((40 mod r)+1)*b-1 downto (40 mod r)*b), core_done, state_input); 
    --    --state_input <= states((r+1)*b-1 downto r*b) when core_done = '0' else
    --    --               states(((40 mod r)+1)*b-1 downto (40 mod r)*b);
    --end generate;

    ke : entity work.keyexpansion
        port map (round_key, keys(2*b-1 downto b));
    cl : entity work.roundconstant
        port map (round_cst, csts(2*c-1 downto c));
    rf : entity work.partial
        port map (clk, round_cst, round_key,
	          round_state1, round_state2, round_state3, round_state4,
		  states1(2*b-1 downto b), states2(2*b-1 downto b), states3(2*b-1 downto b),
	          states4(2*b-1 downto b));
    --rf1 : entity work.roundfunction
    --    port map (round_cst, round_key, round_state, states(2*b-1 downto b));

    --rounds : for i in 1 to r-1 generate
    --    ke : entity work.keyexpansion
    --        port map (keys((i+1)*b-1 downto i*b), keys((i+2)*b-1 downto (i+1)*b));
    --    cl : entity work.roundconstant
    --        port map (csts((i+1)*c-1 downto i*c), csts((i+2)*c-1 downto (i+1)*c));
    --    rf : entity work.roundfunction
    --        port map (csts((i+1)*c-1 downto (i+0)*c), keys((i+1)*b-1 downto i*b),
    --                  states((i+1)*b-1 downto i*b), states((i+2)*b-1 downto (i+1)*b));
    --end generate;

    out0 : if (40 mod r) = 0 generate
        core_done   <= '1'  when csts(((r-1)+1)*c-1 downto (r-1)*c) = "011010"  else '0';
        core_output1 <= states1((r+1)*b-1 downto r*b);
        core_output2 <= states2((r+1)*b-1 downto r*b);
        core_output3 <= states3((r+1)*b-1 downto r*b);
        core_output4 <= states4((r+1)*b-1 downto r*b);
    end generate;
    --out1 : if (40 mod r) /= 0 generate
    --    core_done   <= '1' when csts(((40 mod r))*c-1 downto ((40 mod r)-1)*c) = "011010" else '0';
    --    core_output <= states(((40 mod r)+1)*b-1 downto (40 mod r)*b);
    --end generate;

    round_cst   <= csts(c-1 downto 0);
    round_key   <= keys(b-1 downto 0);
    round_state1 <= x1 when core_gfunc = '1' else states1(b-1 downto 0);
    round_state2 <= x2 when core_gfunc = '1' else states2(b-1 downto 0);
    round_state3 <= x3 when core_gfunc = '1' else states3(b-1 downto 0);
    round_state4 <= x4 when core_gfunc = '1' else states4(b-1 downto 0);

    ready_block <= core_done;

    delta_state1 <= core_output1(127 downto 64) when delta_load = '1' else delta_out1;
    delta_state2 <= core_output2(127 downto 64) when delta_load = '1' else delta_out2;
    delta_state3 <= core_output3(127 downto 64) when delta_load = '1' else delta_out3;
    delta_state4 <= core_output4(127 downto 64) when delta_load = '1' else delta_out4;
    
    delta_reg1 : entity work.gff
        generic map(clock_gated => true, size => 64)
        port map (clk, reset, delta_state1, delta_save, delta_in1);
    delta_reg2 : entity work.gff
        generic map(clock_gated => true, size => 64)
        port map (clk, reset, delta_state2, delta_save, delta_in2);
    delta_reg3 : entity work.gff
        generic map(clock_gated => true, size => 64)
        port map (clk, reset, delta_state3, delta_save, delta_in3);
    delta_reg4 : entity work.gff
        generic map(clock_gated => true, size => 64)
        port map (clk, reset, delta_state4, delta_save, delta_in4);

    delta1 : entity work.deltaupdate
        port map (delta_in1, delta_mode, delta_out1);
    delta2 : entity work.deltaupdate
        port map (delta_in2, delta_mode, delta_out2);
    delta3 : entity work.deltaupdate
        port map (delta_in3, delta_mode, delta_out3);
    delta4 : entity work.deltaupdate
        port map (delta_in4, delta_mode, delta_out4);

    controller : entity work.controller
        port map (clk, reset, core_done, last_block, last_partial, empty_ad, empty_msg, core_load,
                  core_gfunc, delta_load, delta_mode, core_reset, delta_save);

    g1 : entity work.gfunc
        port map (states1(b-1 downto 0), gfunc_out1);
    g2 : entity work.gfunc
        port map (states2(b-1 downto 0), gfunc_out2);
    g3 : entity work.gfunc
        port map (states3(b-1 downto 0), gfunc_out3);
    g4 : entity work.gfunc
        port map (states4(b-1 downto 0), gfunc_out4);

    ciphertext1 <= data1 xor states1(b-1 downto 0);
    ciphertext2 <= states2(b-1 downto 0);
    ciphertext3 <= states3(b-1 downto 0);
    ciphertext4 <= states4(b-1 downto 0);
    tag1 <= core_output1;
    tag2 <= core_output2;
    tag3 <= core_output3;
    tag4 <= core_output4;

    mix : for i in 0 to 63 generate
        x1(64+i) <= gfunc_out1(64+i) xor data1(64+i) xor delta_out1(i);
        x1(i)    <= gfunc_out1(i) xor data1(i);
        
	x2(64+i) <= gfunc_out2(64+i) xor delta_out2(i);
        x2(i)    <= gfunc_out2(i);
	
	x3(64+i) <= gfunc_out3(64+i) xor delta_out3(i);
        x3(i)    <= gfunc_out3(i);
	
	x4(64+i) <= gfunc_out4(64+i) xor delta_out4(i);
        x4(i)    <= gfunc_out4(i);
    end generate;

end structural;
