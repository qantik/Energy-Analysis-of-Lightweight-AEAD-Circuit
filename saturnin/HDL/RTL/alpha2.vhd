library ieee;
use ieee.std_logic_1164.all;
 
use ieee.numeric_std.all;
use std.textio.all;
use work.all;

entity alpha2 is
port ( InpxDI : in  std_logic_vector(63 downto 0);
       OupxDO : out std_logic_vector(63 downto 0));
end entity alpha2;

architecture a of alpha2 is

signal A,B: std_logic_vector(63 downto 0);

begin


x1: entity alpha (a) port map (InpxDI, A);
x2: entity alpha (a) port map (A, B);
 
OupxDO<= B;

end architecture a;
