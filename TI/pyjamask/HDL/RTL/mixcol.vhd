library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;               -- contains conversion functions
use work.all;

entity Mixcol is
  
  port (
    InpxDI : in  std_logic_vector(127 downto 0);
    OupxDO : out std_logic_vector(127 downto 0)
    );

end Mixcol;


architecture mc of Mixcol is

type Coltype is array (0 to 31) of std_logic_vector(3 downto 0);
signal IxD,OxD: Coltype;

 

begin

loop1: for i in 0 to 31 generate 


IxD(i) <= InpxDI(127-i)  & InpxDI(95-i)  &  InpxDI(63-i)  & InpxDI(31-i);
a0: entity Amds (a01) port map (IxD(i),OxD(i));

OupxDO(127-i) <= OxD(i)(3);
OupxDO(95-i) <= OxD(i)(2);
OupxDO(63-i) <= OxD(i)(1);
OupxDO(31-i) <= OxD(i)(0);

end generate loop1;
 


end architecture mc ;
 
