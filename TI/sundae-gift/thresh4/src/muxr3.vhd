library ieee;
use ieee.std_logic_1164.all;

entity muxr3 is
    generic (r : integer := 3);
    port (a   : in std_logic_vector(127 downto 0);
	  b   : in std_logic_vector(127 downto 0);
          sel : in std_logic;
	  c   : out std_logic_vector(127 downto 0));
end;

architecture parallel of muxr3 is
begin
	c <= a when sel = '0' else b;
end;
