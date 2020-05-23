library ieee;
use ieee.std_logic_1164.all;
 
use ieee.numeric_std.all;
use std.textio.all;
use work.all;

entity alpha is
port ( InpxDI : in  std_logic_vector(63 downto 0);
       OupxDO : out std_logic_vector(63 downto 0));
end entity alpha;

architecture a of alpha is

signal A: std_logic_vector(15 downto 0);

begin

A <= InpxDI(63 downto 48) xor InpxDI(47 downto 32);

OupxDO<= InpxDI(47 downto 0) & A;


end architecture a;
