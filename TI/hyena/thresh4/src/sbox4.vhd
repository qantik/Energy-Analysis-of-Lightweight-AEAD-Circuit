library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;               -- contains conversion functions

entity sbox4 is
  
  port (
    Inp1xDI : in  std_logic_vector(3 downto 0);
    Inp2xDI : in  std_logic_vector(3 downto 0);
    Inp3xDI : in  std_logic_vector(3 downto 0);
    OupxDO : out std_logic_vector(3 downto 0)
    );

end sbox4;




architecture func of sbox4 is

signal  a1,b1,c1,d1,  a2,b2,c2,d2,   a3,b3,c3,d3 : std_logic;

signal s43,s42,s41,s40: std_logic;
 

  
begin  -- lookuptable

 

a1 <= Inp1xDI(0);
b1 <= Inp1xDI(1);
c1 <= Inp1xDI(2);
d1 <= Inp1xDI(3);

a2 <= Inp2xDI(0);
b2 <= Inp2xDI(1);
c2 <= Inp2xDI(2);
d2 <= Inp2xDI(3);

a3 <= Inp3xDI(0);
b3 <= Inp3xDI(1);
c3 <= Inp3xDI(2);
d3 <= Inp3xDI(3);


 
s40 <= (a1) xor (b1) xor (c1) xor (d1) xor (a1 and b1) xor (a1 and b2) xor (a1 and b3) xor (a3 and b2);

s41 <= (a1) xor (c1) xor (d1) xor (a1 and b1) xor (a1 and b2) xor (a1 and b3) xor (a3 and b2) xor (a1 and c1) xor (a1 and c2) xor (a1 and c3) xor (a3 and c2);


s42 <= (b1) xor (c1) xor (a1 and d1) xor (a1 and d2) xor (a1 and d3) xor (b1 and d1) xor (b1 and d2) xor (b1 and d3) xor (a3 and d2) xor (b3 and d2) xor (b1 and c1 and d1) xor (b1 and c2 and d1) xor (b1 and c3 and d1) xor (b2 and c3 and d1) xor (b3 and c2 and d1) xor (b1 and c1 and d2) xor (b1 and c2 and d2) xor (b1 and c3 and d2) xor (b3 and c1 and d2) xor (b3 and c2 and d2) xor (b3 and c3 and d2) xor (b1 and c1 and d3) xor (b1 and c2 and d3) xor (b1 and c3 and d3) xor (b2 and c1 and d3) xor (b3 and c2 and d3);


s43 <= (a1) xor (b1 and d1) xor (b1 and d2) xor (b1 and d3) xor (b3 and d2) xor (a1 and c1 and d1) xor (a1 and c2 and d1) xor (a1 and c3 and d1) xor (a2 and c3 and d1) xor (a3 and c2 and d1) xor (a1 and c1 and d2) xor (a1 and c2 and d2) xor (a1 and c3 and d2) xor (a3 and c1 and d2) xor (a3 and c2 and d2) xor (a3 and c3 and d2) xor (a1 and c1 and d3) xor (a1 and c2 and d3) xor (a1 and c3 and d3) xor (a2 and c1 and d3) xor (a3 and c2 and d3);




 
OupxDO <= s43 & s42 & s41 & s40;

 
end architecture func;

 

