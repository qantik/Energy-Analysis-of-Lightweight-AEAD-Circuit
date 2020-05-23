library ieee;
use ieee.std_logic_1164.all;
 
use ieee.numeric_std.all;
use std.textio.all;
use work.all;

entity Slayer is
port ( InpxDI : in  std_logic_vector(127 downto 0);
       OupxDO : out std_logic_vector(127 downto 0));
end entity Slayer;

architecture sl of Slayer is 
 
type Sigtype is array (0 to 31) of std_logic_vector(3 downto 0);
signal InxD,OpxD: Sigtype;

begin 


loop1: for i in 0 to 31 generate 

InxD(i)<= InpxDI(127 - i) & InpxDI(95 - i)    & InpxDI(63 - i)  & InpxDI(31 - i) ;

i_sbox: entity s4 (com) port map (InxD(i), OpxD(i));

OupxDO(127-i) <= OpxD(i)(3);
OupxDO(95-i) <= OpxD(i)(2);
OupxDO(63-i) <= OpxD(i)(1);
OupxDO(31-i) <= OpxD(i)(0); 
end generate loop1;

end architecture sl;
