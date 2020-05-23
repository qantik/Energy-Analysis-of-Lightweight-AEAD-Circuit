library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity FF is
    generic (SIZE : integer);
    port (CLK : in  std_logic;
          D   : in  std_logic_vector((SIZE - 1) downto 0);
          Q   : out std_logic_vector((SIZE - 1) downto 0));
end FF;

architecture STRUCTURAL of FF is
begin

    process (CLK)
    begin 
        if rising_edge(CLK) then
            Q <= D;
        end if;
    end process;

end STRUCTURAL;
