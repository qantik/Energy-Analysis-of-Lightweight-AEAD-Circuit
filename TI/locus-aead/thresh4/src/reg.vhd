library ieee;
use ieee.std_logic_1164.all;

entity reg is
    generic (size : integer := 1);
    port (clk   : in  std_logic;
          d     : in  std_logic_vector((size - 1) downto 0);
          q     : out std_logic_vector((size - 1) downto 0));
end reg;

architecture structural of reg is
begin

    bank : for i in 0 to (size - 1) generate
        dff : entity work.dff port map (clk, d(i), q(i));
    end generate;

end architecture structural;
