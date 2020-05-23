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
 
 




signal ASBxD, AMRxD, AMCxD, AMTxD, RCxD: std_logic_vector(127 downto 0);


signal  StatexDP, SoutxD, PTxD, KeyxDP, KoutxD: std_logic_vector(127 downto 0);
 
  
signal CtxD : std_logic_vector(3 downto 0);

signal RoundxDP,RoundxDN ,CxD: integer range 0 to 15;

begin

 
--PTxD <= InxDI xor KeyxDI;

 
---- round function ------
sl0: entity Slayer (sl) port map (InxDI, ASBxD);
 
mr0: entity Mixrow (mr) port map (ASBxD, AMRxD);

SoutxD <= AMRxD xor KoutxD; 
---------------------------

---- Keyschedule function ------

mc0 : entity Mixcol (mc) port map (KeyxDI, AMCxD);
 
mar0: entity Mixrot (mt) port map (AMCxD,  AMTxD);

KoutxD <= AMTxD xor RCxD;


RCxD <= x"0000008" & CtxD & x"00006a00" & x"003f0000" & x"24000000";
CtxD <= std_logic_vector(to_unsigned(CxD, 4));    
-----------------------------------

OutxDO <= SoutxD;
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


