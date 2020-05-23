library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;               -- contains conversion functions

entity gbox3 is
  
  port (
    Inp1xDI : in  std_logic_vector(3 downto 0);
    Inp2xDI : in  std_logic_vector(3 downto 0);
    OupxDO : out std_logic_vector(3 downto 0)
    );

end gbox3;




architecture func of gbox3 is

signal  a2,b2,c2,d2,  a1,b1,c1,d1  : std_logic;

signal g33,g32,g31,g30: std_logic;
 

  
begin  -- lookuptable

 

a1 <= Inp1xDI(0);
b1 <= Inp1xDI(1);
c1 <= Inp1xDI(2);
d1 <= Inp1xDI(3);

a2 <= Inp2xDI(0);
b2 <= Inp2xDI(1);
c2 <= Inp2xDI(2);
d2 <= Inp2xDI(3);

 


g30 <= (a2) xor (b2) xor (c2) xor (d2) xor (a1 and b1) xor (a1 and b2) xor (a2 and b1);

g31 <= (b2) xor (a1 and c1) xor (a1 and c2) xor (a2 and c1);

g32 <= (c2);

g33 <= (a2) xor (b2) xor (b1 and c1) xor (b1 and c2) xor (b2 and c1);


 
OupxDO <= g33 & g32 & g31 & g30;

 
end architecture func;

 

