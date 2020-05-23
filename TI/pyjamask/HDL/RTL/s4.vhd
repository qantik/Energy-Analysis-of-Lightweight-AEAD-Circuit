library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;               -- contains conversion functions
use work.all;

entity s4 is
  
  port (
    InpxDI : in  std_logic_vector(3 downto 0);
    OupxDO : out std_logic_vector(3 downto 0)
    );

end s4;


architecture com of s4 is

 
  subtype Int4Type is integer range 0 to 15;
  type Int4Array is array (0 to 15) of Int4Type;
  constant SBOX : Int4Array := (
2 , 13,	3 , 9,
7 , 11, 10, 6,
14, 0 , 15, 4,
8 , 5 , 1 , 12
 
 
);

  
begin  -- lookuptable

  OupxDO <= std_logic_vector(to_unsigned(SBOX(to_integer(unsigned(InpxDI(3 downto 0)))), 4));

end architecture com;

