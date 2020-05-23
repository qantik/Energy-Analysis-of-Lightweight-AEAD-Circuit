library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;               -- contains conversion functions

entity fbox3 is
  
  port (
    Inp1xDI : in  std_logic_vector(3 downto 0);
    Inp2xDI : in  std_logic_vector(3 downto 0);
    OupxDO : out std_logic_vector(3 downto 0)
    );

end fbox3;




architecture func of fbox3 is

signal  a2,b2,c2,d2,  a1,b1,c1,d1 : std_logic;

signal f33,f32,f31,f30: std_logic;
 

  
begin  -- lookuptable

 

a1 <= Inp1xDI(0);
b1 <= Inp1xDI(1);
c1 <= Inp1xDI(2);
d1 <= Inp1xDI(3);

a2 <= Inp2xDI(0);
b2 <= Inp2xDI(1);
c2 <= Inp2xDI(2);
d2 <= Inp2xDI(3);

 


f30 <= (a2);

f31 <= (a2) xor (b2);

f32 <= (b2) xor (c2) xor (d2) xor (a1 and d1) xor (a1 and d2) xor (a2 and d1);

f33 <= (d2) xor (a1 and b1) xor (a1 and b2) xor (a2 and b1);

 
OupxDO <= f33 & f32 & f31 & f30;

 
end architecture func;

 

