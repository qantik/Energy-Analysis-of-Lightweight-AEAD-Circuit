library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;               -- contains conversion functions

entity gbox2 is
  
  port (
    Inp1xDI : in  std_logic_vector(3 downto 0);
    Inp2xDI : in  std_logic_vector(3 downto 0);
    OupxDO : out std_logic_vector(3 downto 0)
    );

end gbox2;




architecture func of gbox2 is

signal  a1,b1,c1,d1,  a3,b3,c3,d3  : std_logic;

signal g23,g22,g21,g20: std_logic;
 

  
begin  -- lookuptable

 

a1 <= Inp1xDI(0);
b1 <= Inp1xDI(1);
c1 <= Inp1xDI(2);
d1 <= Inp1xDI(3);

a3 <= Inp2xDI(0);
b3 <= Inp2xDI(1);
c3 <= Inp2xDI(2);
d3 <= Inp2xDI(3);

 


g20 <= (a1) xor (b1) xor (c1) xor (d1) xor (a1 and b3) xor (a3 and b1) xor (a3 and b3);

g21 <= (b1) xor (a1 and c3) xor (a3 and c1) xor (a3 and c3);

g22 <= (c1);

g23 <= (a1) xor (b1) xor (b1 and c3) xor (b3 and c1) xor (b3 and c3);


 
OupxDO <= g23 & g22 & g21 & g20;

 
end architecture func;

 

