 

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.all;
 

entity pyjamaskbc is
  port(
        InxDI     : in  std_logic_vector(127 downto 0);
        KeyxDI    : in  std_logic_vector(127 downto 0);
        ClkxCI    : in  std_logic;
        OutxDO    : out std_logic_vector(127 downto 0) 
      );

end pyjamaskbc;


architecture behav of pyjamaskbc is
 
 

type Sigtype is array (0 to 14) of std_logic_vector(127 downto 0);
type Ctrtype is array (0 to 14) of std_logic_vector(3 downto 0);
 


signal RCxD  : Sigtype;

signal StatexDP, PTxD, KeyxDP: std_logic_vector(127 downto 0);

signal SoutxD:  Sigtype;

signal KoutxD:  Sigtype;

signal CoutxD:  Sigtype;
 
signal CtxD:    Ctrtype;



 

 


signal LoadxS: std_logic;

begin

 
PTxD <= InxDI xor KeyxDI;

SoutxD(0) <= PTxD;
KoutxD(0) <= KeyxDI ;

---- round function ------

loop1: for i in 1 to 14 generate  
rf1: entity roundf (rf) port map (SoutxD(i-1), KoutxD(i), SoutxD(i));
 

ks1: entity keysch (ks) port map (KoutxD(i-1), CoutxD(i) );

KoutxD(i)<= CoutxD(i) xor RCxD(i);

RCxD(i)  <= x"0000008" & CtxD(i) & x"00006a00" & x"003f0000" & x"24000000";

CtxD(i) <= std_logic_vector(to_unsigned(i-1, 4));   
---------------------------

end generate loop1;

 
-----------------------------------

OutxDO <= SoutxD(14);
 


end architecture behav;


