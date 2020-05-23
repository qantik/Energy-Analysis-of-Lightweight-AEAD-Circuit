--M0=cir([1,1,0,1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1,1,0,0,0,0,1,1,1,0,0,0,1,0]),
--M1=cir([0,1,0,0,0,0,1,0,0,0,0,0,0,1,1,1,0,1,0,0,0,0,0,1,0,1,1,0,0,0,1,1]),
--M2=cir([0,0,0,0,0,0,0,0,1,0,1,0,0,1,1,1,1,0,0,1,1,0,1,0,0,1,0,0,1,0,1,1]),
--M3=cir([0,1,1,0,0,1,0,0,0,0,0,0,1,0,0,1,0,1,0,1,0,0,1,0,1,0,0,0,1,0,0,1]).

--MK=cir([1,0,1,0,1,0,0,1,1,1,0,0,1,1,1,0,1,1,0,0,0,0,0,0,1,0,0,0,1,1,1,0])

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;               -- contains conversion functions

entity rmixk is
  
  port (
    InpxDI : in  std_logic_vector(31 downto 0);
    OupxDO : out std_logic 
    );

end rmixk;



architecture rm of rmixk is

 

  
begin  

OupxDO <= InpxDI(31) xor InpxDI(29) xor InpxDI(27) xor InpxDI(24) xor InpxDI(23) xor InpxDI(22) xor InpxDI(19) xor InpxDI(18) xor InpxDI(17) xor InpxDI(15)  xor InpxDI(14) xor InpxDI(7) xor InpxDI(3) xor InpxDI(2)  xor InpxDI(1) ;


end architecture rm;

