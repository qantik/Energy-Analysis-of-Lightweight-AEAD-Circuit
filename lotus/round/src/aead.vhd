library ieee;
use ieee.std_logic_1164.all;

entity aead is
    generic (r : integer := 3);
    port (clk   : in std_logic;
          reset : in std_logic; -- active low

          key   : in std_logic_vector(127 downto 0);
          nonce : in std_logic_vector(127 downto 0);

          -- A data block is either associated data or plaintext.
          -- last_block indicates whether the current ad or plaintext
          -- block is the last one with last_partial indicating whether
          -- said block is only partially filled.
          data         : in std_logic_vector(127 downto 0);
          last_block   : in std_logic;
          last_partial : in std_logic;

          empty_ad     : in std_logic; -- Constant, set at the beginning.
          empty_msg    : in std_logic; -- Constant, set at the beginning.

          ready_block  : out std_logic; -- Expecting new block at next rising edge.
          ready_full   : out std_logic; -- AEAD finished.

          -- Indication signals that tell whether current value on either
          -- the ciphertext or tag output pins is valid.
          cipher_ready : out std_logic;
          tag_ready    : out std_logic;

          ciphertext   : out std_logic_vector(127 downto 0);
          tag          : out std_logic_vector(63 downto 0));
end;

architecture structural of aead is

    -- Block cipher signals.
    constant b   : integer                      := 64;
    constant k   : integer                      := 128;
    constant c   : integer                      := 6;
    constant cst : std_logic_vector(5 downto 0) := "000001";

    signal round_cst   : std_logic_vector(c-1 downto 0);
    signal round_key   : std_logic_vector(k-1 downto 0);
    signal round_state : std_logic_vector(b-1 downto 0);
    signal state_input : std_logic_vector(b-1 downto 0);

    signal csts   : std_logic_vector((r+1)*c-1 downto 0);
    signal keys   : std_logic_vector((r+1)*k-1 downto 0);
    signal states : std_logic_vector((r+1)*b-1 downto 0);

    -- AEAD signals.
    signal core_reset, core_done : std_logic;
    signal core_output           : std_logic_vector(63 downto 0);
    signal delta_load            : std_logic;

    signal tweak         : std_logic_vector(3 downto 0);
    signal mode          : std_logic_vector(2 downto 0);
    signal plaintext     : std_logic_vector(63 downto 0);
    signal key_input     : std_logic_vector(127 downto 0);

    signal nonce_delta_in  : std_logic_vector(63 downto 0);
    signal nonce_delta_out : std_logic_vector(63 downto 0);
    signal nonce_delta_en  : std_logic;

    signal v_delta_in  : std_logic_vector(63 downto 0);
    signal v_delta_out : std_logic_vector(63 downto 0);
    signal v_delta_en  : std_logic;       
                                          
    signal w_delta_in  : std_logic_vector(63 downto 0);
    signal w_delta_out : std_logic_vector(63 downto 0);
    signal w_delta_en  : std_logic;

    signal l_delta_in   : std_logic_vector(127 downto 0);
    signal l_delta_out  : std_logic_vector(127 downto 0);
    signal l_delta_upd  : std_logic_vector(127 downto 0);
    signal l_delta_en   : std_logic;
    signal l_delta_load : std_logic;

    signal load_key, load_key_delta : std_logic;

    constant length : std_logic_vector(63 downto 0) := X"0000000000000010";

