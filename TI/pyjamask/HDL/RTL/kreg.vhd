library ieee;
use ieee.std_logic_1164.all;
 
use ieee.numeric_std.all;
use std.textio.all;
use work.all;

entity Kreg is 
port (
D0xDI : in std_logic_vector (127 downto 0);
D1xDI : in std_logic_vector (127 downto 0);
 
ClkxCI : in std_logic;
SelxSI : in std_logic;
 

StatexDP : out std_logic_vector (127 downto 0));
end entity Kreg;


architecture kr of Kreg is

begin


       

p_clk: process (SelxSI, ClkxCI)
         begin
 
if ClkxCI'event and ClkxCI ='1' then
             if SelxSI ='0'then
             StatexDP <= D0xDI;
           else
             StatexDP <= D1xDI;
           end if;
  
end if;
          
end process p_clk;

end architecture kr;
