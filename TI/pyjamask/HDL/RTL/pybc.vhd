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
        In4xDI     : in  std_logic_vector(127 downto 0);
        KeyxDI    : in  std_logic_vector(127 downto 0);
        ClkxCI    : in  std_logic;
        ResxRBI   : in  std_logic; 
        Out1xDO    : out std_logic_vector(127 downto 0);
        Out2xDO    : out std_logic_vector(127 downto 0);
        Out3xDO    : out std_logic_vector(127 downto 0);
        Out4xDO    : out std_logic_vector(127 downto 
        KOutxDO    : out std_logic_vector(127 downto 0) 
      );

end pyjamaskbc;


architecture behav of pyjamaskbc is
 
 




signal ASBxD, AMRxD, AMCxD, AMTxD, RCxD: std_logic_vector(127 downto 0);


signal  StatexDP, SoutxD, PTxD, KeyxDP, KoutxD: std_logic_vector(127 downto 0);
 
  
signal CtxD : std_logic_vector(3 downto 0);

signal RoundxDP,RoundxDN ,CxD: integer range 0 to 15;

begin

 
--PTxD <= InxDI xor KeyxDI;

 
---- round function ------
 

sl1: entity Slayer1 (sl) port map (In2xDI, In3xDI, In4xDI, ASB1xD);
sl2: entity Slayer2 (sl) port map (In1xDI, In3xDI, In4xDI, ASB2xD);
sl3: entity Slayer3 (sl) port map (In1xDI, In2xDI, In4xDI, ASB3xD);
sl4: entity Slayer4 (sl) port map (In1xDI, In2xDI, In3xDI, ASB4xD);

 
mr1: entity Mixrow (mr) port map (ASB1xD, AMR1xD);
mr2: entity Mixrow (mr) port map (ASB2xD, AMR2xD);
mr3: entity Mixrow (mr) port map (ASB3xD, AMR3xD);
mr4: entity Mixrow (mr) port map (ASB4xD, AMR4xD);

Sout1xD <= AMR1xD xor KoutxD;
Sout2xD <= AMR2xD  ;
Sout3xD <= AMR3xD  ;
Sout4xD <= AMR4xD  ;
---------------------------

---- Keyschedule function ------

mc0 : entity Mixcol (mc) port map (KeyxDI, AMCxD);
 
mar0: entity Mixrot (mt) port map (AMCxD,  AMTxD);

KoutxD <= AMTxD xor RCxD;


RCxD <= x"0000008" & CtxD & x"00006a00" & x"003f0000" & x"24000000";
CtxD <= std_logic_vector(to_unsigned(CxD, 4));    
-----------------------------------

Out1xDO <= Sout1xD;
Out2xDO <= Sout2xD;
Out3xDO <= Sout3xD;
Out4xDO <= Sout4xD;

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

 
               when 14 =>  RoundxDN <= 0;CxD<= RoundxDP-1; 

               when others => RoundxDN <= RoundxDP + 1;CxD<= RoundxDP-1; 
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


