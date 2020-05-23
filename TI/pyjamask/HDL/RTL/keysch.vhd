library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.all;


entity keysch is
  port(
        InxDI     : in  std_logic_vector(127 downto 0);
        OutxDO    : out std_logic_vector(127 downto 0) 
      );

end keysch;


architecture ks of keysch is

signal AMCxD,AMTxD: std_logic_vector(127 downto 0) ;

begin
 

mc0 : entity Mixcol (mc) port map (InxDI, AMCxD);
 
mar0: entity Mixrot (mt) port map (AMCxD,  AMTxD);

OutxDO<= AMTxD;

end architecture ks;
