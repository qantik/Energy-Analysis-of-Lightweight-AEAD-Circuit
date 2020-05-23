library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity RFF is
    generic (SIZE : integer);
    port (CLK : in  std_logic;
          RST : in  std_logic;
          D   : in  std_logic_vector((SIZE - 1) downto 0);
          Q   : out std_logic_vector((SIZE - 1) downto 0));
end RFF;

architecture STRUCTURAL of RFF is
begin

    process (CLK, RST)
    begin 
        if RST = '0' then
            Q <= ( others => '0');
        elsif rising_edge(CLK) then
            Q <= D;
        end if;
    end process;

end STRUCTURAL;
