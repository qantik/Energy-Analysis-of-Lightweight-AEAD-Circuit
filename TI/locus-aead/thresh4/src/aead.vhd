library ieee;
use ieee.std_logic_1164.all;

entity aead is
    generic (r : integer := 1);
    port (clk   : in std_logic;
          reset : in std_logic; -- active low

          key                    : in std_logic_vector(127 downto 0);
          nonce                  : in std_logic_vector(127 downto 0);

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
          tag1, tag2, tag3,tag4                             : out std_logic_vector(63 downto 0));
end;

architecture structural of aead is

    -- Block cipher signals.
    constant b   : integer                      := 64;
    constant k   : integer                      := 128;
    constant c   : integer                      := 6;
    constant cst : std_logic_vector(5 downto 0) := "000001";

    signal round_cst   : std_logic_vector(c-1 downto 0);
    signal round_key1, round_key2, round_key3,round_key4         : std_logic_vector(k-1 downto 0);
    signal round_state1, round_state2, round_state3,round_state4 : std_logic_vector(b-1 downto 0);
    signal state_input1, state_input2, state_input3,state_input4 : std_logic_vector(b-1 downto 0);

    signal csts                      : std_logic_vector((r+1)*c-1 downto 0);
    signal keys1                     : std_logic_vector((r+1)*k-1 downto 0);
    signal states1, states2, states3, states4 : std_logic_vector((r+1)*b-1 downto 0);

    -- AEAD signals.
    signal core_reset, core_done                                  : std_logic;
    signal core_output1, core_output2, core_output3, core_output4 : std_logic_vector(63 downto 0);
    signal delta_load                                             : std_logic;

    signal tweak         : std_logic_vector(3 downto 0);
    signal mode          : std_logic_vector(2 downto 0);
    signal plaintext1, plaintext2, plaintext3,plaintext4 : std_logic_vector(63 downto 0);
    signal key_input1                                    : std_logic_vector(127 downto 0);

    signal nonce_delta_in1, nonce_delta_in2, nonce_delta_in3, nonce_delta_in4  : std_logic_vector(63 downto 0);
    signal nonce_delta_out1, nonce_delta_out2, nonce_delta_out3, nonce_delta_out4 : std_logic_vector(63 downto 0);
    signal nonce_delta_en  : std_logic;

    signal v_delta_in1  : std_logic_vector(63 downto 0);
    signal v_delta_out1 : std_logic_vector(63 downto 0);
    signal v_delta_en  : std_logic;       
                                          
    signal w_delta_in1  : std_logic_vector(63 downto 0);
    signal w_delta_out1 : std_logic_vector(63 downto 0);
    signal w_delta_en   : std_logic;

    signal l_delta_in1    : std_logic_vector(127 downto 0);
    signal l_delta_out1   : std_logic_vector(127 downto 0);
    signal l_delta_upd1   : std_logic_vector(127 downto 0);
    signal l_delta_en   : std_logic;
    signal l_delta_load : std_logic;

    signal load_key, load_key_delta : std_logic;

    --constant length : std_logic_vector(63 downto 0) := X"0000000000000010";
    constant length : std_logic_vector(63 downto 0) := X"0000000000000008";

