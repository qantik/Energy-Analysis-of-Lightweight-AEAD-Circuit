library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;               -- contains conversion functions

entity sbox2 is
  
  port (
    Inp1xDI : in  std_logic_vector(3 downto 0);
    Inp2xDI : in  std_logic_vector(3 downto 0);
    Inp3xDI : in  std_logic_vector(3 downto 0);
    OupxDO : out std_logic_vector(3 downto 0)
    );

end sbox2;




architecture func of sbox2 is

signal  a1,b1,c1,d1,  a3,b3,c3,d3,   a4,b4,c4,d4 : std_logic;

signal s23,s22,s21,s20: std_logic;
 

  
begin  -- lookuptable

 

a1 <= Inp1xDI(0);
b1 <= Inp1xDI(1);
c1 <= Inp1xDI(2);
d1 <= Inp1xDI(3);

a3 <= Inp2xDI(0);
b3 <= Inp2xDI(1);
c3 <= Inp2xDI(2);
d3 <= Inp2xDI(3);

a4 <= Inp3xDI(0);
b4 <= Inp3xDI(1);
c4 <= Inp3xDI(2);
d4 <= Inp3xDI(3);


s20 <= (a3) xor (b3) xor (c3) xor (d3) xor (a3 and b3) xor (a3 and b4) xor (a3 and b1) xor (a1 and b4);

s21 <= (a3) xor (c3) xor (d3) xor (a3 and b3) xor (a3 and b4) xor (a3 and b1) xor (a1 and b4) xor (a3 and c3) xor (a3 and c4) xor (a3 and c1) xor (a1 and c4);


s22 <= (b3) xor (c3) xor (a3 and d3) xor (a3 and d4) xor (a3 and d1) xor (b3 and d3) xor (b3 and d4) xor (b3 and d1) xor (a1 and d4) xor (b1 and d4) xor (b3 and c3 and d3) xor (b3 and c4 and d3) xor (b3 and c1 and d3) xor (b4 and c1 and d3) xor (b1 and c4 and d3) xor (b3 and c3 and d4) xor (b3 and c4 and d4) xor (b3 and c1 and d4) xor (b1 and c3 and d4) xor (b1 and c4 and d4) xor (b1 and c1 and d4) xor (b3 and c3 and d1) xor (b3 and c4 and d1) xor (b3 and c1 and d1) xor (b4 and c3 and d1) xor (b1 and c4 and d1);



s23 <= (a3) xor (b3 and d3) xor (b3 and d4) xor (b3 and d1) xor (b1 and d4) xor (a3 and c3 and d3) xor (a3 and c4 and d3) xor (a3 and c1 and d3) xor (a4 and c1 and d3) xor (a1 and c4 and d3) xor (a3 and c3 and d4) xor (a3 and c4 and d4) xor (a3 and c1 and d4) xor (a1 and c3 and d4) xor (a1 and c4 and d4) xor (a1 and c1 and d4) xor (a3 and c3 and d1) xor (a3 and c4 and d1) xor (a3 and c1 and d1) xor (a4 and c3 and d1) xor (a1 and c4 and d1);





 
OupxDO <= s23 & s22 & s21 & s20;

 
end architecture func;

 

