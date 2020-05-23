library ieee;
use ieee.std_logic_1164.all;

entity keyexpansion is
    port (key_in  : in  std_logic_vector(127 downto 0);
          key_out : out std_logic_vector(127 downto 0));
end keyexpansion;

architecture parallel of keyexpansion is
begin

    key_out <= key_in(17 downto 16) &
               key_in(31 downto 18) &
               key_in(11 downto 0) &
               key_in(15 downto 12) &
               key_in(127 downto 32);

end parallel;
