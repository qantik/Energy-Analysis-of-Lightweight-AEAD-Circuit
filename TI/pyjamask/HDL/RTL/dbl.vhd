library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;               -- contains conversion functions
use work.all;

entity dbl is
  
  port (
    InpxDI : in  std_logic_vector(127 downto 0);
    OupxDO : out std_logic_vector(127 downto 0)
    );

end dbl;


architecture func of dbl is


signal ShiftxD:  std_logic_vector(127 downto 0);
signal AddxD, SumxD:  std_logic_vector(7 downto 0);

begin  --  
 
ShiftxD<= InpxDI(126 downto 0) & InpxDI(127);

AddxD <= InpxDI(127) & "0000" &   InpxDI(127) &   InpxDI(127) &  '0';

SumxD <= ShiftxD(7 downto 0) xor AddxD;

OupxDO<= ShiftxD(127 downto 8) & SumxD;


end architecture func;
