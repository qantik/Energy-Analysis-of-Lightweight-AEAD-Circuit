-------------------------------------------------------------------------------
-- Title      : QARMA
-- Project    : 
-------------------------------------------------------------------------------
-- File       : pyjamaskbc.vhd
-- Author     : Subhadeep Banik  <subhadeep.banik@epfl.ch>
-- Company    : LASEC, EPF Lausanne
-- Created    : 2006-04-06
-- Last update: 2006-04-10
-- Platform   : ModelSim (simulation), Synopsys (synthesis)
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: Main PYJAMASK block
-------------------------------------------------------------------------------
-- Copyright (c) 2018 LASEC, EPF Lausanne
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2006-04-06  1.0      kgf	Created
-------------------------------------------------------------------------------

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
        COutxDO   : out std_logic_vector(127 downto 0);
        KOutxDO   : out std_logic_vector(127 downto 0) 
      );

end pyjamaskbc;


architecture behav of pyjamaskbc is
 
 




signal RC1xD,RC2xD,RC3xD ,RC4xD ,RC5xD: std_logic_vector(127 downto 0);

signal StatexDP, PTxD, KeyxDP: std_logic_vector(127 downto 0);

signal Sout1xD, Sout2xD, Sout3xD , Sout4xD , Sout5xD: std_logic_vector(127 downto 0);

signal Kout1xD, Kout2xD, Kout3xD , Kout4xD , Kout5xD: std_logic_vector(127 downto 0);

signal Cout1xD, Cout2xD, Cout3xD , Cout4xD , Cout5xD: std_logic_vector(127 downto 0);
 
signal Ct1xD,Ct2xD,Ct3xD ,Ct4xD ,Ct5xD: std_logic_vector(3 downto 0);

signal RoundxDP,RoundxDN ,C1xD,C2xD,C3xD ,C4xD ,C5xD: integer range 0 to 15;

signal LoadxS: std_logic;

begin

 
--PTxD <= InxDI xor KeyxDI;

 
---- round function ------


rf1: entity roundf (rf) port map (InxDI, Kout1xD, Sout1xD);
rf2: entity roundf (rf) port map (Sout1xD,  Kout2xD, Sout2xD);
rf3: entity roundf (rf) port map (Sout2xD,  Kout3xD, Sout3xD);
rf4: entity roundf (rf) port map (Sout3xD,  Kout4xD, Sout4xD);
rf5: entity roundf (rf) port map (Sout4xD,  Kout5xD, Sout5xD);
---------------------------

---- Keyschedule function ------

ks1: entity keysch (ks) port map (KeyxDI,   Cout1xD);
ks2: entity keysch (ks) port map (Kout1xD,  Cout2xD);
ks3: entity keysch (ks) port map (Kout2xD,  Cout3xD);
ks4: entity keysch (ks) port map (Kout3xD,  Cout4xD);
ks5: entity keysch (ks) port map (Kout4xD,  Cout5xD);

Kout1xD<= Cout1xD xor RC1xD;
Kout2xD<= Cout2xD xor RC2xD;
Kout3xD<= Cout3xD xor RC3xD;
Kout4xD<= Cout4xD xor RC4xD;
Kout5xD<= Cout5xD xor RC5xD;

---------------------------------
RC1xD <= x"0000008" & Ct1xD & x"00006a00" & x"003f0000" & x"24000000";
RC2xD <= x"0000008" & Ct2xD & x"00006a00" & x"003f0000" & x"24000000";
RC3xD <= x"0000008" & Ct3xD & x"00006a00" & x"003f0000" & x"24000000";
RC4xD <= x"0000008" & Ct4xD & x"00006a00" & x"003f0000" & x"24000000";
RC5xD <= x"0000008" & Ct5xD & x"00006a00" & x"003f0000" & x"24000000";

Ct1xD <= std_logic_vector(to_unsigned(C1xD, 4));   
Ct2xD <= std_logic_vector(to_unsigned(C2xD, 4));  
Ct3xD <= std_logic_vector(to_unsigned(C3xD, 4));  
Ct4xD <= std_logic_vector(to_unsigned(C4xD, 4)); 
Ct5xD <= std_logic_vector(to_unsigned(C5xD, 4)); 
-----------------------------------

COutxDO <= Sout4xD;
OutxDO <= Sout5xD;
KOutxDO <= Kout5xD;

-----------------------------------
--reg1: entity Sreg (sr) port map (Sout5xD, PTxD  ,  LoadxS, ClkxCI, StatexDP);

--reg2: entity Sreg (sr) port map (Kout5xD, KeyxDI,  LoadxS, ClkxCI, KeyxDP);
----------------------------------------------

  p_main : process (RoundxDP)
           begin

             RoundxDN <= RoundxDP;
             C2xD <= RoundxDP;
             C3xD <= RoundxDP+1;
             C4xD <= RoundxDP+2;
             C5xD <= RoundxDP+3;
             case RoundxDP is
               when 0 =>   RoundxDN <= 1; C1xD<= 0; 

 
               when 11 =>  RoundxDN <= 0; C1xD<= RoundxDP-1; 

               when others => RoundxDN <= RoundxDP + 5; C1xD<= RoundxDP-1; 
             end case;    
             
           end process p_main;

----------------------------------------------
--LoadxS<= '1' when RoundxDP=0 else '0';
 p_clk: process (ResxRBI, ClkxCI)
         begin
          
 
           if ClkxCI'event and ClkxCI ='1' then
     


          if ResxRBI ='0'then
              RoundxDP  <= 1;
           else
              RoundxDP  <= RoundxDN;
           end if;

         end if;
         end process p_clk;



end architecture behav;


