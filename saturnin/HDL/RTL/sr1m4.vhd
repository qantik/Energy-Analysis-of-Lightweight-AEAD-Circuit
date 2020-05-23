library ieee;
use ieee.std_logic_1164.all;
 
use ieee.numeric_std.all;
use std.textio.all;
use work.all;

entity Sr1m4 is
port ( InpxDI : in  std_logic_vector(255 downto 0);
       OupxDO : out std_logic_vector(255 downto 0));
end entity Sr1m4;

architecture s1 of Sr1m4 is 

subtype nibble is std_logic_vector(3 downto 0);
 
type Slicetype is array (0 to 15) of nibble;
type Statetype is array (0 to 3) of Slicetype;


signal InxD,OpxD: Statetype;
  
  subtype Int4Type is integer range 0 to 15;
  type Int4Array is array (0 to 15) of Int4Type;
  constant Perm : Int4Array := (
 
 0, 13, 10, 7, 4, 1, 14, 11, 8, 5, 2, 15, 12, 9, 6, 3 
 
);

begin


loop1: for i in 0 to 3 generate 
   loop2: for j in 0 to 15 generate 
	InxD(i)(j) <= InpxDI(255 -64*i-4*j downto 252 -64*i-4*j);
        OupxDO(255 -64*i-4*j downto 252 -64*i-4*j)<= OpxD(i)(j);
   end generate loop2;
end generate loop1;

 
   loop4: for j in 0 to 15 generate 

        OpxD(0)(j) <= InxD(0)(j)  ; 
        OpxD(1)(j) <= InxD(1)(j)(2 downto 0) &  InxD(1)(j)(3) ; 
        OpxD(2)(j) <= InxD(2)(j)(1 downto 0) &  InxD(2)(j)(3 downto 2) ; 
        OpxD(3)(j) <= InxD(3)(j)(0) &  InxD(3)(j)(3 downto 1) ; 
 
   end generate loop4;
 




end architecture s1;







