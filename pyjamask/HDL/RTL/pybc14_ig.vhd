 

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

signal SoutxD,EoutxD:  Sigtype;

signal KoutxD,EKoutxD:  Sigtype;

signal CoutxD:  Sigtype;
 
signal CtxD:    Ctrtype;

signal  C,ENxS: std_logic_vector(14 downto 0);

 

 


signal LoadxS: std_logic;

begin

 
PTxD <= InxDI xor KeyxDI;

SoutxD(0) <= PTxD;
KoutxD(0) <= KeyxDI ;

---- round function 1------
rf0: entity roundf (rf) port map (SoutxD(0), KoutxD(1), SoutxD(1));
ks0: entity keysch (ks) port map (KoutxD(0), CoutxD(1) );
RCxD(1)  <= x"0000008" & x"0" & x"00006a00" & x"003f0000" & x"24000000";
KoutxD(1)<= CoutxD(1) xor RCxD(1);
---------------------------

---------------------------
loop1: for i in 2 to 14 generate  
---------------------------
rf1: entity roundf (rf) port map (EoutxD(i-1),  KoutxD(i), SoutxD(i));

ks1: entity keysch (ks) port map (EKoutxD(i-1), CoutxD(i) );

KoutxD(i)<= CoutxD(i) xor RCxD(i);

RCxD(i)  <= x"0000008" & CtxD(i) & x"00006a00" & x"003f0000" & x"24000000";

CtxD(i) <= std_logic_vector(to_unsigned(i-1, 4));   
---------------------------
end generate loop1;
---------------------------


---------------------------
loop2: for i in 2 to 14 generate  
---------------------------

    il: for j in 0 to 127 generate
       
            EoutxD(i-1)(j)  <= SoutxD(i-1)(j)  and ENxS(i);
            EKoutxD(i-1)(j) <= KoutxD(i-1)(j)  and ENxS(i);           

    end generate il;


 end generate loop2;

del1x: entity nBuf (nbf) port map (ClkxCI ,C(1));
-----------------------------------

loop3: for i in 2 to 14 generate  
---------------------------
del2x: entity Buf (bf) port map (C(i-1),C(i));
EnxS(i) <= (ClkxCI ) nand C(i-1);
end generate loop3;


 





OutxDO <= SoutxD(14);
 





---- igate----






end architecture behav;


