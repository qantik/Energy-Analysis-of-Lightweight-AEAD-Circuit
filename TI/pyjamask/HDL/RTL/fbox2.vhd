library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;               -- contains conversion functions

entity fbox2 is
  
  port (
    Inp1xDI : in  std_logic_vector(3 downto 0);
    Inp2xDI : in  std_logic_vector(3 downto 0);
    OupxDO : out std_logic_vector(3 downto 0)
    );

end fbox2;




architecture func of fbox2 is

signal  a1,b1,c1,d1,  a3,b3,c3,d3  : std_logic;

signal f23,f22,f21,f20: std_logic;
 

  
begin  -- lookuptable

 

a1 <= Inp1xDI(0);
b1 <= Inp1xDI(1);
c1 <= Inp1xDI(2);
d1 <= Inp1xDI(3);

a3 <= Inp2xDI(0);
b3 <= Inp2xDI(1);
c3 <= Inp2xDI(2);
d3 <= Inp2xDI(3);

 


f20 <= (a1) xor (b1) xor (c3 and d3) xor (c3 and d1) xor (c1 and d3);

f21 <= (d1);

f22 <=  (a1) xor (b1) xor (c1)  xor (a3 and d3) xor (a3 and d1) xor (a1 and d3);

f23 <= (a1) xor (c1);-- (a2 and b2) xor (a2 and b3) xor (a3 and b2);


 
OupxDO <= f23 & f22 & f21 & f20;

 
end architecture func;

 

