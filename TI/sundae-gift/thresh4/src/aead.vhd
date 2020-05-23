library ieee;
use ieee.std_logic_1164.all;

entity aead is
    generic (r : integer := 1);
    port (clk   : in std_logic;
          reset : in std_logic; -- active low

          key   : in std_logic_vector(127 downto 0);

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

          ciphertext1, ciphertext2, ciphertext3,ciphertext4 : out std_logic_vector(127 downto 0);
          tag1, tag2, tag3,tag4                             : out std_logic_vector(127 downto 0));
end;

architecture structural of aead is

    -- Block cipher signals.
    constant b   : integer                      := 128;
    constant c   : integer                      := 6;
    constant cst : std_logic_vector(5 downto 0) := "000001";

    signal round_cst                                : std_logic_vector(c-1 downto 0);
    signal round_key                                : std_logic_vector(b-1 downto 0);
    signal round_state1, round_state2, round_state3,round_state4 : std_logic_vector(b-1 downto 0);

    signal csts                              : std_logic_vector((r+1)*c-1 downto 0);
    signal keys                              : std_logic_vector((r+1)*b-1 downto 0);
    signal states1, states2, states3,states4 : std_logic_vector((r+1)*b-1 downto 0);

    -- AEAD signals.
    signal core_load, core_gfunc, core_done : std_logic;
    signal core_output1, core_output2, core_output3,core_output4 : std_logic_vector(127 downto 0);
    signal x1, x2, x3, x4                                        : std_logic_vector(127 downto 0);
    signal gfunc_out1, gfunc_out2, gfunc_out3, gfunc_out4        : std_logic_vector(127 downto 0);
    signal state_input1, state_input2, state_input3,state_input4 : std_logic_vector(127 downto 0);

    signal core_reset : std_logic;
    signal round_comp : std_logic;

    signal domain1, domain2, domain3, domain4 : std_logic_vector(127 downto 0);
    signal mode                               : std_logic_vector(1 downto 0);
    signal gmult_sel                          : std_logic;


begin

    --domain <= not(empty_ad) & not(empty_msg) & mode & X"0000000000000000000000000000000";
    --domain1 <= not(empty_ad) & not(empty_msg) & mode & X"0000000000000000000000000000000";
    --domain2 <= (others => '0');
    --domain3 <= (others => '0');
    --domain4 <= (others => '0');

    --mode_proc : process(empty_ad)
    --begin
    --    if empty_ad = '1' then
    --        mode <= "00";
    --    else
    --        mode <= "10";
    --    end if;
    --end process;

    cst_reg : entity work.reg
        generic map (size => c)
        port map (clk, core_reset, csts((r+1)*c-1 downto r*c), cst, csts(c-1 downto 0));
    key_reg : entity work.reg
        generic map (size => b)
        port map (clk, core_reset, keys((r+1)*b-1 downto r*b), key, keys(b-1 downto 0));

    state_reg1 : entity work.reg
        generic map (size => b)
        port map (clk, core_load, state_input1, data1, states1(b-1 downto 0));
    state_reg2 : entity work.reg
        generic map (size => b)
        port map (clk, core_load, state_input2, data2, states2(b-1 downto 0));
    state_reg3 : entity work.reg
        generic map (size => b)
        port map (clk, core_load, state_input3, data3, states3(b-1 downto 0));
    state_reg4 : entity work.reg
        generic map (size => b)
        port map (clk, core_load, state_input4, data4, states4(b-1 downto 0));

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
        core_done    <= '1' when csts(((r-1)+1)*c-1 downto (r-1)*c) = "011010" else '0';
        core_output1 <= states1((r+1)*b-1 downto r*b);
        core_output2 <= states2((r+1)*b-1 downto r*b);
        core_output3 <= states3((r+1)*b-1 downto r*b);
        core_output4 <= states4((r+1)*b-1 downto r*b);
    end generate;
    --out1 : if (40 mod r) /= 0 generate
    --    core_done   <= '1' when csts(((40 mod r))*c-1 downto ((40 mod r)-1)*c) = "011010" else '0';
    --    core_output <= states(((40 mod r)+1)*b-1 downto (40 mod r)*b);
    --end generate;

    round_cst    <= csts(c-1 downto 0);
    round_key    <= keys(b-1 downto 0);
    round_state1 <= states1(127 downto 0) when round_comp = '1' else
                    gfunc_out1 when core_gfunc = '1' else x1;
    round_state2 <= states2(127 downto 0) when round_comp = '1' else
                    gfunc_out2 when core_gfunc = '1' else x2;
    round_state3 <= states3(127 downto 0) when round_comp = '1' else
                    gfunc_out3 when core_gfunc = '1' else x3;
    round_state4 <= states4(127 downto 0) when round_comp = '1' else
                    gfunc_out4 when core_gfunc = '1' else x4;


    ready_block <= core_done;

    controller : entity work.controller
        port map (clk, reset, core_done, last_block, last_partial, empty_ad, empty_msg,
                  core_load, core_gfunc, core_reset, round_comp, gmult_sel);

    g1 : entity work.gmult
        port map (x1, gmult_sel, gfunc_out1);
    g2 : entity work.gmult
        port map (x2, gmult_sel, gfunc_out2);
    g3 : entity work.gmult
        port map (x3, gmult_sel, gfunc_out3);
    g4 : entity work.gmult
        port map (x4, gmult_sel, gfunc_out4);

    ciphertext1 <= core_output1 xor data1;
    ciphertext2 <= core_output2;
    ciphertext3 <= core_output3;
    ciphertext4 <= core_output4;
    tag1        <= core_output1;
    tag2        <= core_output2;
    tag3        <= core_output3;
    tag4        <= core_output4;

    x1 <= data1 xor states1(127 downto 0);
    x2 <= data2 xor states2(127 downto 0);
    x3 <= data3 xor states3(127 downto 0);
    x4 <= data4 xor states4(127 downto 0);
    
end structural;
