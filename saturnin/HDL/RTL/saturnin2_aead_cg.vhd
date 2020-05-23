library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;  
use work.all;


entity saturnin_aead is
 
        
    port (clk   : in std_logic;
          reset : in std_logic; -- active low

          key   : in std_logic_vector(255 downto 0);
          nonce : in std_logic_vector(127 downto 0);

          -- A data block is either associated data or plaintext.
          -- last_block indicates whether the current ad or plaintext
          -- block is the last one with last_partial indicating whether
          -- said block is only partially filled.
          data         : in std_logic_vector(255 downto 0);
          mask	       : in std_logic_vector(255 downto 0);
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

          ciphertext   : out std_logic_vector(255 downto 0);
          tag          : out std_logic_vector(255 downto 0));

end saturnin_aead;

architecture sat of saturnin_aead is 


signal init_enc, process_ad, ctr_enc, alternate_casc,final_tag : std_logic;

signal reset_bc, LoadxS, Load_LxS ,Load_IxS : std_logic;

signal FcntxDP, FcntxDN: integer range 0 to 21;

signal CountxDP, CountxDN: integer range 0 to 255;

signal StatusxDP, StatusxDN : std_logic_vector(2 downto 0);

 

signal BINxDP, LRegxDP, LRegxDN,  IRegxDP, IRegxDN, EINxD,KeyxD,  EOUTxD,   EPOUTxD,BINxD,BINPKxD,ct,cm ,o:  std_logic_vector(255 downto 0);

 
signal RCPOUTxD , RINxD ,RCINxD ,  RINxDP ,RCOUTxD:  std_logic_vector(31 downto 0);
 
 

 signal f :  std_logic_vector(4 downto 0);


 signal clk_l,clk_i,clk_l1,clk_i1,clk_l2,clk_i2,clk_l3,clk_i3   : std_logic;
 signal clk_l4,clk_i4,clk_l5,clk_i5,clk_l6,clk_i6,clk_l7,clk_i7   : std_logic;


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

   init_enc  <='0';
   
   final_tag  <='0';
   process_ad <='0'; 

   ctr_enc<='0';
   alternate_casc  <='0';

   CountxDN<=CountxDP;
   
   case StatusxDP is 
   when "000" => init_enc <= '1';
   
   

    if FcntxDP <10 then
                                if FcntxDP = 0 then
      					reset_bc <= '0';
                                        CountxDN<=0;
                                end if;

                                FcntxDN  <= FcntxDP+1;
                                StatusxDN <= StatusxDP;
  
                                
                             else
                                FcntxDN  <= 0;

 
                                StatusxDN <= "001";
                                                  
                             end if;  



   when "001" =>  process_ad <='1';

   if FcntxDP <10 then
 		  if FcntxDP = 0 then
      			   reset_bc <= '0';
                  end if;
                  
                  FcntxDN <= FcntxDP+1;
                  StatusxDN <= StatusxDP;
   else
                 if last_block = '1' then
                       if empty_msg = '1' then 
                          StatusxDN <= "000";
                       else
                          StatusxDN <= "010";
                       end if;
                       CountxDN<=1;
                 else
                       StatusxDN <= StatusxDP; 
                       CountxDN<=CountxDP+1;
                 end if;
 

 
                 FcntxDN  <= 0;
   end if;  
                   
            
   when "010" => ctr_enc <= '1';

        if FcntxDP <10 then
 		  if FcntxDP = 0 then
      			   reset_bc <= '0';

                  end if;
                  
                  FcntxDN <= FcntxDP+1;
                  StatusxDN <= StatusxDP;
       else
                  
                  StatusxDN <= "011";
                  CountxDN<=CountxDP;

                  FcntxDN  <= 0;
   end if;  
   
   when "011" => alternate_casc <= '1';

    if FcntxDP <10 then
		  if FcntxDP = 0 then
      			   reset_bc <= '0';                                        

                  end if;
                  FcntxDN <= FcntxDP+1;
                  StatusxDN <= StatusxDP;
   else
                 if last_block = '1' then
                    if last_partial ='1' then 
                       StatusxDN<= "000";
                    else
                       StatusxDN<= "100";
                    end if;
                    CountxDN<=0;
                 else
                    StatusxDN <= "010"; 
                    CountxDN<=CountxDP+1;
                 end if;

 
                 FcntxDN  <= 0;
   end if;  
   when "100" => final_tag <= '1';

    if FcntxDP <10 then
 		  if FcntxDP = 0 then
      			   reset_bc <= '0';

                  end if;
                  
                  FcntxDN <= FcntxDP+1;
                  StatusxDN <= StatusxDP;
       else
                  
                  StatusxDN <= "000";
                  CountxDN<=CountxDP;

                  FcntxDN  <= 1;
   end if;  

   when others =>  FcntxDN<=FcntxDP; CountxDN<=CountxDP ;  StatusxDN <= StatusxDP;