begin

    pt_mux : process(mode, states, data, nonce_delta_out, v_delta_out, w_delta_out)
    begin
        case mode is
            when "000" => plaintext <= (others => '0'); 
            when "001" => plaintext <= states(b-1 downto 0);
            when "010" => plaintext <= data(63 downto 0) xor nonce_delta_out;
            when "011" => plaintext <= data(127 downto 64) xor states(b-1 downto 0);
            when "100" => plaintext <= data(127 downto 64) xor nonce_delta_out xor v_delta_out xor w_delta_out;
            when "101" => plaintext <= nonce_delta_out xor length;
            when "110" => plaintext <= data(63 downto 0) xor states(b-1 downto 0);
            when others => null;
        end case;
    end process pt_mux;

    key_input <= key when load_key = '1' else
                 key xor nonce when load_key_delta = '1' else
                 l_delta_upd;

    ciphertext(63 downto 0)   <= plaintext xor nonce_delta_out;
    ciphertext(127 downto 64) <= data(63 downto 0) xor core_output xor nonce_delta_out;
    tag                       <= core_output xor nonce_delta_out;

    controller : entity work.controller
        port map (clk, reset, core_done, last_block, last_partial, empty_ad, empty_msg,
                  mode, tweak, core_reset, nonce_delta_en, v_delta_en, w_delta_en,
                  l_delta_en, l_delta_load, load_key, load_key_delta);

    nonce_delta_in <= core_output;

    l_delta_in <= key xor nonce when l_delta_load = '1' else l_delta_upd;

    v_delta_in <= core_output xor v_delta_out;
    w_delta_in <= core_output xor w_delta_out;

    nonce_delta_reg : entity work.gff
        generic map (false, 64)
        port map (clk, reset, nonce_delta_in, nonce_delta_en, nonce_delta_out);
    v_delta_reg : entity work.gff
        generic map (false, 64)
        port map (clk, reset, v_delta_in, v_delta_en, v_delta_out);
    w_delta_reg : entity work.gff
        generic map (false, 64)
        port map (clk, reset, w_delta_in, w_delta_en, w_delta_out);
    l_delta_reg : entity work.gff
        generic map (false, 128)
        port map (clk, reset, l_delta_in, l_delta_en, l_delta_out);

    l_delta : entity work.deltaupdate
        port map (l_delta_out, l_delta_upd);

    in0 : if (28 mod r) = 0 generate
        state_input <= states((r+1)*b-1 downto r*b);
    end generate;
    in1 : if (28 mod r) /= 0 generate
        muxr3 : entity work.muxr3
	   port map(states((r+1)*b-1 downto r*b),
	            core_output, core_done, state_input); 
        --state_input <= core_output when core_done = '1' else states((r+1)*b-1 downto r*b);
    end generate;

    cst_reg : entity work.reg
        generic map (size => c)
        port map (clk, csts((r+1)*c-1 downto r*c), csts(c-1 downto 0));
    key_reg : entity work.reg
        generic map (size => k)
        port map (clk, keys((r+1)*k-1 downto r*k), keys(k-1 downto 0));
    state_reg : entity work.reg
        generic map (size => b)
        --port map (clk, states((r+1)*b-1 downto r*b), states(b-1 downto 0));
        port map (clk, state_input, states(b-1 downto 0));

    ke1 : entity work.keyexpansion
        port map (round_key, keys(2*k-1 downto k));
    cl1 : entity work.roundconstant
        port map (round_cst, csts(2*c-1 downto c));
    rf1 : entity work.roundfunction
        port map (round_cst, round_key, tweak, round_state, states(2*b-1 downto b));

     rounds : for i in 1 to r-1 generate
         ke : entity work.keyexpansion
             port map (keys((i+1)*k-1 downto i*k), keys((i+2)*k-1 downto (i+1)*k));
         cl : entity work.roundconstant
             port map (csts((i+1)*c-1 downto i*c), csts((i+2)*c-1 downto (i+1)*c));
         rf : entity work.roundfunction
             port map (csts((i+1)*c-1 downto (i+0)*c), keys((i+1)*k-1 downto i*k), tweak,
                       states((i+1)*b-1 downto i*b), states((i+2)*b-1 downto (i+1)*b));
     end generate;

    out0 : if (28 mod r) = 0 generate
        core_done   <= '1' when csts(((r-1)+1)*c-1 downto (r-1)*c) = "001011" else '0';
        core_output <= states((r+1)*b-1 downto r*b);
    end generate;
    out1 : if (28 mod r) /= 0 generate
        core_done   <= '1' when csts(((28 mod r))*c-1 downto ((28 mod r)-1)*c) = "001011" else '0';
        core_output <= states(((28 mod r)+1)*b-1 downto ((28 mod r))*b);
    end generate;

    round_cst   <= cst       when core_reset = '1' else csts(c-1 downto 0);
    round_key   <= key_input when core_reset = '1' else keys(k-1 downto 0);
    round_state <= plaintext when core_reset = '1' else states(b-1 downto 0);

    ready_block <= core_done;

end structural;
