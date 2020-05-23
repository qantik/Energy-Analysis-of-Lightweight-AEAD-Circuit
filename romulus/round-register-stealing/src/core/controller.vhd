library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity ControlLogic is
    port (CST_in : in std_logic_vector(5 downto 0);
          CST_out : out std_logic_vector (5 downto 0));
end ControlLogic;

architecture Round of ControlLogic is
begin

    CST_out <= CST_in(4 downto 0) & (CST_in(5) xnor CST_in(4));

end Round;
