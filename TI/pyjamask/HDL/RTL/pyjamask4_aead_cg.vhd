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

signal reset_bc,reset_s,reset_a, LoadxS, clk_l, clk_o, clk_a, clk_s  ,clk_l1, clk_o1, clk_a1, clk_s1: std_logic;

signal clk_l2, clk_o2, clk_a2, clk_s2  ,clk_l3, clk_o3, clk_a3, clk_s3: std_logic;

signal FcntxDP, FcntxDN: integer range 0 to 15;

signal f: std_logic_vector(3 downto 0);

signal CountxDP, CountxDN: integer range 0 to 255;

signal StatusxDP, StatusxDN : std_logic_vector(2 downto 0);

signal InxD,InpKxD, EINxD, KINxD, EOUTxD,CTOUTxD, KOUTxD :  std_logic_vector(127 downto 0);

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
   
   

    if FcntxDP <4 then
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

   if FcntxDP <4 then
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

        if FcntxDP <4 then
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

    if FcntxDP <4 then
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

    if FcntxDP <4 then
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

BC_01: entity pyjamaskbc (behav) port map (EINxD,KINxD,clk,reset_bc,EOUTxD,CTOUTxD,KOUTxD );

sr01 : entity Kreg (kr) port map (EOUTxD , InpKxD  ,clk,LoadxS,  RegxDP);

kr01 : entity Kreg (kr) port map (KOUTxD , key ,clk,LoadxS, KeyxDP);

lr01 : entity Dreg (dr) port map (LRegxDN(127 downto 96) , clk_l , LRegxDP(127 downto 96));

or01 : entity Dreg (dr) port map (ORegxDN(127 downto 96) , clk_o , ORegxDP(127 downto 96));

au01 : entity DRreg (drr) port map (ARegxDN (127 downto 96), clk_a, reset_a,  ARegxDP(127 downto 96));

sr02:  entity DRreg (drr) port map (SumxDN (127 downto 96) , clk_s, reset_s,  SumxDP(127 downto 96));


lr011 : entity Dreg (dr) port map (LRegxDN(95 downto 64) , clk_l1 , LRegxDP(95 downto 64));

or011 : entity Dreg (dr) port map (ORegxDN(95 downto 64) , clk_o1 , ORegxDP(95 downto 64));

au011 : entity DRreg (drr) port map (ARegxDN(95 downto 64) , clk_a1, reset_a,  ARegxDP(95 downto 64));

sr021:  entity DRreg (drr) port map (SumxDN(95 downto 64)  , clk_s1, reset_s,  SumxDP(95 downto 64));


lr012 : entity Dreg (dr) port map (LRegxDN(63 downto 32) , clk_l2 , LRegxDP(63 downto 32));

or012 : entity Dreg (dr) port map (ORegxDN(63 downto 32) , clk_o2 , ORegxDP(63 downto 32));

au012 : entity DRreg (drr) port map (ARegxDN(63 downto 32) , clk_a2, reset_a,  ARegxDP(63 downto 32));

sr022:  entity DRreg (drr) port map (SumxDN(63 downto 32)  , clk_s2, reset_s,  SumxDP(63 downto 32));


lr013 : entity Dreg (dr) port map (LRegxDN(31 downto 0) , clk_l3 , LRegxDP(31 downto 0));

or013 : entity Dreg (dr) port map (ORegxDN(31 downto 0) , clk_o3 , ORegxDP(31 downto 0));

au013 : entity DRreg (drr) port map (ARegxDN(31 downto 0) , clk_a3, reset_a,  ARegxDP(31 downto 0));

sr023:  entity DRreg (drr) port map (SumxDN(31 downto 0)  , clk_s3, reset_s,  SumxDP(31 downto 0));

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
LRegxDN <= CTOUTxD;
ARegxDN <= CTOUTxD xor ARegxDP; 
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
f<= std_logic_vector(to_unsigned(FcntxDP,4));
cg01: entity cgate (cg) port map (clk,prepare_lstar, process_ad, nonce_enc, process_pt, f, clk_l,clk_o,clk_a,clk_s); 
cg02: entity cgate (cg) port map (clk,prepare_lstar, process_ad, nonce_enc, process_pt, f, clk_l1,clk_o1,clk_a1,clk_s1); 
cg03: entity cgate (cg) port map (clk,prepare_lstar, process_ad, nonce_enc, process_pt, f, clk_l2,clk_o2,clk_a2,clk_s2); 
cg04: entity cgate (cg) port map (clk,prepare_lstar, process_ad, nonce_enc, process_pt, f, clk_l3,clk_o3,clk_a3,clk_s3); 


reset_s <= '0' when (nonce_enc='1'  and FcntxDP=4) else '1';
reset_a <= '0' when (prepare_lstar='1'  and FcntxDP=4) else '1';
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
StpartxD<= CTOUTxD (127 downto 64) xor CTOUTxD(119 downto 56);
stretch <= CTOUTxD & StpartxD;
Ozero   <= stretch(191-bottom downto 64-bottom);
bottom <= to_integer(unsigned(nonce(5 downto 0)));
-----------------------------------------------------------------------------------------------
  
 
-----------------------------------------------------------------------------------------------
ciphertext <= CTOUTxD xor Opad;

tag <= CTOUTxD xor ARegxDP;

cipher_ready <= '1' when process_pt='1' and FcntxDP=4 else '0';

tag_ready <= '1' when final_tag='1' and FcntxDP=4 else '0';

ready_full<= '1' when final_tag='1' and FcntxDP=4 else '0';

ready_block <= '1' when ((prepare_lstar='1' and empty_ad='0') or (process_ad='1' and last_block='0') or  (nonce_enc='1' and empty_msg='0') or (process_pt='1' and last_block='0')) 
                        and FcntxDP=4 else '0';
-----------------------------------------------------------------------------------------------

end architecture py;
