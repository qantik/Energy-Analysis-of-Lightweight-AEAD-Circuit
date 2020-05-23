library ieee;
use ieee.std_logic_1164.all;
 
use ieee.numeric_std.all;
use std.textio.all;
use work.all;

entity DRreg is 
port (
RegxDN : in std_logic_vector (31 downto 0);

ClkxCI : in std_logic;
ResetxRBI : in std_logic;
 
RegxDP : out std_logic_vector (31 downto 0));
end entity DRreg;


architecture drr of DRreg is

begin

PROCESS(ClkxCI, ResetxRBI,RegxDN)
BEGIN
 IF ClkxCI'event and ClkxCI ='1' then
if ResetxRBI='0' then 
RegxDP <= (others=>'0') ;
else
RegxDP <=   RegxDN;
end if;
END IF;
END PROCESS ;
 

end architecture drr;