end case;
end process p_main;
 

-----------------------------------------------------------------------------------------------

BC_01: entity saturninbc (behav) port map (EINxD,KeyxD,RCINxD, clk,reset_bc,EOUTxD, RCOUTxD   );

sr01 : entity Kreg (kr) port map (EPOUTxD , BINPKxD   ,clk,LoadxS,  BINxDP);

 

ir01  : entity Dreg (dr) port map (LRegxDN (255 downto 224) ,         clk_l,  LRegxDP(255 downto 224));
ir02  : entity Dreg (dr) port map (IRegxDN (255 downto 224) ,         clk_i,  IRegxDP(255 downto 224));

ir01a  : entity Dreg (dr) port map (LRegxDN (223 downto 192) ,         clk_l1,  LRegxDP(223 downto 192));
ir02a  : entity Dreg (dr) port map (IRegxDN (223 downto 192) ,         clk_i1,  IRegxDP(223 downto 192));


ir011 : entity Dreg (dr) port map (LRegxDN (191 downto 160) ,         clk_l2,  LRegxDP(191 downto 160));
ir021 : entity Dreg (dr) port map (IRegxDN (191 downto 160) ,         clk_i2,  IRegxDP(191 downto 160));

ir011a : entity Dreg (dr) port map (LRegxDN (159 downto 128) ,         clk_l3,  LRegxDP(159 downto 128));
ir021a : entity Dreg (dr) port map (IRegxDN (159 downto 128) ,         clk_i3,  IRegxDP(159 downto 128));


ir012 : entity Dreg (dr) port map (LRegxDN (127 downto 96)  ,         clk_l4,  LRegxDP(127 downto 96));
ir022 : entity Dreg (dr) port map (IRegxDN (127 downto 96)  ,         clk_i4,  IRegxDP(127 downto 96));

ir012a : entity Dreg (dr) port map (LRegxDN (95 downto 64)  ,         clk_l5,  LRegxDP(95 downto 64));
ir022a : entity Dreg (dr) port map (IRegxDN (95 downto 64)  ,         clk_i5,  IRegxDP(95 downto 64));


ir013 : entity Dreg (dr) port map (LRegxDN (63 downto 32)    ,         clk_l6,  LRegxDP(63 downto 32));
ir023 : entity Dreg (dr) port map (IRegxDN (63 downto 32)    ,         clk_i6,  IRegxDP(63 downto 32));

ir013a : entity Dreg (dr) port map (LRegxDN (31 downto 0)    ,         clk_l7,  LRegxDP(31 downto 0));
ir023a : entity Dreg (dr) port map (IRegxDN (31 downto 0)    ,         clk_i7,  IRegxDP(31 downto 0));

rc01 : entity Rreg (rr) port map (RCOUTxD , RINxD  ,clk,   LoadxS,  RINxDP );

 
-----------------------------------------------------------------------------------------------
EINxD  <= BINxDP ;
RCINxD <= RINxDP ;
-----------------------------------------------------------------------------------------------
EPOUTxD  <= EOUTxD ; 

-----------------------------------------------------------------------------------------------
LRegxDN <=  EOUTxD xor IRegxDP;

IRegxDN <= nonce & x"80000000000000000000000000000000" when (init_enc='1' and FcntxDP=1) else 
           data when process_ad='1' else
           cm   when ctr_enc='1' else
           x"8000000000000000000000000000000000000000000000000000000000000000";
 
k_input: process(StatusxDP, FcntxDP, empty_ad, empty_msg, last_block, last_partial, ctr_enc,process_ad ,init_enc, final_tag, alternate_casc, LRegxDP, key)
begin
if init_enc='1' or ctr_enc='1' then 
KeyxD <= key;
elsif process_ad='1' or alternate_casc='1' or final_tag='1' then 
KeyxD <= LRegxDP;
 
