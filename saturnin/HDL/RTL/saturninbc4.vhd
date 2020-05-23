library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;               -- contains conversion functions
use work.all;


entity saturninbc is
  port(
        InxDI     : in  std_logic_vector(255 downto 0);
        KeyxDI    : in  std_logic_vector(255 downto 0);
        R0        : in  std_logic_vector(31  downto 0);
        ClkxCI    : in  std_logic;
        ResxRBI   : in  std_logic; 
        OutxDO    : out std_logic_vector(255 downto 0);
        RCoutxDO  : out std_logic_vector(31  downto 0) 
      );
end saturninbc;

architecture behav of saturninbc is



signal PTxD, StatexDP, ASBxD, ASB1xD, ASB2xD, ASB3xD,  AMCxD,AMC1xD,AMC2xD,AMC3xD, SoutxD,Sout1xD ,RotxD: std_logic_vector(255 downto 0);

signal S1xD, S3xD, T1xD, T3xD, RKxD, AC1xD,AC2xD : std_logic_vector(255 downto 0);

signal RC0xDP, RC0xDN, U0xD, RC1xDP, RC1xDN, U1xD,  V0xD,V1xD: std_logic_vector(15 downto 0);

signal RoundxDP, RoundxDN: integer range 0 to 20;

signal RxD : integer range 0 to 3;
 
  
signal LoadxS: std_logic;
 

begin

 

s0: entity slayer (sl) port map (InxDI, ASBxD);

mc0: entity mds (m) port map (ASBxD, AMCxD);

s1: entity slayer (sl) port map (AMCxD, ASB1xD);

sh14:  entity sr1m4 (s1) port map (ASB1xD, S1xD);

mc1: entity mds (m) port map (S1xD, AMC1xD);

shi14:  entity sr1m4i (s1) port map (AMC1xD, T1xD);

SoutxD<= T1xD xor RotxD xor AC1xD;


 
s2: entity slayer (sl) port map (SoutxD, ASB2xD);

mc2: entity mds (m) port map (ASB2xD, AMC2xD);

s3: entity slayer (sl) port map (AMC2xD, ASB3xD);

sh34:  entity sr3m4 (s3) port map (ASB3xD, S3xD);

mc3: entity mds (m) port map (S3xD, AMC3xD);

shi34:  entity sr3m4i (s3) port map (AMC3xD, T3xD);

Sout1xD<= T3xD xor KeyxDI xor AC2xD;

 

 
OutxDO<=Sout1xD;


rcon0: entity rcup0 (rc) port map (RC0xDP, U0xD);
rcon1: entity rcup1 (rc) port map (RC1xDP, U1xD);


 
rcon2: entity rcup0 (rc) port map (U0xD, V0xD);
rcon3: entity rcup1 (rc) port map (U1xD, V1xD);



RC0xDN <= V0xD;
RC1xDN <= V1xD; 


l1: for i in 0 to 15 generate

RotxD(255-16*i downto 240-16*i) <= KeyxDI(244-16*i  downto 240-16*i ) & KeyxDI(255-16*i  downto 245-16*i );
end generate l1;
 
AC1xD<= U0xD(7 downto 0) & U0xD(15 downto 8) & x"0000000000000000000000000000" &  U1xD(7 downto 0) & U1xD(15 downto 8) & x"0000000000000000000000000000" ;
AC2xD<= V0xD(7 downto 0) & V0xD(15 downto 8) & x"0000000000000000000000000000" &  V1xD(7 downto 0) & V1xD(15 downto 8) & x"0000000000000000000000000000" ;
----------------------------------------------
 
RC0xDP<= R0(31 downto 16);
RC1xDP<= R0(15 downto 0);
RCoutxDO <= RC0xDN & RC1xDN;

----------------------------------------------

  p_main : process (RoundxDP)
           begin

             RoundxDN <= RoundxDP;
  
             case RoundxDP is
               when 0 =>   RoundxDN <= 1;  

 
               when 17 =>  RoundxDN <= 0;  

               when others => RoundxDN <= RoundxDP + 4; 
             end case;    
             
           end process p_main;

----------------------------------------------

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

