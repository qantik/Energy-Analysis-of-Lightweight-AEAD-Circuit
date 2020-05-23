--M0=cir([1,1,0,1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1,1,0,0,0,0,1,1,1,0,0,0,1,0]),
--M1=cir([0,1,0,0,0,0,1,0,0,0,0,0,0,1,1,1,0,1,0,0,0,0,0,1,0,1,1,0,0,0,1,1]),
--M2=cir([0,0,0,0,0,0,0,0,1,0,1,0,0,1,1,1,1,0,0,1,1,0,1,0,0,1,0,0,1,0,1,1]),
--M3=cir([0,1,1,0,0,1,0,0,0,0,0,0,1,0,0,1,0,1,0,1,0,0,1,0,1,0,0,0,1,0,0,1]).


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;               -- contains conversion functions

entity rmix1 is
  
  port (
    InpxDI : in  std_logic_vector(31 downto 0);
    OupxDO : out std_logic 
    );

end rmix1;



architecture rm of rmix1 is

 

  
begin  

OupxDO <= InpxDI(30) xor InpxDI(25) xor InpxDI(18) xor InpxDI(17) xor InpxDI(16) xor InpxDI(14) xor InpxDI(8) xor InpxDI(6) xor InpxDI(5) xor InpxDI(1) xor InpxDI(0) ;


end architecture rm;

