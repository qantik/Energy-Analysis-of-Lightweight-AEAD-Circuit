library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;  
use work.all;


entity pyjamask_aead is
 
        
    port (clk   : in std_logic;
          reset : in std_logic; -- active low

          key   : in std_logic_vector(127 downto 0);
          nonce : in std_logic_vector(95 downto 0);

          -- A data block is either associated data or plaintext.
          -- last_block indicates whether the current ad or plaintext
          -- block is the last one with last_partial indicating whether
          -- said block is only partially filled.
          data         : in std_logic_vector(127 downto 0);
          last_block   : in std_logic;
          last_partial : in std_logic;

          empty_ad     : in std_logic; -- Constant, set at the beginning.
          empty_msg    : in std_logic; -- Constant, set at the beginning.

          ready_block  : out std_logic; -- Expecting new block at next rising edge.
          ready_full   : out std_logic; -- AEAD finished.

          -- Indication signals that tell whether current value on either
          -- the ciphertext or tag output pins is valid.
          cipher_ready : out std_logic;
          tag_ready    : out std_logic;

          ciphertext   : out std_logic_vector(127 downto 0);
          tag          : out std_logic_vector(127 downto 0));

end pyjamask_aead;

architecture py of pyjamask_aead is 


signal prepare_lstar, process_ad, nonce_enc,process_pt,final_tag : std_logic;

signal reset_bc,reset_s,reset_a, LoadxS, Load_LxS, Load_OxS,Load_AxS,Load_SxS  : std_logic;

signal FcntxDP, FcntxDN: integer range 0 to 15;

signal CountxDP, CountxDN: integer range 0 to 255;

signal StatusxDP, StatusxDN : std_logic_vector(2 downto 0);

signal InxD,InpKxD, EINxD, KINxD, EOUTxD, KOUTxD :  std_logic_vector(127 downto 0);

signal RegxDP, KeyxDP, LRegxDP, LRegxDN, ARegxDP, ARegxDN, SumxDP, SumxDN, ORegxDP, ORegxDN:  std_logic_vector(127 downto 0);

signal Ldollar, Lntz:  std_logic_vector(127 downto 0);

type Sigtype is array (0 to 10) of std_logic_vector(127 downto 0);
signal L: Sigtype;

signal N : integer range 0 to 7;

signal NoutxD:  std_logic_vector(2 downto 0);

signal bottom : integer range 0 to 63;

signal StpartxD :  std_logic_vector(63 downto 0);

signal stretch:  std_logic_vector(191 downto 0);

signal Ozero,Opad:  std_logic_vector(127 downto 0);

signal Count:  std_logic_vector(7 downto 0);

begin

p_clk: process (reset, clk)
         begin
           if reset='0' then
             StatusxDP  <= "000";
             CountxDP<=0;
             FcntxDP <= 0;
         
 
           elsif clk'event and clk ='1' then
             
                  StatusxDP  <= StatusxDN;
                  FcntxDP <= FcntxDN;
                  CountxDP<= CountxDN;
                 

                  
           end if;
end process p_clk;



p_main: process (StatusxDP, FcntxDP, empty_ad, empty_msg, last_block, last_partial)
  
   begin
   
 
   reset_bc <= '1';

   prepare_lstar  <='0';
   
   process_pt <='0';
   process_ad <='0'; 

   nonce_enc<='0';
   final_tag<='0';

   CountxDN<=CountxDP;
   
   case StatusxDP is 
   when "000" => prepare_lstar <= '1';
   
   

    if FcntxDP < 14 then
                                if FcntxDP = 0 then
      					reset_bc <= '0';
                                        CountxDN<=0;
                                end if;

                                FcntxDN  <= FcntxDP+1;
                                StatusxDN <= StatusxDP;
                                
                    
                                
                             else
                                FcntxDN  <= 0;

                                if empty_ad ='1' then 
                                	StatusxDN <= "010";
                                else
                                        StatusxDN <= "001";
                                        CountxDN<=CountxDP+1;
                                end if;
                                                            
                             end if;  



   when "001" =>  process_ad <='1';

   if FcntxDP <14 then
 		  if FcntxDP = 0 then
      			   reset_bc <= '0';
                  end if;
                  
                  FcntxDN <= FcntxDP+1;
                  StatusxDN <= StatusxDP;
   else
                 if last_block = '1' then
                       StatusxDN <= "010";
                       CountxDN<=0;
                 else
                       StatusxDN <= StatusxDP; 
                       CountxDN<=CountxDP+1;
                 end if;
 

 
                 FcntxDN  <= 0;
   end if;  
                   
            
   when "010" => nonce_enc <= '1';

        if FcntxDP <14 then
 		  if FcntxDP = 0 then
      			   reset_bc <= '0';
                           CountxDN<=0;
                  end if;
                  
                  FcntxDN <= FcntxDP+1;
                  StatusxDN <= StatusxDP;
       else
                 if empty_msg = '1' then
                   
                       StatusxDN <= "100";
                 else
                       StatusxDN <= "011";
                       CountxDN<=CountxDP+1;
               
                 end if;

 
                 FcntxDN  <= 0;
   end if;  
   
   when "011" => process_pt <= '1';

    if FcntxDP <14 then
		  if FcntxDP = 0 then
      			   reset_bc <= '0';                                        

                  end if;
                  FcntxDN <= FcntxDP+1;
                  StatusxDN <= StatusxDP;
   else
                 if last_block = '1' then
                    StatusxDN <= "100";
                    CountxDN<=0;
                 else
                    StatusxDN <= StatusxDP; 
                    CountxDN<=CountxDP+1;
                 end if;

 
                 FcntxDN  <= 0;
   end if;  


   when "100" => final_tag <= '1';

    if FcntxDP <14 then
		  if FcntxDP = 0 then
      			   reset_bc <= '0';
                  end if;

                  FcntxDN <= FcntxDP+1;
                  StatusxDN <= StatusxDP;
   else
 
                 reset_bc <= '0';   
                 FcntxDN  <= 0;
   end if;  



  when others => FcntxDN  <= 0;
                 StatusxDN <= StatusxDP;
                  CountxDN<=CountxDP;
