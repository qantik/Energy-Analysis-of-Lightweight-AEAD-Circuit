library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity SCANFF is
    generic (SIZE : integer);
    port (CLK : in  std_logic;
          D   : in  std_logic_vector((SIZE - 1) downto 0);
          Q   : out std_logic_vector((SIZE - 1) downto 0));
end SCANFF;

architecture STRUCTURAL of SCANFF is
begin

    GEN : for i in 0 to (SIZE - 1) generate
        SFF : entity WORK.FLIP port map (CLK, D(i), Q(i));
    end generate;

end STRUCTURAL;
