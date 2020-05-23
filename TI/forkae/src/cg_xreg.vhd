library ieee;
use ieee.std_logic_1164.all;

entity cg_xreg is
    generic (SIZE : integer := 128; PARTITION : integer := 16);
    port(clk    : in std_logic;
         reset  : in std_logic;
         enable : in std_logic;
         input  : in std_logic_vector(127 downto 0);

         output : out std_logic_vector(127 downto 0));
end;

architecture behaviour of cg_xreg is

    constant n : integer := SIZE / PARTITION;
    signal state : std_logic_vector(127 downto 0);
    signal clken  : std_logic_vector(n-1 downto 0);

begin

    gen_loop: for i in 0 to n-1 generate
        cgate : entity WORK.cg_xor port map (clk, enable, clken(i));
        fflop : entity WORK.RFF generic map (SIZE => PARTITION) port map (clken(i), reset, input(PARTITION*(i+1) - 1 downto PARTITION*i), output(PARTITION*(i+1) - 1 downto PARTITION*i));
    end generate;

end;