end case;
end process p_main;
 

-----------------------------------------------------------------------------------------------

BC_01: entity pyjamaskbc (behav) port map (EINxD,KINxD,clk,reset_bc,EOUTxD,KOUTxD );

sr01 : entity Kreg (kr) port map (EOUTxD , InpKxD  ,clk,LoadxS,  RegxDP);

kr01 : entity Kreg (kr) port map (KOUTxD , key ,clk,LoadxS, KeyxDP);

lr01 : entity Ereg (er) port map (LRegxDN , clk, Load_LxS, LRegxDP);

or01 : entity Ereg (er) port map (ORegxDN , clk, Load_OxS, ORegxDP);

au01 : entity ERreg (err) port map (ARegxDN , clk, reset_a,Load_AxS, ARegxDP);

sr02:  entity ERreg (err) port map (SumxDN  , clk, reset_s, Load_SxS, SumxDP);
-----------------------------------------------------------------------------------------------
EINxD <= RegxDP ;
KINxD <= KeyxDP ;
-----------------------------------------------------------------------------------------------
dbl0: entity dbl (func) port map (LRegxDP , Ldollar);
dbl1: entity dbl (func) port map (Ldollar , L(0));

gen: for i in 0 to 7 generate

double:  entity dbl (func) port map (L(i) , L(i+1));
 
end generate gen;
-----------------------------------------------------------------------------------------------
LRegxDN <= EOUTxD;
ARegxDN <= EOUTxD xor ARegxDP; 
SumxDN  <= data   xor SumxDP;

o_input: process(StatusxDP, FcntxDP, empty_ad, empty_msg, last_block, last_partial, prepare_lstar ,process_pt,final_tag, nonce_enc,process_ad,Ozero,ORegxDP,Lntz)
begin
if prepare_lstar='1' then 
ORegxDN <= (others=>'0');
elsif nonce_enc='1' then 
ORegxDN <= Ozero;
else
ORegxDN <= Lntz   xor ORegxDP;
end if;
end process o_input;
-----------------------------------------------------------------------------------------------
Count<= std_logic_vector(to_unsigned(CountxDP,8));
nt: entity ntz (lut) port map (Count, NoutxD);
N <= to_integer(unsigned(NoutxD(2 downto 0)));
Lntz <= LregxDP when last_block='1' and last_partial='1' else L(N);
-----------------------------------------------------------------------------------------------


LoadxS  <= not reset_bc;
Load_LxS<= '1' when prepare_lstar='1' and FcntxDP=14 else '0';
Load_OxS<= '1' when (prepare_lstar='1' or process_ad='1' or nonce_enc='1' or process_pt='1') and FcntxDP=14 else '0';
Load_AxS<= '1' when (process_ad='1' and FcntxDP=14) or (prepare_lstar='1'  and FcntxDP=14) else '0';
Load_SxS<= '1' when (process_pt='1' and FcntxDP=1) or (nonce_enc='1'  and FcntxDP=14) else '0';
reset_s <= '0' when (nonce_enc='1'  and FcntxDP=14) else '1';
reset_a <= '0' when (prepare_lstar='1'  and FcntxDP=14) else '1';
-----------------------------------------------------------------------------------------------

Opad <= data when last_block ='1' and last_partial='1' else ORegxDN ;

bc_input: process(StatusxDP, FcntxDP, empty_ad, empty_msg, last_block, last_partial, prepare_lstar ,process_pt,final_tag, nonce_enc,process_ad,data,ORegxDN,ORegxDP,SumxDP,Ldollar, LregxDP, nonce,Lntz) 
begin
if prepare_lstar ='1' then 

        InxD<= (others=>'0');

elsif process_pt='1' and  last_partial ='1' then

	InxD <= ORegxDP xor LregxDP;

 

elsif final_tag='1' then 

	InxD <= SumxDP xor ORegxDP xor Ldollar;


elsif nonce_enc='1' then 

        InxD <= x"00"& x"00" & x"00" & x"01" & nonce(95 downto 6) & "00" & x"0" ;

else
	InxD <= data xor ORegxDP xor Lntz;

end if;


end process bc_input;
InpKxD<= InxD xor key;
-----------------------------------------------------------------------------------------------
StpartxD<= EOUTxD (127 downto 64) xor EOUTxD(119 downto 56);
stretch <= EOUTxD & StpartxD;
Ozero   <= stretch(191-bottom downto 64-bottom);
bottom <= to_integer(unsigned(nonce(5 downto 0)));
-----------------------------------------------------------------------------------------------
  
 
-----------------------------------------------------------------------------------------------
ciphertext <= EOUTxD xor Opad;

tag <= EOUTxD xor ARegxDP;

cipher_ready <= '1' when process_pt='1' and FcntxDP=14 else '0';

tag_ready <= '1' when final_tag='1' and FcntxDP=14 else '0';

ready_full<= '1' when final_tag='1' and FcntxDP=14 else '0';

ready_block <= '1' when ((prepare_lstar='1' and empty_ad='0') or (process_ad='1' and last_block='0') or  (nonce_enc='1' and empty_msg='0') or (process_pt='1' and last_block='0')) 
                        and FcntxDP=14 else '0';
-----------------------------------------------------------------------------------------------

end architecture py;
