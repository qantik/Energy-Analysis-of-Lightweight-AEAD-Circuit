library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;               -- contains conversion functions
use work.all;

entity s1 is
  
  port (
    InpxDI : in  std_logic_vector(3 downto 0);
    OupxDO : out std_logic_vector(3 downto 0)
    );

end s1;


architecture com of s1 is

 
  subtype Int4Type is integer range 0 to 15;
  type Int4Array is array (0 to 15) of Int4Type;
  constant SBOX : Int4Array := (
0,9,13,2,
15,1,11,7,
6,4,5,3,
8,12,10,14
 
 
);

SIGNAL OupxD,InpxD: std_logic_vector(3 downto 0);

begin  -- lookuptable

  InpxD  <=  InpxDI(0) & InpxDI(1) & InpxDI(2) & InpxDI(3);
  
  OupxD  <= std_logic_vector(to_unsigned(SBOX(to_integer(unsigned(InpxD(3 downto 0)))), 4));

  OupxDO <= OupxD(0) & OupxD(1) & OupxD(2) & OupxD(3);
end architecture com;

