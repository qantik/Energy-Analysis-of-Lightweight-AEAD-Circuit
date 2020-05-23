library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;               -- contains conversion functions
use work.all;

entity Mixrow is
  
  port (
    InpxDI : in  std_logic_vector(127 downto 0);
    OupxDO : out std_logic_vector(127 downto 0)
    );

end Mixrow;


architecture mr of Mixrow is

 
type Rowtype is array (0 to 31) of std_logic_vector(31 downto 0);
signal In0xD,In1xD,In2xD,In3xD: Rowtype;
  
signal OpxD: std_logic_vector(127 downto 0);

begin  -- lookuptable

In0xD(0)<= InpxDI(127 downto 96);
In1xD(0)<= InpxDI(95  downto 64);

In2xD(0)<= InpxDI(63  downto 32);
In3xD(0)<= InpxDI(31  downto 0);

loop1: for i in 1 to 31 generate 
In0xD(i) <= InpxDI(127-i downto 96)  & InpxDI(127 downto 128-i);
In1xD(i) <= InpxDI(95-i  downto 64)  & InpxDI(95  downto 96-i);
In2xD(i) <= InpxDI(63-i  downto 32)  & InpxDI(63  downto 64-i);
In3xD(i) <= InpxDI(31-i  downto 0)   & InpxDI(31  downto 32-i);
end generate loop1;

loop2: for i in 0 to 31 generate 

e0: entity rmix0 (rm) port map (In0xD(i),OpxD(127-i));
e1: entity rmix1 (rm) port map (In1xD(i),OpxD(95-i));
e2: entity rmix2 (rm) port map (In2xD(i),OpxD(63-i));
e3: entity rmix3 (rm) port map (In3xD(i),OpxD(31-i));
end generate loop2;

OupxDO<= OpxD;

end architecture mr;

