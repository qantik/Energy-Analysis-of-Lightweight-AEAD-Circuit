library ieee;
use ieee.std_logic_1164.all;

entity aead is
    generic (inverse_gated : boolean := true);
    port (clk   : in std_logic;
          iclk  : in std_logic;
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
          tag          : out std_logic_vector(127 downto 0));
end;

architecture structural of aead is

    -- Block cipher signals.
    constant b   : integer                      := 128;
    constant c   : integer                      := 6;
    constant r   : integer                      := 40;
    constant cst : std_logic_vector(5 downto 0) := "000001";

    signal round_cst   : std_logic_vector(c-1 downto 0);
    signal round_key   : std_logic_vector(b-1 downto 0);
    signal round_state : std_logic_vector(b-1 downto 0);

    signal csts   : std_logic_vector((r+1)*c-1 downto 0);
    signal keys   : std_logic_vector((r+1)*b-1 downto 0);
    signal states : std_logic_vector((r+1)*b-1 downto 0);

    -- AEAD signals.
    signal core_load, core_gfunc : std_logic;
    signal core_output           : std_logic_vector(127 downto 0);
    signal delta_load            : std_logic;
    signal delta_mode            : std_logic_vector(3 downto 0);
    signal delta_in, delta_out   : std_logic_vector(63 downto 0);
    signal x                     : std_logic_vector(127 downto 0);
    signal gfunc_out             : std_logic_vector(127 downto 0);
    signal state_input           : std_logic_vector(127 downto 0);

    signal core_state : std_logic_vector(127 downto 0);
    signal core_key   : std_logic_vector(127 downto 0);
    signal core_cst   : std_logic_vector(5 downto 0);
    signal round_tmp  : std_logic_vector(127 downto 0);

    signal inter  : std_logic_vector(((r) * b) - 1 downto 0);
    signal enable : std_logic_vector(r-1 downto 0);

begin
    state_reg : entity work.reg
        generic map (size => b)
        port map (clk, core_load, state_input, nonce, states(b-1 downto 0));

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
            
            ke : entity work.keyexpansion
                port map (keys((i+1)*b-1 downto i*b), keys((i+2)*b-1 downto (i+1)*b));
            cl : entity work.roundconstant
                port map (csts((i+1)*c-1 downto i*c), csts((i+2)*c-1 downto (i+1)*c));
            rf : entity work.roundfunction
                port map (csts((i+1)*c-1 downto (i+0)*c), keys((i+1)*b-1 downto i*b),
                          inter(((i)*b) - 1 downto ((i-1)*b)), states((i+2)*b-1 downto (i+1)*b));
        end generate;
    end generate;

    norm : if inverse_gated = false generate
        rounds : for i in 1 to 39 generate
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
    round_state        <= x when core_gfunc = '1' else states(b-1 downto 0);

    delta_reg : entity work.reg
        generic map(size => 64)
        port map (clk, delta_load, delta_out, core_output(127 downto 64), delta_in);

    delta : entity work.deltaupdate
        port map (delta_in, delta_mode, delta_out);

    controller : entity work.controller
        port map (clk, reset, last_block, last_partial, empty_ad, empty_msg, core_load,
                  core_gfunc, delta_load, delta_mode);

    g : entity work.gfunc
        port map (states(b-1 downto 0), gfunc_out);

    ciphertext <= data xor states(b-1 downto 0);
    tag        <= core_output;

    mix : for i in 0 to 63 generate
        x(64+i) <= gfunc_out(64+i) xor data(64+i) xor delta_out(i);
        x(i)    <= gfunc_out(i) xor data(i);
    end generate;

end structural;
