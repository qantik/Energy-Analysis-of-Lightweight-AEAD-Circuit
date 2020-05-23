library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;               -- contains conversion functions

entity fbox1 is
  
  port (
    Inp1xDI : in  std_logic_vector(3 downto 0);
    Inp2xDI : in  std_logic_vector(3 downto 0);
    OupxDO : out std_logic_vector(3 downto 0)
    );

end fbox1;




architecture func of fbox1 is

signal  a2,b2,c2,d2,  a3,b3,c3,d3  : std_logic;

signal f13,f12,f11,f10: std_logic;
 

  
begin  -- lookuptable

 

a2 <= Inp1xDI(0);
b2 <= Inp1xDI(1);
c2 <= Inp1xDI(2);
d2 <= Inp1xDI(3);

a3 <= Inp2xDI(0);
b3 <= Inp2xDI(1);
c3 <= Inp2xDI(2);
d3 <= Inp2xDI(3);

 


f10 <=  '1'  xor (a3);

f11 <= (a3) xor (b3);

f12 <=  '1'  xor (b3) xor (c3) xor (d3) xor (a2 and d2) xor (a2 and d3) xor (a3 and d2);

f13 <= (d3) xor (a2 and b2) xor (a2 and b3) xor (a3 and b2);


 
OupxDO <= f13 & f12 & f11 & f10;

 
end architecture func;

 

