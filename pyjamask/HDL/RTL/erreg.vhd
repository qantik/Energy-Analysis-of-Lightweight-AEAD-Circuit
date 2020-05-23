library ieee;
use ieee.std_logic_1164.all;
 
use ieee.numeric_std.all;
use std.textio.all;
use work.all;

entity ERreg is 
port (
RegxDN : in std_logic_vector (127 downto 0);

ClkxCI : in std_logic;
ResetxRBI : in std_logic;
EnxSI: in std_logic;
RegxDP : out std_logic_vector (127 downto 0));
end entity ERreg;


architecture err of ERreg is

begin

PROCESS(ClkxCI,EnxSI,ResetxRBI)
BEGIN
IF EnxSI='0' THEN null;
ELSIF RISING_EDGE(ClkxCI) THEN
if ResetxRBI='0' then 
RegxDP <= (others=>'0') ;
else
RegxDP <=   RegxDN;
end if;
END IF;
END PROCESS ;
 

end architecture err;