end if;
end process k_input;

msk: for u in 0 to 255 generate 
        cm(u)<= o(u) or (ct(u) and mask(u));
end generate msk;

o(255)<='0';
off: for u in 0 to 254 generate 
        o(u)<= mask(u) xor mask(u+1);
end generate off;

-----------------------------------------------------------------------------------------------
Count<= std_logic_vector(to_unsigned(CountxDP,8));
 
-----------------------------------------------------------------------------------------------


LoadxS  <= not reset_bc;


cg:  entity cgate (cg) port map( clk, init_enc, process_ad, alternate_casc,ctr_enc, last_block, last_partial, f, clk_l, clk_i); 
cg1: entity cgate (cg) port map( clk, init_enc, process_ad, alternate_casc,ctr_enc, last_block, last_partial, f, clk_l1, clk_i1); 
cg2: entity cgate (cg) port map( clk, init_enc, process_ad, alternate_casc,ctr_enc, last_block, last_partial, f, clk_l2, clk_i2); 
cg3: entity cgate (cg) port map( clk, init_enc, process_ad, alternate_casc,ctr_enc, last_block, last_partial, f, clk_l3, clk_i3); 
cg4: entity cgate (cg) port map( clk, init_enc, process_ad, alternate_casc,ctr_enc, last_block, last_partial, f, clk_l4, clk_i4); 
cg5: entity cgate (cg) port map( clk, init_enc, process_ad, alternate_casc,ctr_enc, last_block, last_partial, f, clk_l5, clk_i5); 
cg6: entity cgate (cg) port map( clk, init_enc, process_ad, alternate_casc,ctr_enc, last_block, last_partial, f, clk_l6, clk_i6); 
cg7: entity cgate (cg) port map( clk, init_enc, process_ad, alternate_casc,ctr_enc, last_block, last_partial, f, clk_l7, clk_i7); 
f <=   std_logic_vector(to_unsigned(FcntxDP,5));
-----------------------------------------------------------------------------------------------

 

bc_input: process(StatusxDP, FcntxDP, empty_ad, empty_msg, last_block, last_partial, init_enc, process_ad, alternate_casc,final_tag, ctr_enc, nonce ,data, Count, LRegxDP) 
begin
if init_enc ='1' then 

        BINxD<= nonce & x"80000000000000000000000000000000";
        RINxD<= x"fea2fea2";
      
elsif process_ad='1'   then

	BINxD <=data;
        if last_block ='1'  then
           RINxD <= x"fea3fea3";
        else
           RINxD <= x"fea2fea2";       
        end if;

elsif ctr_enc ='1' then 

	BINxD <= nonce & x"800000000000000000000000000000" & Count;
	RINxD<= x"fea1fea1";

elsif alternate_casc='1' then 

       BiNxD<= IRegxDP;
 
       if last_block ='1' and last_partial ='1' then
           RINxD <= x"fea5fea5";
       else
           RINxD <= x"fea4fea4";       
        end if;

 else 

        BINxD <=  x"80000000000000000000000000000000" & x"00000000000000000000000000000000" ;
        RINxD <= x"fea5fea5";
end if;
end process bc_input;
BINPKxD<= BINxD xor KeyxD;
-----------------------------------------------------------------------------------------------
 
-----------------------------------------------------------------------------------------------
  
 
-----------------------------------------------------------------------------------------------
ct <= EOUTxD xor data;

ciphertext <= ct;

tag <= EOUTxD xor IRegxDP;

cipher_ready <= '1' when ctr_enc='1' and FcntxDP=10 else '0';

tag_ready <= '1' when (alternate_casc='1' and FcntxDP=10 and last_block='1' and last_partial='1') or (empty_msg='1' and process_ad='1' and FcntxDP=10)  
                      or (final_tag='1' and FcntxDP=10) else '0';

ready_full<= '1' when (alternate_casc='1' and FcntxDP=10 and last_block='1' and last_partial='1') or (empty_msg='1' and process_ad='1' and FcntxDP=10)  
                      or (final_tag='1' and FcntxDP=10) else '0';

ready_block <= '1' when ((init_enc='1' or (process_ad='1' and last_block='0') )  and FcntxDP=10) or (ctr_enc='1' and FcntxDP=9) else '0';
-----------------------------------------------------------------------------------------------

end architecture sat;
