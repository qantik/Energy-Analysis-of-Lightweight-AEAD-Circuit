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
        In1xDI     : in  std_logic_vector(127 downto 0);
        In2xDI     : in  std_logic_vector(127 downto 0);
        In3xDI     : in  std_logic_vector(127 downto 0);
 
        KeyxDI    : in  std_logic_vector(127 downto 0);
        ClkxCI    : in  std_logic;
        ResxRBI   : in  std_logic; 
        Out1xDO    : out std_logic_vector(127 downto 0);
        Out2xDO    : out std_logic_vector(127 downto 0);
        Out3xDO    : out std_logic_vector(127 downto 0);
 
        KOutxDO    : out std_logic_vector(127 downto 0) 
      );

end pyjamaskbc;


architecture behav of pyjamaskbc is
 
 



signal ASB1xD, AMR1xD, AMCxD, AMTxD, RCxD: std_logic_vector(127 downto 0);
signal ASB2xD, AMR2xD : std_logic_vector(127 downto 0);
signal ASB3xD, AMR3xD : std_logic_vector(127 downto 0);
 

signal Sout1xD, Sout2xD, Sout3xD : std_logic_vector(127 downto 0);

signal  StatexDP,  PTxD, KeyxDP, KoutxD: std_logic_vector(127 downto 0);
 
signal G1xD,G2xD,G3xD,G1xDP,G2xDP,G3xDP : std_logic_vector(127 downto 0);
signal CtxD : std_logic_vector(4 downto 0);

signal RoundxDP,RoundxDN ,CxD: integer range 0 to  31;

begin

 
--PTxD <= InxDI xor KeyxDI;

 
---- round function ------
 
 

gl1: entity Glayer1 (gl) port map (In2xDI, In3xDI , G1xD);
gl2: entity Glayer2 (gl) port map (In1xDI, In3xDI , G2xD);
gl3: entity Glayer3 (gl) port map (In1xDI, In2xDI , G3xD);


mr01 : entity Smreg (sr) port map (G1xD,ClkxCI, G1xDP);
mr02 : entity Smreg (sr) port map (G2xD,ClkxCI, G2xDP);
mr03 : entity Smreg (sr) port map (G3xD,ClkxCI, G3xDP);


fl1: entity Flayer1 (fl) port map (G2xDP, G3xDP , ASB1xD);
fl2: entity Flayer2 (fl) port map (G1xDP, G3xDP , ASB2xD);
fl3: entity Flayer3 (fl) port map (G1xDP, G2xDP , ASB3xD);
 
mr1: entity Mixrow (mr) port map (ASB1xD, AMR1xD);
mr2: entity Mixrow (mr) port map (ASB2xD, AMR2xD);
mr3: entity Mixrow (mr) port map (ASB3xD, AMR3xD);
 

Sout1xD <= AMR1xD xor KoutxD;
Sout2xD <= AMR2xD  ;
Sout3xD <= AMR3xD  ;
 
---------------------------

---- Keyschedule function ------

mc0 : entity Mixcol (mc) port map (KeyxDI, AMCxD);
 
mar0: entity Mixrot (mt) port map (AMCxD,  AMTxD);

KoutxD <= AMTxD xor RCxD;


RCxD <= x"0000008" & CtxD(4 downto 1) & x"00006a00" & x"003f0000" & x"24000000";
CtxD <= std_logic_vector(to_unsigned(CxD, 5));    
-----------------------------------

Out1xDO <= Sout1xD;
Out2xDO <= Sout2xD;
Out3xDO <= Sout3xD;
 

KOutxDO <= KoutxD;
-----------------------------------
--reg1: entity Sreg (sr) port map (SoutxD, PTxD  ,  LoadxS, ClkxCI, StatexDP);

--reg2: entity Sreg (sr) port map (KoutxD, KeyxDI,  LoadxS, ClkxCI, KeyxDP);
----------------------------------------------

  p_main : process (RoundxDP)
           begin

             RoundxDN <= RoundxDP;
  
             case RoundxDP is
               when 0 =>   RoundxDN <= 1;CxD<= 0; 
               when 1 =>   RoundxDN <= 2;CxD<= 0; 
 
               when 28 =>  RoundxDN <= 0; CxD<= RoundxDP-2; 

               when others => RoundxDN <= RoundxDP + 1;CxD<= RoundxDP-2; 
             end case;    
             
           end process p_main;

----------------------------------------------
 --p_clk: process (ResetxRBI, ClkxCI)
  --       begin
  --         if ResetxRBI='0' then
  --           RoundxDP  <= 0;
             
  --         elsif ClkxCI'event and ClkxCI ='1' then
  --           RoundxDP  <= RoundxDN;

  --         end if;
  --       end process p_clk;

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


