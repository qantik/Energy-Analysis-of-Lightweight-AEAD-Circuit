library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;               -- contains conversion functions

entity gbox1 is
  
  port (
    Inp1xDI : in  std_logic_vector(3 downto 0);
    Inp2xDI : in  std_logic_vector(3 downto 0);
    OupxDO : out std_logic_vector(3 downto 0)
    );

end gbox1;




architecture func of gbox1 is

signal  a2,b2,c2,d2,  a3,b3,c3,d3  : std_logic;

signal g13,g12,g11,g10: std_logic;
 

  
begin  -- lookuptable

 

a2 <= Inp1xDI(0);
b2 <= Inp1xDI(1);
c2 <= Inp1xDI(2);
d2 <= Inp1xDI(3);

a3 <= Inp2xDI(0);
b3 <= Inp2xDI(1);
c3 <= Inp2xDI(2);
d3 <= Inp2xDI(3);

 

g10 <= (a3) xor (b3) xor (c3) xor (d3) xor (a2 and b2) xor (a2 and b3) xor (a3 and b2);

g11 <= (b3) xor (a2 and c2) xor (a2 and c3) xor (a3 and c2);

g12 <=  '1'  xor (c3);

g13 <= (a3) xor (b3) xor (b2 and c2) xor (b2 and c3) xor (b3 and c2);



 
OupxDO <= g13 & g12 & g11 & g10;

 
end architecture func;

 

