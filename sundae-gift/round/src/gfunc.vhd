library ieee;
use ieee.std_logic_1164.all;

use ieee.numeric_std.all;
use std.textio.all;
use work.all;


entity Gfunc is
  port (
         DinxDI      : in  std_logic_vector(127 downto 0);
 
         DoutxDO     : out std_logic_vector(127 downto 0)
        
       );
end Gfunc;

architecture gf of Gfunc is


 

signal MxD , LxD : std_logic_vector(63 downto 0);



begin
 

  MxD <= DinxDI(63 downto 0);
  --LxD <= DinxDI(64) & DinxDI(127 downto 65);
LxD <=  DinxDI(126 downto 64) & DinxDI(127);
  DoutxDO<= MxD & LxD; 

end architecture gf;
