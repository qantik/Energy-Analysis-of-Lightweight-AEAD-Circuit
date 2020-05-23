library ieee;
use ieee.std_logic_1164.all;
 
use ieee.numeric_std.all;
use std.textio.all;
use work.all;

entity Dreg is 
port (
RegxDN : in std_logic_vector (127 downto 0);

ClkxCI : in std_logic;

 
RegxDP : out std_logic_vector (127 downto 0));
end entity Dreg;


architecture dr of Dreg is

begin

PROCESS(ClkxCI )
BEGIN
 IF RISING_EDGE(ClkxCI) THEN
RegxDP <= RegxDN;
END IF;
END PROCESS ;


end architecture dr;
