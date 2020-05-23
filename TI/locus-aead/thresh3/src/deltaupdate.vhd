library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity deltaupdate is
  port (delta_in  : in  std_logic_vector(127 downto 0);
        delta_out : out std_logic_vector(127 downto 0));
end deltaupdate;

architecture parallel of deltaupdate is

    constant cst : std_logic_vector(127 downto 0) := X"00000000000000000000000000000087";
    
begin

    delta_out <= (delta_in(126 downto 0) & "0") xor (cst and (127 downto 0 => delta_in(127))); 

end architecture parallel;
