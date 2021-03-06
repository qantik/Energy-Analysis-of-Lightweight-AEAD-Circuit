library ieee;
use ieee.std_logic_1164.all;
 
use ieee.numeric_std.all;
use std.textio.all;
use work.all;

entity Slayer1 is
port ( Inp2xDI : in  std_logic_vector(127 downto 0);
       Inp3xDI : in  std_logic_vector(127 downto 0);
       Inp4xDI : in  std_logic_vector(127 downto 0);   
       OupxDO : out std_logic_vector(127 downto 0));
end entity Slayer1;

architecture sl of Slayer1 is 
 
type Sigtype is array (0 to 31) of std_logic_vector(3 downto 0);
signal In2xD,In3xD, In4xD, OpxD: Sigtype;

begin 


loop1: for i in 0 to 31 generate 

In2xD(i)<= Inp2xDI(127 - i) & Inp2xDI(95 - i)    & Inp2xDI(63 - i)  & Inp2xDI(31 - i) ;
In3xD(i)<= Inp3xDI(127 - i) & Inp3xDI(95 - i)    & Inp3xDI(63 - i)  & Inp3xDI(31 - i) ;
In4xD(i)<= Inp4xDI(127 - i) & Inp4xDI(95 - i)    & Inp4xDI(63 - i)  & Inp4xDI(31 - i) ;

i_sbox: entity s4_1 (com) port map (In2xD(i),In3xD(i),In4xD(i), OpxD(i));

OupxDO(127-i) <= OpxD(i)(3);
OupxDO(95-i) <= OpxD(i)(2);
OupxDO(63-i) <= OpxD(i)(1);
OupxDO(31-i) <= OpxD(i)(0); 
end generate loop1;

end architecture sl;
