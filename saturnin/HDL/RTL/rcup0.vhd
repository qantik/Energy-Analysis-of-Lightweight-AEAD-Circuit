library ieee;
use ieee.std_logic_1164.all;
 
use ieee.numeric_std.all;
use std.textio.all;
use work.all;

entity rcup0 is
port ( InpxDI : in  std_logic_vector(15 downto 0);
       OupxDO : out std_logic_vector(15 downto 0));
end entity rcup0;


architecture rc of rcup0 is



type rcup is array (0 to 16) of std_logic_vector(15 downto 0);
signal R: rcup;

begin

R(0)<= InpxDI;

ll: for i in 1 to 16 generate

R(i)<= R(i-1)(14 downto 0) & "0" when R(i-1)(15)='0' else  (R(i-1)(14 downto 0) & "0") xor x"002d";

end generate ll;

OupxDO<= R(16);

end architecture rc;


