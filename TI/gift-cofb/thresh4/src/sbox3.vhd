library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;               -- contains conversion functions

entity sbox3 is
  
  port (
    Inp1xDI : in  std_logic_vector(3 downto 0);
    Inp2xDI : in  std_logic_vector(3 downto 0);
    Inp3xDI : in  std_logic_vector(3 downto 0);
    OupxDO : out std_logic_vector(3 downto 0)
    );

end sbox3;




architecture func of sbox3 is

signal  a1,b1,c1,d1,  a2,b2,c2,d2,   a4,b4,c4,d4 : std_logic;

signal s33,s32,s31,s30: std_logic;
 

  
begin  -- lookuptable

 

a1 <= Inp1xDI(0);
b1 <= Inp1xDI(1);
c1 <= Inp1xDI(2);
d1 <= Inp1xDI(3);

a2 <= Inp2xDI(0);
b2 <= Inp2xDI(1);
c2 <= Inp2xDI(2);
d2 <= Inp2xDI(3);

a4 <= Inp3xDI(0);
b4 <= Inp3xDI(1);
c4 <= Inp3xDI(2);
d4 <= Inp3xDI(3);


 
s30 <= (a4) xor (b4) xor (c4) xor (d4) xor (a4 and b4) xor (a4 and b1) xor (a4 and b2) xor (a2 and b1);


s31 <= (a4) xor (c4) xor (d4) xor (a4 and b4) xor (a4 and b1) xor (a4 and b2) xor (a2 and b1) xor (a4 and c4) xor (a4 and c1) xor (a4 and c2) xor (a2 and c1);


s32 <= (b4) xor (c4) xor (a4 and d4) xor (a4 and d1) xor (a4 and d2) xor (b4 and d4) xor (b4 and d1) xor (b4 and d2) xor (a2 and d1) xor (b2 and d1) xor (b4 and c4 and d4) xor (b4 and c1 and d4) xor (b4 and c2 and d4) xor (b1 and c2 and d4) xor (b2 and c1 and d4) xor (b4 and c4 and d1) xor (b4 and c1 and d1) xor (b4 and c2 and d1) xor (b2 and c4 and d1) xor (b2 and c1 and d1) xor (b2 and c2 and d1) xor (b4 and c4 and d2) xor (b4 and c1 and d2) xor (b4 and c2 and d2) xor (b1 and c4 and d2) xor (b2 and c1 and d2);



s33 <= (a4) xor (b4 and d4) xor (b4 and d1) xor (b4 and d2) xor (b2 and d1) xor (a4 and c4 and d4) xor (a4 and c1 and d4) xor (a4 and c2 and d4) xor (a1 and c2 and d4) xor (a2 and c1 and d4) xor (a4 and c4 and d1) xor (a4 and c1 and d1) xor (a4 and c2 and d1) xor (a2 and c4 and d1) xor (a2 and c1 and d1) xor (a2 and c2 and d1) xor (a4 and c4 and d2) xor (a4 and c1 and d2) xor (a4 and c2 and d2) xor (a1 and c4 and d2) xor (a2 and c1 and d2);




 
OupxDO <= s33 & s32 & s31 & s30;

 
end architecture func;

 

