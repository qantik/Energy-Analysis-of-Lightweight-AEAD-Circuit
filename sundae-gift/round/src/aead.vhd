library ieee;
use ieee.std_logic_1164.all;

entity aead is
    generic (r : integer := 3);
    port (clk   : in std_logic;
          reset : in std_logic; -- active low

          key   : in std_logic_vector(127 downto 0);

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
    constant cst : std_logic_vector(5 downto 0) := "000001";

    signal round_cst   : std_logic_vector(c-1 downto 0);
    signal round_key   : std_logic_vector(b-1 downto 0);
    signal round_state : std_logic_vector(b-1 downto 0);

    signal csts   : std_logic_vector((r+1)*c-1 downto 0);
    signal keys   : std_logic_vector((r+1)*b-1 downto 0);
    signal states : std_logic_vector((r+1)*b-1 downto 0);

    -- AEAD signals.
    signal core_load, core_gfunc, core_done : std_logic;
    signal core_output                      : std_logic_vector(127 downto 0);
    signal x                                : std_logic_vector(127 downto 0);
    signal gfunc_out                        : std_logic_vector(127 downto 0);
    signal state_input                      : std_logic_vector(127 downto 0);

    signal core_reset : std_logic;
    signal round_comp : std_logic;

    signal domain    : std_logic_vector(127 downto 0);
    signal mode      : std_logic_vector(1 downto 0);
    signal gmult_sel : std_logic;

begin

    domain <= not(empty_ad) & not(empty_msg) & mode & X"0000000000000000000000000000000";

    mode_proc : process(empty_ad)
    begin
        if empty_ad = '1' then
            mode <= "00";
        else
            mode <= "10";
        end if;
    end process;

    cst_reg : entity work.reg
        generic map (size => c)
        port map (clk, core_reset, csts((r+1)*c-1 downto r*c), cst, csts(c-1 downto 0));
    key_reg : entity work.reg
        generic map (size => b)
        port map (clk, core_reset, keys((r+1)*b-1 downto r*b), key, keys(b-1 downto 0));
    state_reg : entity work.reg
        generic map (size => b)
        port map (clk, core_load, state_input, domain, states(b-1 downto 0));

    input0 : if (40 mod r) = 0 generate
        state_input <= states((r+1)*b-1 downto r*b);
    end generate;
    input1 : if (40 mod r) /= 0 generate
        muxr3 : entity work.muxr3
	   port map(states((r+1)*b-1 downto r*b),
	            states(((40 mod r)+1)*b-1 downto (40 mod r)*b), core_done, state_input); 
        --state_input <= states((r+1)*b-1 downto r*b) when core_done = '0' else
        --               states(((40 mod r)+1)*b-1 downto (40 mod r)*b);
    end generate;

    ke1 : entity work.keyexpansion
        port map (round_key, keys(2*b-1 downto b));
    cl1 : entity work.roundconstant
        port map (round_cst, csts(2*c-1 downto c));
    rf1 : entity work.roundfunction
        port map (round_cst, round_key, round_state, states(2*b-1 downto b));

    rounds : for i in 1 to r-1 generate
        ke : entity work.keyexpansion
            port map (keys((i+1)*b-1 downto i*b), keys((i+2)*b-1 downto (i+1)*b));
        cl : entity work.roundconstant
            port map (csts((i+1)*c-1 downto i*c), csts((i+2)*c-1 downto (i+1)*c));
        rf : entity work.roundfunction
            port map (csts((i+1)*c-1 downto (i+0)*c), keys((i+1)*b-1 downto i*b),
                      states((i+1)*b-1 downto i*b), states((i+2)*b-1 downto (i+1)*b));
    end generate;

    out0 : if (40 mod r) = 0 generate
        core_done   <= '1' when csts(((r-1)+1)*c-1 downto (r-1)*c) = "011010" else '0';
        core_output <= states((r+1)*b-1 downto r*b);
    end generate;
    out1 : if (40 mod r) /= 0 generate
        core_done   <= '1' when csts(((40 mod r))*c-1 downto ((40 mod r)-1)*c) = "011010" else '0';
        core_output <= states(((40 mod r)+1)*b-1 downto (40 mod r)*b);
    end generate;

    round_cst   <= csts(c-1 downto 0);
    round_key   <= keys(b-1 downto 0);
    round_state <= states(127 downto 0) when round_comp = '1' else
                   gfunc_out when core_gfunc = '1' else x;

    ready_block <= core_done;

    controller : entity work.controller
        port map (clk, reset, core_done, last_block, last_partial, empty_ad, empty_msg,
                  core_load, core_gfunc, core_reset, round_comp, gmult_sel);

    g : entity work.gmult
        port map (x, gmult_sel, gfunc_out);

    ciphertext <= core_output xor data;
    tag        <= core_output;

    x           <= data xor states(127 downto 0);
    
end structural;
