library ieee;
use ieee.std_logic_1164.all;
 
use ieee.numeric_std.all;
use std.textio.all;
use work.all;

entity Flayer3 is
port ( Inp1xDI : in  std_logic_vector(127 downto 0);
       Inp2xDI : in  std_logic_vector(127 downto 0);
 
       OupxDO : out std_logic_vector(127 downto 0));
end entity Flayer3;

architecture fl of Flayer3 is 

 
type Atype is array (0 to 31) of std_logic_vector(3 downto 0);

signal A1,A2, B: Atype; 

begin 


loop1: for i in 0 to 31 generate 

A1(i)<= Inp1xDI(i) & Inp1xDI(i+32) & Inp1xDI(i+64) & Inp1xDI(i+96);
A2(i)<= Inp2xDI(i) & Inp2xDI(i+32) & Inp2xDI(i+64) & Inp2xDI(i+96);
 


i_sbox: entity fbox3(func) port map (A1(i),A2(i),  B(i));

OupxDO(i)<=B(i)(3);
OupxDO(i+32)<=B(i)(2);
OupxDO(i+64)<=B(i)(1);
OupxDO(i+96)<=B(i)(0);

 

end generate loop1;

end architecture fl;
