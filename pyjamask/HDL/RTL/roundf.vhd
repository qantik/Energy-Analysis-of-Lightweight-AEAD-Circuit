
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.all;


entity roundf is
  port(
        InxDI     : in  std_logic_vector(127 downto 0);
        KeyxDI    : in  std_logic_vector(127 downto 0);
        OutxDO    : out std_logic_vector(127 downto 0) 
      );

end roundf;


architecture rf of roundf is

signal ASBxD,AMRxD: std_logic_vector(127 downto 0) ;

begin

sl0: entity Slayer (sl) port map (InxDI, ASBxD);
 
mr0: entity Mixrow (mr) port map (ASBxD, AMRxD);

OutxDO <= AMRxD xor KeyxDI; 


end architecture rf;
