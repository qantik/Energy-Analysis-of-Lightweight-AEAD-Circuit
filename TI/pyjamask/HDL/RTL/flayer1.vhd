library ieee;
use ieee.std_logic_1164.all;
 
use ieee.numeric_std.all;
use std.textio.all;
use work.all;

entity Flayer1 is
port ( Inp1xDI : in  std_logic_vector(127 downto 0);
       Inp2xDI : in  std_logic_vector(127 downto 0);
 
       OupxDO : out std_logic_vector(127 downto 0));
end entity Flayer1;

architecture fl of Flayer1 is 

 
type Sigtype is array (0 to 31) of std_logic_vector(3 downto 0);
signal In1xD,In2xD,    OpxD: Sigtype;

begin 


loop1: for i in 0 to 31 generate 

In1xD(i)<= Inp1xDI(127 - i) & Inp1xDI(95 - i)    & Inp1xDI(63 - i)  & Inp1xDI(31 - i) ;
In2xD(i)<= Inp2xDI(127 - i) & Inp2xDI(95 - i)    & Inp2xDI(63 - i)  & Inp2xDI(31 - i) ;
 

i_sbox: entity fbox1 (func) port map (In1xD(i),In2xD(i),  OpxD(i));

OupxDO(127-i) <= OpxD(i)(3);
OupxDO(95-i) <= OpxD(i)(2);
OupxDO(63-i) <= OpxD(i)(1);
OupxDO(31-i) <= OpxD(i)(0); 
end generate loop1;

end architecture fl;
