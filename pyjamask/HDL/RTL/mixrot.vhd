library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;               -- contains conversion functions
use work.all;

entity Mixrot is
  
  port (
    InpxDI : in  std_logic_vector(127 downto 0);
    OupxDO : out std_logic_vector(127 downto 0)
    );

end Mixrot;


architecture mt of Mixrot is

 
type Rowtype is array (0 to 31) of std_logic_vector(31 downto 0);
signal In0xD,In1xD,In2xD,In3xD: Rowtype;
  
signal OpxD: std_logic_vector(31 downto 0);

begin  -- lookuptable

In0xD(0)<= InpxDI(127 downto 96);
 

loop1: for i in 1 to 31 generate 
In0xD(i) <= InpxDI(127-i downto 96)  & InpxDI(127 downto 128-i);
end generate loop1;

loop2: for i in 0 to 31 generate 
e0: entity rmixk (rm) port map (In0xD(i),OpxD(31-i));
end generate loop2;

--OupxDO<= OpxD & InpxDI(87 downto 64) & InpxDI(95 downto 88) &  
--                InpxDI(48 downto 32) & InpxDI(63 downto 49) & 
--		  InpxDI(13 downto 0)  & InpxDI(31 downto 14) ;
--mistake in paper

OupxDO<= OpxD & InpxDI(71 downto 64) & InpxDI(95 downto 72) &  
                InpxDI(46 downto 32) & InpxDI(63 downto 47) & 
       	        InpxDI(17 downto 0)  & InpxDI(31 downto 18) ;


end architecture mt;
