library ieee;
use ieee.std_logic_1164.all;
 
use ieee.numeric_std.all;
use std.textio.all;
use work.all;

entity Smreg is 
port (
RegxDN : in std_logic_vector (127 downto 0);
 
ClkxCI : in std_logic;
RegxDP : out std_logic_vector (127 downto 0));
end entity Smreg;


architecture sr of Smreg is

begin


p_clk: process (  ClkxCI)
         begin
          if ClkxCI'event and ClkxCI ='1' then

			
                         RegxDP <= RegxDN;
                        
           end if;
         end process p_clk;

end architecture sr;
