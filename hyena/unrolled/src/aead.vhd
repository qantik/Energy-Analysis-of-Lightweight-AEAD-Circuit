library ieee;
use ieee.std_logic_1164.all;

entity aead is
    generic (inverse_gated : boolean := true);
    port (clk   : in std_logic;
          iclk  : in std_logic;
          reset : in std_logic; -- active low

          key   : in std_logic_vector(127 downto 0);
          nonce : in std_logic_vector(95 downto 0);

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
          tag          : out std_logic_vector(127 downto 0));
end;

architecture structural of aead is

    -- Block cipher signals.
    constant b   : integer                      := 128;
    constant c   : integer                      := 6;
    constant r   : integer                      := 40;
    constant cst : std_logic_vector(5 downto 0) := "000001";

    signal round_state : std_logic_vector(b-1 downto 0);

    signal csts   : std_logic_vector((r+1)*c-1 downto 0);
    signal keys   : std_logic_vector((r+1)*b-1 downto 0);
    signal states : std_logic_vector((r+1)*b-1 downto 0);

    -- AEAD signals.
    signal core_load, core_gfunc, core_done : std_logic;
    signal core_output                      : std_logic_vector(127 downto 0);
    signal delta_load                       : std_logic;
    signal delta_mode                       : std_logic_vector(1 downto 0);
    signal delta_in, delta_out              : std_logic_vector(63 downto 0);
    signal state_input                      : std_logic_vector(127 downto 0);

    signal domain   : std_logic_vector(127 downto 0);
    signal feedback : std_logic_vector(127 downto 0);
    signal hyfb_x   : std_logic_vector(127 downto 0);
    signal hyfb_c   : std_logic_vector(127 downto 0);

    signal zero_feedback : std_logic;
    signal switch        : std_logic;
    signal load_hyfb     : std_logic;
    signal is_nonce      : std_logic;

    signal inter       : std_logic_vector(((r) * b) - 1 downto 0);
    signal inter_keys  : std_logic_vector(((r) * b) - 1 downto 0);
    signal enable      : std_logic_vector(r-1 downto 0);

begin

    domain <= nonce & "000000000000000000000000000000" & (empty_ad and empty_msg) & empty_ad;
    
    state_reg : entity work.reg
        generic map (size => b)
        port map (clk, core_load, state_input, domain, states(b-1 downto 0));

    state_input <= states((r+1)*b-1 downto r*b);

    ke1 : entity work.keyexpansion
        port map (keys(b-1 downto 0), keys(2*b-1 downto b));
    cl1 : entity work.roundconstant
        port map (csts(c-1 downto 0), csts(2*c-1 downto c));
    rf1 : entity work.roundfunction
        port map (csts(c-1 downto 0), key, round_state, states(2*b-1 downto b));

    ig : if inverse_gated = true generate
        enable(0) <= clk;

        delay_gen : for i in 1 to r-1 generate
            delay : entity work.delayer port map (enable(i-1), enable(i));
        end generate;
        
        rounds : for i in 1 to 39 generate
            inter(((i)*b) - 1 downto ((i-1)*b)) <= states((i+1)*b-1 downto i*b)
                                                 when (enable(i) or iclk) = '1'
                                                 else (others => '0');
            inter_keys(((i)*b) - 1 downto ((i-1)*b)) <= keys((i+1)*b-1 downto i*b)
                                                 when (enable(i) or iclk) = '1'
                                                 else (others => '0');
            ke : entity work.keyexpansion
                port map (keys((i+1)*b-1 downto i*b), keys((i+2)*b-1 downto (i+1)*b));
            cl : entity work.roundconstant
                port map (csts((i+1)*c-1 downto i*c), csts((i+2)*c-1 downto (i+1)*c));
            rf : entity work.roundfunction
                port map (csts((i+1)*c-1 downto (i+0)*c), inter_keys((i)*b-1 downto (i-1)*b),
                          inter(((i)*b) - 1 downto ((i-1)*b)), states((i+2)*b-1 downto (i+1)*b));
        end generate;
    end generate;

    nig : if inverse_gated = false generate
        rounds : for i in 1 to r-1 generate
            ke : entity work.keyexpansion
                port map (keys((i+1)*b-1 downto i*b), keys((i+2)*b-1 downto (i+1)*b));
            cl : entity work.roundconstant
                port map (csts((i+1)*c-1 downto i*c), csts((i+2)*c-1 downto (i+1)*c));
            rf : entity work.roundfunction
                port map (csts((i+1)*c-1 downto (i+0)*c), keys((i+1)*b-1 downto i*b),
                          states((i+1)*b-1 downto i*b), states((i+2)*b-1 downto (i+1)*b));
        end generate;
    end generate;

    core_output <= states((r+1)*b-1 downto r*b);

    csts(c-1 downto 0) <= cst;
    keys(b-1 downto 0) <= key;
    round_state <= hyfb_x(63 downto 0) & hyfb_x(127 downto 64) when switch = '1' else
                   states(b-1 downto 0) when is_nonce = '1' else hyfb_x;

    delta_reg : entity work.reg
        generic map(size => 64)
        port map (clk, delta_load, delta_out, core_output(127 downto 64), delta_in);

    delta : entity work.deltaupdate
        port map (delta_in, delta_mode, delta_out);

    controller : entity work.controller
        port map (clk, reset, last_block, last_partial, empty_ad, empty_msg, core_load,
                  delta_load, delta_mode, zero_feedback, switch, load_hyfb, is_nonce);

    feedback <= X"00000000000000000000000000000001" when zero_feedback = '1' else data;
    hyfb : entity work.hyfb
        port map(states(b-1 downto 0), delta_out, feedback, hyfb_x, hyfb_c);

    ciphertext <= hyfb_x;
    tag        <= core_output;

end structural;
