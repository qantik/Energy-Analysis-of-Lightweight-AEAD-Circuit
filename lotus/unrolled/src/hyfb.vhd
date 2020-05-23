library ieee;
use ieee.std_logic_1164.all;

entity hyfb is
    port(y     : in std_logic_vector(127 downto 0);
         delta : in std_logic_vector(63 downto 0);
         m     : in std_logic_vector(127 downto 0);

         x : out std_logic_vector(127 downto 0);
         c : out std_logic_vector(127 downto 0));
end;

architecture parallel of hyfb is
    signal tmp, b : std_logic_vector(127 downto 0);
begin
    

    tmp <= m xor y;
    b   <= m(127 downto 64) & (tmp(63 downto 0) xor delta);
    --b   <= m(63 downto 0) & (tmp(63 downto 0) xor delta);
    --b   <= (tmp(127 downto 64) xor delta) & m(63 downto 0);

    x <= b xor y;
    c <= tmp;
    
end architecture parallel;

