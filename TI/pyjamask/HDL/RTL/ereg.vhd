library ieee;
use ieee.std_logic_1164.all;
 
use ieee.numeric_std.all;
use std.textio.all;
use work.all;

entity Ereg is 
port (
RegxDN : in std_logic_vector (127 downto 0);

ClkxCI : in std_logic;

EnxSI: in std_logic;
RegxDP : out std_logic_vector (127 downto 0));
end entity Ereg;


architecture er of Ereg is

begin

PROCESS(ClkxCI,EnxSI)
BEGIN
IF EnxSI='0' THEN null;
ELSIF RISING_EDGE(ClkxCI) THEN
RegxDP <= RegxDN;
END IF;
END PROCESS ;


end architecture er;
