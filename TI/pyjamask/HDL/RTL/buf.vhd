library ieee;
use ieee.std_logic_1164.all;
 
use ieee.numeric_std.all;
use std.textio.all;
use work.all;

entity Buf is 
port ( InpxDI : in std_logic;     
       OupxDO: out std_logic );
end entity Buf;

architecture bf of Buf is



begin

OupxDO <= InpxDI;


end architecture bf;
