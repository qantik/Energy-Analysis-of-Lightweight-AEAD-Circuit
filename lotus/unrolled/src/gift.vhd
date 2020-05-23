library ieee;
use ieee.std_logic_1164.all;

entity gift is
    generic (r : integer := 1);
    port(cst_in    : in  std_logic_vector(5 downto 0);
         cst_out   : out std_logic_vector(5 downto 0);
         key_in    : in  std_logic_vector(127 downto 0);
         key_out   : out std_logic_vector(127 downto 0);
         state_in  : in  std_logic_vector(63 downto 0);
         state_out : out std_logic_vector(63 downto 0);
         done      : out std_logic);
end;

architecture structural of gift is

    constant b : integer := 128;
    constant c : integer := 6;

    signal csts   : std_logic_vector((r)*c-1 downto 0);
    signal keys   : std_logic_vector((r)*b-1 downto 0);
    signal states : std_logic_vector((r)*b-1 downto 0);

    signal done_tmp : std_logic;

begin

    ke1 : entity work.keyexpansion
        port map (key_in, keys(b-1 downto 0));
    cl1 : entity work.roundconstant
        port map (cst_in, csts(c-1 downto 0));
    rf1 : entity work.roundfunction
        port map (cst_in, key_in, state_in, states(b-1 downto 0));

    rounds : for i in 1 to r-1 generate
        ke : entity work.keyexpansion
            port map (keys((i)*b-1 downto (i-1)*b), keys((i+1)*b-1 downto (i)*b));
        cl : entity work.roundconstant
            port map (csts((i)*c-1 downto (i-1)*c), csts((i+1)*c-1 downto (i)*c));
        rf : entity work.roundfunction
            port map (csts((i)*c-1 downto (i-1)*c), keys((i)*b-1 downto (i-1)*b),
                      states((i)*b-1 downto (i-1)*b), states((i+1)*b-1 downto (i)*b));
    end generate;


    out0 : if (40 mod r) = 0 generate
        done_tmp  <= '1' when csts(((r-1))*c-1 downto (r-2)*c) = "011010" else '0';
        state_out <= states((r)*b-1 downto (r-1)*b);
        key_out   <= keys((r)*b-1 downto (r-1)*b);
        cst_out   <= csts((r)*c-1 downto (r-1)*c);
        done      <= done_tmp;
    end generate;
    out1 : if (40 mod r) /= 0 generate
        done_tmp  <= '1' when cst_in = "011010" else '0';
        state_out <= states(((40 mod r)+2)*b-1 downto ((40 mod r)+1)*b) when done_tmp = '0' else
                     states((40 mod r)*b-1 downto ((40 mod r)-1)*b);
        key_out   <= keys(((40 mod r)+2)*b-1 downto ((40 mod r)+1)*b);
        cst_out   <= csts(((40 mod r)+2)*c-1 downto ((40 mod r)+1)*c);
        done      <= done_tmp;
    end generate;

end;

