library ieee;
use ieee.std_logic_1164.all;
 
use ieee.numeric_std.all;
use std.textio.all;
use work.all;

entity Sreg is 
port (
Reg0xDN : in std_logic_vector (255 downto 0);
Reg1xDN : in std_logic_vector (255 downto 0);
SelxSI  : in std_logic;
ClkxCI  : in std_logic;
RegxDP : out std_logic_vector (255 downto 0));
end entity Sreg;


architecture sr of Sreg is

begin


p_clk: process (SelxSI, ClkxCI)
         begin
           
           
	 if ClkxCI'event and ClkxCI ='1' then
             if SelxSI ='0'then
             RegxDP <= Reg0xDN;
           else
             RegxDP <= Reg1xDN;
           end if;
          end if; 
           
         end process p_clk;

end architecture sr;