begin

    pt_mux1 : process(mode, states1, data1, nonce_delta_out1, v_delta_out1, w_delta_out1)
    begin
        case mode is
            when "000" => plaintext1 <= data1(63 downto 0); 
            when "001" => plaintext1 <= states1(b-1 downto 0);
            when "010" => plaintext1 <= data1(63 downto 0) xor nonce_delta_out1;
            --when "011" => plaintext1 <= data1(127 downto 64) xor states1(b-1 downto 0);
            when "100" => plaintext1 <= data1(63 downto 0) xor nonce_delta_out1 xor v_delta_out1 xor w_delta_out1;
            when "101" => plaintext1 <= nonce_delta_out1 xor length;
            when "110" => plaintext1 <= data1(63 downto 0) xor states1(b-1 downto 0);
            when others => null;
        end case;
    end process pt_mux1;
    pt_mux2 : process(mode, states2, data2, nonce_delta_out2, v_delta_out1, w_delta_out1)
    begin
        case mode is
            when "000" => plaintext2 <= data2(63 downto 0);
            when "001" => plaintext2 <= states2(b-1 downto 0);
            when "010" => plaintext2 <= data2(63 downto 0) xor nonce_delta_out2;
            --when "011" => plaintext2 <= data2(127 downto 64) xor states2(b-1 downto 0);
            when "100" => plaintext2 <= data2(63 downto 0) xor nonce_delta_out2 xor v_delta_out1 xor w_delta_out1;
            when "101" => plaintext2 <= nonce_delta_out2;
            when "110" => plaintext2 <= data2(63 downto 0) xor states2(b-1 downto 0);
            when others => null;
        end case;
    end process pt_mux2;
    pt_mux3 : process(mode, states3, data3, nonce_delta_out3, v_delta_out1, w_delta_out1)
    begin
        case mode is
            when "000" => plaintext3 <= data3(63 downto 0); 
            when "001" => plaintext3 <= states3(b-1 downto 0);
            when "010" => plaintext3 <= data3(63 downto 0) xor nonce_delta_out3;
            --when "011" => plaintext3 <= data3(127 downto 64) xor states3(b-1 downto 0);
            when "100" => plaintext3 <= data3(63 downto 0) xor nonce_delta_out3 xor v_delta_out1 xor w_delta_out1;
            when "101" => plaintext3 <= nonce_delta_out3;
            when "110" => plaintext3 <= data3(63 downto 0) xor states3(b-1 downto 0);
            when others => null;
        end case;
    end process pt_mux3;
    pt_mux4 : process(mode, states4, data4, nonce_delta_out4, v_delta_out1, w_delta_out1)
    begin
        case mode is
            when "000" => plaintext4 <= data4(63 downto 0); 
            when "001" => plaintext4 <= states4(b-1 downto 0);
            when "010" => plaintext4 <= data4(63 downto 0) xor nonce_delta_out4;
            --when "011" => plaintext4 <= data4(127 downto 64) xor states4(b-1 downto 0);
            when "100" => plaintext4 <= data4(63 downto 0) xor nonce_delta_out4;-- xor v_delta_out1 xor w_delta_out1;
            when "101" => plaintext4 <= nonce_delta_out4;
            when "110" => plaintext4 <= data4(63 downto 0) xor states4(b-1 downto 0);
            when others => null;
        end case;
    end process pt_mux4;

    key_input1 <= key when load_key = '1' else
                  key xor nonce when load_key_delta = '1' else
                  l_delta_upd1;

    ciphertext1(63 downto 0)   <= plaintext1 xor nonce_delta_out1;
    ciphertext1(127 downto 64) <= data1(63 downto 0) xor core_output1 xor nonce_delta_out1;
    tag1                       <= core_output1 xor nonce_delta_out1;
    ciphertext2(63 downto 0)   <= plaintext2 xor nonce_delta_out2;
    ciphertext2(127 downto 64) <= data2(63 downto 0) xor core_output2 xor nonce_delta_out2;
    tag2                       <= core_output2 xor nonce_delta_out2;
    ciphertext3(63 downto 0)   <= plaintext3 xor nonce_delta_out3;
    ciphertext3(127 downto 64) <= data3(63 downto 0) xor core_output3 xor nonce_delta_out3;
    tag3                       <= core_output3 xor nonce_delta_out3;
    ciphertext4(63 downto 0)   <= plaintext4 xor nonce_delta_out4;
    ciphertext4(127 downto 64) <= data4(63 downto 0) xor core_output4 xor nonce_delta_out4;
    tag4                       <= core_output4 xor nonce_delta_out4;
    --tag4                       <= core_output1 xor core_output2 xor core_output3 xor core_output4;

    controller : entity work.controller
        port map (clk, reset, core_done, last_block, last_partial, empty_ad, empty_msg, 
                  mode, tweak, core_reset, nonce_delta_en, v_delta_en, w_delta_en,
                  l_delta_en, l_delta_load, load_key, load_key_delta);

    --nonce_delta_in1 <= core_output1 xor core_output2 xor core_output3 xor core_output4;
    nonce_delta_in1 <= core_output1;
    nonce_delta_in2 <= core_output2;
    nonce_delta_in3 <= core_output3;
    nonce_delta_in4 <= core_output4;

    l_delta_in1 <= key xor nonce when l_delta_load = '1' else l_delta_upd1;
    --l_delta_in2 <= key xor nonce2 when l_delta_load = '1' else l_delta_upd2;
    --l_delta_in3 <= key xor nonce3 when l_delta_load = '1' else l_delta_upd3;

    v_delta_in1 <= core_output1 xor core_output2 xor core_output3 xor core_output4 xor v_delta_out1;
    w_delta_in1 <= core_output1 xor core_output2 xor core_output3 xor core_output4 xor w_delta_out1;
    --v_delta_in2 <= core_output2 xor v_delta_out2;
    --w_delta_in2 <= core_output2 xor w_delta_out2;
    --v_delta_in3 <= core_output3 xor v_delta_out3;
    --w_delta_in3 <= core_output3 xor w_delta_out3;

    nonce_delta_reg1 : entity work.gff
        generic map (true, 64)
        port map (clk, reset, nonce_delta_in1, nonce_delta_en, nonce_delta_out1);
    nonce_delta_reg2 : entity work.gff
        generic map (true, 64)
        port map (clk, reset, nonce_delta_in2, nonce_delta_en, nonce_delta_out2);
    nonce_delta_reg3 : entity work.gff
        generic map (true, 64)
        port map (clk, reset, nonce_delta_in3, nonce_delta_en, nonce_delta_out3);
    nonce_delta_reg4 : entity work.gff
        generic map (true, 64)
        port map (clk, reset, nonce_delta_in4, nonce_delta_en, nonce_delta_out4);

    v_delta_reg1 : entity work.gff
        generic map (true, 64)
        port map (clk, reset, v_delta_in1, v_delta_en, v_delta_out1);
    --v_delta_reg2 : entity work.gff
    --    generic map (false, 64)
    --    port map (clk, reset, v_delta_in2, v_delta_en, v_delta_out2);
    --v_delta_reg3 : entity work.gff
    --    generic map (false, 64)
    --    port map (clk, reset, v_delta_in3, v_delta_en, v_delta_out3);
    
    w_delta_reg1 : entity work.gff
        generic map (true, 64)
        port map (clk, reset, w_delta_in1, w_delta_en, w_delta_out1);
    --w_delta_reg2 : entity work.gff
    --    generic map (false, 64)
    --    port map (clk, reset, w_delta_in2, w_delta_en, w_delta_out2);
    --w_delta_reg3 : entity work.gff
    --    generic map (false, 64)
    --    port map (clk, reset, w_delta_in3, w_delta_en, w_delta_out3);
    l_delta_reg1 : entity work.gff
        generic map (true, 128)
        port map (clk, reset, l_delta_in1, l_delta_en, l_delta_out1);
    --l_delta_reg2 : entity work.gff
    --    generic map (false, 128)
    --    port map (clk, reset, l_delta_in2, l_delta_en, l_delta_out2);
    --l_delta_reg3 : entity work.gff
    --    generic map (false, 128)
    --    port map (clk, reset, l_delta_in3, l_delta_en, l_delta_out3);

    l_delta1 : entity work.deltaupdate
        port map (l_delta_out1, l_delta_upd1);
    --l_delta2 : entity work.deltaupdate
    --    port map (l_delta_out2, l_delta_upd2);
    --l_delta3 : entity work.deltaupdate
    --    port map (l_delta_out3, l_delta_upd3);

    in0 : if (28 mod r) = 0 generate
        state_input1 <= states1((r+1)*b-1 downto r*b);
        state_input2 <= states2((r+1)*b-1 downto r*b);
        state_input3 <= states3((r+1)*b-1 downto r*b);
        state_input4 <= states4((r+1)*b-1 downto r*b);
    end generate;
    --in1 : if (28 mod r) /= 0 generate
    --    muxr3 : entity work.muxr3
    --       port map(states((r+1)*b-1 downto r*b),
    --                core_output, core_done, state_input); 
    --    --state_input <= core_output when core_done = '1' else states((r+1)*b-1 downto r*b);
    --end generate;

    cst_reg : entity work.reg
        generic map (size => c)
        port map (clk, csts((r+1)*c-1 downto r*c), csts(c-1 downto 0));
    
    state_reg1 : entity work.reg
        generic map (size => b)
        port map (clk, state_input1, states1(b-1 downto 0));
    state_reg2 : entity work.reg
        generic map (size => b)
        port map (clk, state_input2, states2(b-1 downto 0));
    state_reg3 : entity work.reg
        generic map (size => b)
        port map (clk, state_input3, states3(b-1 downto 0));
    state_reg4 : entity work.reg
        generic map (size => b)
        port map (clk, state_input4, states4(b-1 downto 0));
    key_reg1 : entity work.reg
        generic map (size => k)
        port map (clk, keys1((r+1)*k-1 downto r*k), keys1(k-1 downto 0));
    --key_reg2 : entity work.reg
    --    generic map (size => k)
    --    port map (clk, stall, keys2((r+1)*k-1 downto r*k), keys2(k-1 downto 0));
    --key_reg3 : entity work.reg
    --    generic map (size => k)
    --    port map (clk, stall, keys3((r+1)*k-1 downto r*k), keys3(k-1 downto 0));

    cl1 : entity work.roundconstant
        port map (round_cst, csts(2*c-1 downto c));
    
    ke1 : entity work.keyexpansion
        port map (round_key1, keys1(2*k-1 downto k));
    --ke2 : entity work.keyexpansion
    --    port map (round_key2, keys2(2*k-1 downto k));
    --ke3 : entity work.keyexpansion
    --    port map (round_key3, keys3(2*k-1 downto k));

    rf : entity work.partial
        port map (clk, round_cst, tweak, round_key1,
	   round_state1, round_state2, round_state3, round_state4,
	   states1(2*b-1 downto b), states2(2*b-1 downto b), states3(2*b-1 downto b),
           states4(2*b-1 downto b));
    
    --rf1 : entity work.roundfunction
    --    port map (round_cst, round_key, tweak, round_state, states(2*b-1 downto b));

     --rounds : for i in 1 to r-1 generate
     --    ke : entity work.keyexpansion
     --        port map (keys((i+1)*k-1 downto i*k), keys((i+2)*k-1 downto (i+1)*k));
     --    cl : entity work.roundconstant
     --        port map (csts((i+1)*c-1 downto i*c), csts((i+2)*c-1 downto (i+1)*c));
     --    rf : entity work.roundfunction
     --        port map (csts((i+1)*c-1 downto (i+0)*c), keys((i+1)*k-1 downto i*k), tweak,
     --                  states((i+1)*b-1 downto i*b), states((i+2)*b-1 downto (i+1)*b));
     --end generate;

    out0 : if (28 mod r) = 0 generate
        core_done   <= '1' when csts(((r-1)+1)*c-1 downto (r-1)*c) = "001011" else '0';
        core_output1 <= states1((r+1)*b-1 downto r*b);
        core_output2 <= states2((r+1)*b-1 downto r*b);
        core_output3 <= states3((r+1)*b-1 downto r*b);
        core_output4 <= states4((r+1)*b-1 downto r*b);
    end generate;
    --out1 : if (28 mod r) /= 0 generate
    --    core_done   <= '1' when csts(((28 mod r))*c-1 downto ((28 mod r)-1)*c) = "001011" else '0';
    --    core_output <= states(((28 mod r)+1)*b-1 downto ((28 mod r))*b);
    --end generate;

    round_cst   <= cst       when core_reset = '1' else csts(c-1 downto 0);
    
    round_state1 <= plaintext1 when core_reset = '1' else states1(b-1 downto 0);
    round_state2 <= plaintext2 when core_reset = '1' else states2(b-1 downto 0);
    round_state3 <= plaintext3 when core_reset = '1' else states3(b-1 downto 0);
    round_state4 <= plaintext4 when core_reset = '1' else states4(b-1 downto 0);
    round_key1   <= key_input1 when core_reset = '1' else keys1(k-1 downto 0);
    --round_key2   <= key_input1 when core_reset = '1' else keys2(k-1 downto 0);
    --round_key3   <= key_input1 when core_reset = '1' else keys3(k-1 downto 0);

    ready_block <= core_done;

end structural;
