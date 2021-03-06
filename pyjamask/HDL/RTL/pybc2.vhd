
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.all;
 

entity pyjamaskbc is
  port(
        InxDI     : in  std_logic_vector(127 downto 0);
        KeyxDI    : in  std_logic_vector(127 downto 0);
        ClkxCI    : in  std_logic;
        ResxRBI   : in  std_logic; 
        OutxDO    : out std_logic_vector(127 downto 0);
        KOutxDO    : out std_logic_vector(127 downto 0) 
      );

end pyjamaskbc;


architecture behav of pyjamaskbc is
 
 




signal RC1xD,RC2xD: std_logic_vector(127 downto 0);

signal StatexDP, PTxD, KeyxDP: std_logic_vector(127 downto 0);

signal Sout1xD,Sout2xD,   Kout1xD, Kout2xD,   Cout1xD, Cout2xD : std_logic_vector(127 downto 0);

   
signal Ct1xD,Ct2xD : std_logic_vector(3 downto 0);

signal RoundxDP,RoundxDN ,C1xD,C2xD: integer range 0 to 15;

signal LoadxS: std_logic;

begin

 
--PTxD <= InxDI xor KeyxDI;

 
---- round function ------


rf1: entity roundf (rf) port map (InxDI, Kout1xD, Sout1xD);
rf2: entity roundf (rf) port map (Sout1xD,  Kout2xD, Sout2xD);

 
---------------------------

---- Keyschedule function ------

ks1: entity keysch (ks) port map (KeyxDI,   Cout1xD);
ks2: entity keysch (ks) port map (Kout1xD,  Cout2xD);


Kout1xD<= Cout1xD xor RC1xD;
Kout2xD<= Cout2xD xor RC2xD;

---------------------------------
RC1xD <= x"0000008" & Ct1xD & x"00006a00" & x"003f0000" & x"24000000";
RC2xD <= x"0000008" & Ct2xD & x"00006a00" & x"003f0000" & x"24000000";

Ct1xD <= std_logic_vector(to_unsigned(C1xD, 4));   
Ct2xD <= std_logic_vector(to_unsigned(C2xD, 4));   
-----------------------------------

OutxDO <= Sout2xD;
KOutxDO <= Kout2xD;
-----------------------------------
--reg1: entity Sreg (sr) port map (Sout2xD, PTxD  ,  LoadxS, ClkxCI, StatexDP);

--reg2: entity Sreg (sr) port map (Kout2xD, KeyxDI,  LoadxS, ClkxCI, KeyxDP);
----------------------------------------------

  p_main : process (RoundxDP)
           begin

             RoundxDN <= RoundxDP;
             C2xD <= RoundxDP;
             case RoundxDP is
               when 0 =>   RoundxDN <= 1; C1xD<= 0; 

 
               when 13 =>  RoundxDN <= 0; C1xD<= RoundxDP-1; 

               when others => RoundxDN <= RoundxDP + 2; C1xD<= RoundxDP-1; 
             end case;    
             
           end process p_main;

----------------------------------------------
--LoadxS<= '1' when RoundxDP=0 else '0';
 
-- p_clk: process (ResxRBI, ClkxCI)
---         begin
 --          if ResxRBI='0' then
 --            RoundxDP  <= 0;
--             
--           elsif ClkxCI'event and ClkxCI ='1' then
--             RoundxDP  <= RoundxDN;

--           end if;
--         end process p_clk;

  p_clk: process (ResxRBI, ClkxCI)
         begin
           --if ResetxRBI='0' then
             --LxDP  <=  (others=>'0');
 
           if ClkxCI'event and ClkxCI ='1' then
           --  LxDP  <= LxDN;
 
           --end if;


          if ResxRBI ='0'then
              RoundxDP  <= 1;
           else
              RoundxDP  <= RoundxDN;
           end if;

         end if;
         end process p_clk;

end architecture behav;


