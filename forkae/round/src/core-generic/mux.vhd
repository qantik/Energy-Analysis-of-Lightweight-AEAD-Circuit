library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity MUX is
    port (
          Sel      : in std_logic_vector(1 downto 0);
          D0       : in std_logic_vector (127 downto 0);
          D1       : in std_logic_vector (127 downto 0);
          D2       : in std_logic_vector (127 downto 0);
          D3       : in std_logic_vector (127 downto 0);
          
          Q        : out std_logic_vector (127 downto 0));
end MUX;

architecture STRUCTURAL of MUX is


begin

process (Sel, D0, D1, D2, D3)
begin
    case Sel is 
        when "00" =>
            Q <= D0;
        when "01" =>
            Q <= D1;
        when "10" =>
            Q <= D2;
        when others =>
            Q <= D3; 
    end case;
end process;


end STRUCTURAL;
