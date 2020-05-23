library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;               -- contains conversion functions

entity s4_2 is
  
  port (
    Inp1xDI : in  std_logic_vector(3 downto 0);
    Inp2xDI : in  std_logic_vector(3 downto 0);
    Inp3xDI : in  std_logic_vector(3 downto 0);
    OupxDO : out std_logic_vector(3 downto 0)
    );

end s4_2;




architecture com of s4_2 is

signal  a2,b2,c2,d2,  a3,b3,c3,d3,   a4,b4,c4,d4 : std_logic;

signal s23,s22,s21,s20: std_logic;
 

  
begin  -- lookuptable

--x0  + x1  + x1 x0  + x2  + x2 x0  + x2 x1 x0  + x3 x0  + x3 x2  + 
--1  + x0  + x2 x0  + x3 x2  + 
--x0  + x1 x0  + x2  + x2 x1  + x2 x1 x0  + x3  + x3 x2 x1  + 
 --x0  + x2 x1  + x3  + 

 


a2 <= Inp2xDI(0);
b2 <= Inp2xDI(1);
c2 <= Inp2xDI(2);
d2 <= Inp2xDI(3);--3

a3 <= Inp3xDI(0);
b3 <= Inp3xDI(1);
c3 <= Inp3xDI(2);
d3 <= Inp3xDI(3);--4

a4 <= Inp1xDI(0);--1
b4 <= Inp1xDI(1);
c4 <= Inp1xDI(2);
d4 <= Inp1xDI(3);

s20<= (a2) xor (b2) xor (c2)  xor ((a2 and b2) xor (a2 and b3) xor (a2 and b4) xor (a4 and b3)) xor ( (a2 and c2) xor (a2 and c3) xor (a2 and c4) xor (a4 and c3) )  xor 

       ( (a2 and d2) xor (a2 and d3) xor (a2 and d4) xor (a4 and d3) ) xor ( (c2 and d2) xor (c2 and d3) xor (c2 and d4) xor (c4 and d3))  xor 

       (a2 and b2 and c2) xor (a2 and b3 and c2) xor (a2 and b4 and c2) xor (a3 and b4 and c2) xor (a4 and b3 and c2) xor (a2 and b2 and c3) xor (a2 and b3 and c3) xor (a2 and b4 and c3) xor 
       (a4 and b2 and c3) xor (a4 and b3 and c3) xor (a4 and b4 and c3) xor (a2 and b2 and c4) xor (a2 and b3 and c4) xor (a2 and b4 and c4) xor (a3 and b2 and c4) xor (a4 and b3 and c4);

s21<=   (a2)  xor (a2 and c2) xor (a2 and c3) xor (a2 and c4) xor (a4 and c3) xor (c2 and d2) xor (c2 and d3) xor (c2 and d4) xor (c4 and d3);


s22<= (a2) xor (c2) xor (d2) xor ((a2 and b2) xor (a2 and b3) xor (a2 and b4) xor (a4 and b3)) xor ((b2 and c2) xor (b2 and c3) xor (b2 and c4) xor (b4 and c3))

      xor  (a2 and b2 and c2) xor (a2 and b3 and c2) xor (a2 and b4 and c2) xor (a3 and b4 and c2) xor (a4 and b3 and c2) xor (a2 and b2 and c3) xor (a2 and b3 and c3) xor (a2 and b4 and c3) xor 
       (a4 and b2 and c3) xor (a4 and b3 and c3) xor (a4 and b4 and c3) xor (a2 and b2 and c4) xor (a2 and b3 and c4) xor (a2 and b4 and c4) xor (a3 and b2 and c4) xor (a4 and b3 and c4)
       
      xor (b2 and c2 and d2) xor (b2 and c3 and d2) xor (b2 and c4 and d2) xor (b3 and c4 and d2) xor (b4 and c3 and d2) xor (b2 and c2 and d3) xor (b2 and c3 and d3) xor (b2 and c4 and d3) xor (b4 and c2 and d3) xor (b4 and c3 and d3) xor (b4 and c4 and d3) xor (b2 and c2 and d4) xor (b2 and c3 and d4) xor (b2 and c4 and d4) xor (b3 and c2 and d4) xor (b4 and c3 and d4);



s23<= (a2) xor (d2) xor ((b2 and c2) xor (b2 and c3) xor (b2 and c4) xor (b4 and c3));


 
OupxDO <= s23 & s22 & s21 & s20;

 
end architecture com;

 

