library ieee;
use ieee.std_logic_1164.all;
 
use ieee.numeric_std.all;
use std.textio.all;
use work.all;

entity Slayer is
port ( InpxDI : in  std_logic_vector(255 downto 0);
       OupxDO : out std_logic_vector(255 downto 0));
end entity Slayer;

architecture sl of Slayer is 
 
type Sigtype is array (0 to 63) of std_logic_vector(3 downto 0);
signal InxD,OpxD: Sigtype;

begin 


loop1: for i in 0 to 15 generate 

InxD(4*i)  <= InpxDI(255-i) & InpxDI(239-i) & InpxDI(223-i) & InpxDI(207-i);
InxD(4*i+1)<= InpxDI(191-i) & InpxDI(175-i) & InpxDI(159-i) & InpxDI(143-i);

InxD(4*i+2)<= InpxDI(127-i) & InpxDI(111-i) & InpxDI(95-i) & InpxDI(79-i);
InxD(4*i+3)<= InpxDI(63-i) & InpxDI(47-i) & InpxDI(31-i) & InpxDI(15-i);

i_0: entity s0 (com) port map (InxD(4*i), OpxD(4*i));

i_1: entity s1 (com) port map (InxD(4*i+1), OpxD(4*i+1));

i_2: entity s0 (com) port map (InxD(4*i+2), OpxD(4*i+2));

i_3: entity s1 (com) port map (InxD(4*i+3), OpxD(4*i+3));


OupxDO(255-i) <= OpxD (4*i)(3); 
OupxDO(239-i) <= OpxD (4*i)(2); 
OupxDO(223-i) <= OpxD (4*i)(1); 
OupxDO(207-i) <= OpxD (4*i)(0); 

OupxDO(191-i) <= OpxD (4*i+1)(3); 
OupxDO(175-i) <= OpxD (4*i+1)(2); 
OupxDO(159-i) <= OpxD (4*i+1)(1); 
OupxDO(143-i) <= OpxD (4*i+1)(0); 
 
OupxDO(127-i) <= OpxD (4*i+2)(3); 
OupxDO(111-i) <= OpxD (4*i+2)(2); 
OupxDO(95-i) <= OpxD (4*i+2)(1); 
OupxDO(79-i) <= OpxD (4*i+2)(0); 

OupxDO(63-i) <= OpxD (4*i+3)(3); 
OupxDO(47-i) <= OpxD (4*i+3)(2); 
OupxDO(31-i) <= OpxD (4*i+3)(1); 
OupxDO(15-i) <= OpxD (4*i+3)(0); 
  
end generate loop1;

end architecture sl;
