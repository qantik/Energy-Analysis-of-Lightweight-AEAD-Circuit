library ieee;
use ieee.std_logic_1164.all;
 
use ieee.numeric_std.all;
use std.textio.all;
use work.all;

entity nBuf is 
port ( InpxDI : in std_logic;     
       OupxDO: out std_logic );
end entity nBuf;

architecture nbf of nBuf is



begin

OupxDO <= not InpxDI;


end architecture nbf;
