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



signal PTxD, StatexDP, ASBxD, ASHxD,  AMCxD, AISHxD, SoutxD ,RotxD: std_logic_vector(255 downto 0);

signal S1xD, S3xD, T1xD, T3xD, RKxD, ACxD : std_logic_vector(255 downto 0);

signal RC0xDP, RC0xDN, U0xD, RC1xDP, RC1xDN, U1xD  : std_logic_vector(15 downto 0);

signal RoundxDP, RoundxDN: integer range 0 to 20;

signal RxD : integer range 0 to 3;
 
  
signal LoadxS: std_logic;
 

begin

 

s0: entity slayer (sl) port map (InxDI, ASBxD);

RxD<= RoundxDP mod 4;

sh14:  entity sr1m4 (s1) port map (ASBxD, S1xD);
sh34:  entity sr3m4 (s3) port map (ASBxD, S3xD);



shuffle: process(RxD,ASBxD,S1xD,S3xD,KeyxDI,T1xD,T3xD,ACxD,AMCxD)
begin
if RxD=2 then
   ASHxD<= S1xD;
   RKxD <= RotxD xor ACxD;
   AISHxD <= T1xD; 
elsif RxD=0 then 
   ASHxD<= S3xD;
   RKxD <= KeyxDI xor ACxD;
   AISHxD <= T3xD; 
else
   ASHxD<= ASBxD;
   RKxD <= (others=>'0');
   AISHxD <= AMCxD; 
end if;

end process shuffle;

mc: entity mds (m) port map (ASHxD, AMCxD);

shi14:  entity sr1m4i (s1) port map (AMCxD, T1xD);
shi34:  entity sr3m4i (s3) port map (AMCxD, T3xD);

SoutxD<= AISHxD xor RKxD;

OutxDO<=SoutxD;



rcon0: entity rcup0 (rc) port map (RC0xDP, U0xD);
rcon1: entity rcup1 (rc) port map (RC1xDP, U1xD);


 


RC0xDN <= U0xD when ( RxD=1 or RxD =3 ) else RC0xDP;
RC1xDN <= U1xD when ( RxD=1 or RxD =3 ) else RC1xDP; 


l1: for i in 0 to 15 generate

RotxD(255-16*i downto 240-16*i) <= KeyxDI(244-16*i  downto 240-16*i ) & KeyxDI(255-16*i  downto 245-16*i );
end generate l1;

 
ACxD<= RC0xDP(7 downto 0) & RC0xDP(15 downto 8) & x"0000000000000000000000000000" &  RC1xDP(7 downto 0) & RC1xDP(15 downto 8) & x"0000000000000000000000000000" ;
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

 
               when 20 =>  RoundxDN <= 0;  

               when others => RoundxDN <= RoundxDP + 1; 
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

