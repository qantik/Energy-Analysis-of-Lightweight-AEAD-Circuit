library ieee;
use ieee.std_logic_1164.all;
 
use ieee.numeric_std.all;
use std.textio.all;
use work.all;

entity Sr3m4i is
port ( InpxDI : in  std_logic_vector(255 downto 0);
       OupxDO : out std_logic_vector(255 downto 0));
end entity Sr3m4i;

architecture s3 of Sr3m4i is 


subtype nibble is std_logic_vector(3 downto 0);

type Slicetype is array (0 to 15) of nibble;
type Statetype is array (0 to 3) of Slicetype;

  signal InxD,OpxD: Statetype;
 

  subtype Int4Type is integer range 0 to 15;
  type Int4Array is array (0 to 15) of Int4Type;
  constant Perm1 : Int4Array := (
 
  1,2,3,0, 5,6,7,4, 9,10,11,8, 13,14,15,12
 
);

  constant Perm2 : Int4Array := (
 
  2,3,0,1, 6,7,4,5, 10,11,8,9,  14,15,12,13
 
);



  constant Perm3 : Int4Array := (
 
  3,0,1,2, 7,4,5,6, 11,8,9,10,  15,12,13,14
 
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

        OpxD(3)(j) <= InxD(3)(Perm1(j)); 

        OpxD(2)(j) <= InxD(2)(Perm2(j)); 

        OpxD(1)(j) <= InxD(1)(Perm3(j)); 

 
   end generate loop4;

 

 

end architecture s3;

