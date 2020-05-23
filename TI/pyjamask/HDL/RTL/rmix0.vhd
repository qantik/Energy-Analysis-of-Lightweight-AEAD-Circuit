--M0=cir([1,1,0,1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1,1,0,0,0,0,1,1,1,0,0,0,1,0]),
--M1=cir([0,1,0,0,0,0,1,0,0,0,0,0,0,1,1,1,0,1,0,0,0,0,0,1,0,1,1,0,0,0,1,1]),
--M2=cir([0,0,0,0,0,0,0,0,1,0,1,0,0,1,1,1,1,0,0,1,1,0,1,0,0,1,0,0,1,0,1,1]),
--M3=cir([0,1,1,0,0,1,0,0,0,0,0,0,1,0,0,1,0,1,0,1,0,0,1,0,1,0,0,0,1,0,0,1]).


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;               -- contains conversion functions

entity rmix0 is
  
  port (
    InpxDI : in  std_logic_vector(31 downto 0);
    OupxDO : out std_logic 
    );

end rmix0;



architecture rm of rmix0 is

 

  
begin  

OupxDO <= InpxDI(31) xor InpxDI(30) xor InpxDI(28) xor InpxDI(23) xor InpxDI(18) xor InpxDI(13) xor InpxDI(12) xor InpxDI(7) xor InpxDI(6) xor InpxDI(5) xor InpxDI(1) ;


end architecture rm;

