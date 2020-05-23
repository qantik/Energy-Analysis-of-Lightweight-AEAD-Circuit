library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;  
use work.all;


entity pyjamask_aead is
 
        
    port (clk   : in std_logic;
          reset : in std_logic; -- active low

          key    : in std_logic_vector(127 downto 0);
          nonce1 : in std_logic_vector(95 downto 0);
          nonce2 : in std_logic_vector(95 downto 0);
          nonce3 : in std_logic_vector(95 downto 0);
 
          -- A data block is either associated data or plaintext.
          -- last_block indicates whether the current ad or plaintext
          -- block is the last one with last_partial indicating whether
          -- said block is only partially filled.
          data1         : in std_logic_vector(127 downto 0);
          data2         : in std_logic_vector(127 downto 0);        
          data3         : in std_logic_vector(127 downto 0);
 

          r1         : in std_logic_vector(127 downto 0);
          r2         : in std_logic_vector(127 downto 0);        
          r3         : in std_logic_vector(127 downto 0);
 


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

          ciphertext1   : out std_logic_vector(127 downto 0);
          ciphertext2   : out std_logic_vector(127 downto 0);
          ciphertext3   : out std_logic_vector(127 downto 0);
 

          tag1          : out std_logic_vector(127 downto 0);
          tag2          : out std_logic_vector(127 downto 0);
          tag3          : out std_logic_vector(127 downto 0) 
 
);

end pyjamask_aead;

architecture py of pyjamask_aead is 
signal E:  std_logic_vector(127 downto 0);


signal prepare_lstar, process_ad, nonce_enc,process_pt,final_tag : std_logic;

signal reset_bc,reset_s,reset_a, LoadxS : std_logic;

signal clk_l, clk_o, clk_a, clk_s ,clk_k : std_logic_vector(11 downto 0);

signal FcntxDP, FcntxDN: integer range 0 to 31;

signal f: std_logic_vector(4 downto 0);

signal CountxDP, CountxDN: integer range 0 to 255;

signal StatusxDP, StatusxDN : std_logic_vector(2 downto 0);

signal In1xD,In2xD,In3xD,In4xD, InpK1xD,InpK2xD,InpK3xD, EIN1xD,EIN2xD,EIN3xD, KINxD, EOUT1xD,EOUT2xD,EOUT3xD, KOUTxD :  std_logic_vector(127 downto 0);



signal Reg1xDP,Reg2xDP,Reg3xDP,   KeyxDP, LReg1xDP, LReg1xDN, LReg2xDP, LReg2xDN, LReg3xDP, LReg3xDN :  std_logic_vector(127 downto 0);

signal AReg1xDP, AReg1xDN, AReg2xDP, AReg2xDN, AReg3xDP, AReg3xDN   :  std_logic_vector(127 downto 0);

signal Sum1xDP, Sum1xDN, Sum2xDP, Sum2xDN, Sum3xDP, Sum3xDN   :  std_logic_vector(127 downto 0);

signal OReg1xDP, OReg1xDN, OReg2xDP, OReg2xDN, OReg3xDP, OReg3xDN  :  std_logic_vector(127 downto 0);



signal Ldollar1, Ldollar2, Ldollar3 , Lntz1, Lntz2,Lntz3   :  std_logic_vector(127 downto 0);

type Sigtype is array (0 to 10) of std_logic_vector(127 downto 0);
signal L1,L2,L3 : Sigtype;

signal N : integer range 0 to 7;

signal NoutxD:  std_logic_vector(2 downto 0);

signal bottom : integer range 0 to 63;

signal Stpart1xD,Stpart2xD,Stpart3xD  :  std_logic_vector(63 downto 0);

signal stretch1, stretch2, stretch3   :  std_logic_vector(191 downto 0);

signal Ozero1, Ozero2, Ozero3 , Opad1, Opad2, Opad3:  std_logic_vector(127 downto 0);

signal Count:  std_logic_vector(7 downto 0);
signal CxDP,CxDN:  std_logic;
begin

p_clk: process (reset, clk)
         begin
           if reset='0' then
             StatusxDP  <= "000";
             CountxDP<=0;
             FcntxDP <= 0;
             CxDP <='0';
 
           elsif clk'event and clk ='1' then
             
                  StatusxDP  <= StatusxDN;
                  FcntxDP <= FcntxDN;
                  CountxDP<= CountxDN;
                  CxDP <= CxDN;

                  
           end if;
end process p_clk;


CxDN <= (not CxDP) when FcntxDP<28 else CxDP;
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
   
   

    if FcntxDP < 28 then
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

   if FcntxDP <28 then
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

        if FcntxDP <28 then
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

    if FcntxDP <28 then
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

    if FcntxDP <28 then
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

BC_01: entity pyjamaskbc (behav) port map (EIN1xD,  EIN2xD,EIN3xD,  KINxD,   clk,reset_bc,EOUT1xD, EOUT2xD,EOUT3xD,  KOUTxD );

sr01 : entity Kreg (kr) port map (EOUT1xD , InpK1xD,clk,LoadxS,  Reg1xDP);
sr02 : entity Kreg (kr) port map (EOUT2xD , InpK2xD,clk,LoadxS,  Reg2xDP);
sr03 : entity Kreg (kr) port map (EOUT3xD , InpK3xD,clk,LoadxS,  Reg3xDP);
 

-- E<= EOUT1xD xor  EOUT2xD xor  EOUT3xD     ;



s1: for i in 0 to 3 generate  
lr01 : entity Dreg (dr) port map (LReg1xDN(127 -32*i downto 96 -32*i) , clk_l(i) , LReg1xDP(127-32*i downto 96-32*i));
or01 : entity Dreg (dr) port map (OReg1xDN(127 -32*i downto 96 -32*i) , clk_o(i) , OReg1xDP(127 -32*i downto 96 -32*i));
au01 : entity DRreg (drr) port map (AReg1xDN (127 -32*i downto 96 -32*i), clk_a(i), reset_a,  AReg1xDP(127 -32*i downto 96 -32*i));
sr02:  entity DRreg (drr) port map (Sum1xDN (127 -32*i downto 96 -32*i) , clk_s(i), reset_s,  Sum1xDP(127 -32*i downto 96 -32*i));

kr01 : entity Kreg1 (kr) port map (KOUTxD (127 -32*i downto 96 -32*i), key(127 -32*i downto 96 -32*i) ,  clk_k(i),LoadxS,  KeyxDP(127 -32*i downto 96 -32*i));
end generate s1;

s2: for i in 0 to 3 generate  
lr01 : entity Dreg (dr) port map (LReg2xDN(127 -32*i downto 96 -32*i) , clk_l(i+4) , LReg2xDP(127-32*i downto 96-32*i));
or01 : entity Dreg (dr) port map (OReg2xDN(127 -32*i downto 96 -32*i) , clk_o(i+4) , OReg2xDP(127 -32*i downto 96 -32*i));
au01 : entity DRreg (drr) port map (AReg2xDN (127 -32*i downto 96 -32*i), clk_a(i+4), reset_a,  AReg2xDP(127 -32*i downto 96 -32*i));
sr02:  entity DRreg (drr) port map (Sum2xDN (127 -32*i downto 96 -32*i) , clk_s(i+4), reset_s,  Sum2xDP(127 -32*i downto 96 -32*i));
end generate s2;

s3: for i in 0 to 3 generate  
lr01 : entity Dreg (dr) port map (LReg3xDN(127 -32*i downto 96 -32*i) , clk_l(i+8) , LReg3xDP(127-32*i downto 96-32*i));
or01 : entity Dreg (dr) port map (OReg3xDN(127 -32*i downto 96 -32*i) , clk_o(i+8) , OReg3xDP(127 -32*i downto 96 -32*i));
au01 : entity DRreg (drr) port map (AReg3xDN (127 -32*i downto 96 -32*i), clk_a(i+8), reset_a,  AReg3xDP(127 -32*i downto 96 -32*i));
sr02:  entity DRreg (drr) port map (Sum3xDN (127 -32*i downto 96 -32*i) , clk_s(i+8), reset_s,  Sum3xDP(127 -32*i downto 96 -32*i));
end generate s3;

 



-----------------------------------------------------------------------------------------------
EIN1xD <= Reg1xDP ;
EIN2xD <= Reg2xDP ;
EIN3xD <= Reg3xDP ;
 
KINxD <= KeyxDP ;
-----------------------------------------------------------------------------------------------
dbl0: entity dbl (func) port map (LReg1xDP , Ldollar1);
dbl1: entity dbl (func) port map (Ldollar1 , L1(0));

dbl2: entity dbl (func) port map (LReg2xDP , Ldollar2);
dbl3: entity dbl (func) port map (Ldollar2 , L2(0));

dbl4: entity dbl (func) port map (LReg3xDP , Ldollar3);
dbl5: entity dbl (func) port map (Ldollar3 , L3(0));

 

gen: for i in 0 to 7 generate

double1:  entity dbl (func) port map (L1(i) , L1(i+1));
double2:  entity dbl (func) port map (L2(i) , L2(i+1));
double3:  entity dbl (func) port map (L3(i) , L3(i+1));
 
end generate gen;
-----------------------------------------------------------------------------------------------
LReg1xDN <= EOUT1xD;
LReg2xDN <= EOUT2xD;
LReg3xDN <= EOUT3xD;
 


AReg1xDN <= EOUT1xD xor AReg1xDP; 
AReg2xDN <= EOUT2xD xor AReg2xDP; 
AReg3xDN <= EOUT3xD xor AReg3xDP; 
 

Sum1xDN  <= data1   xor Sum1xDP;
Sum2xDN  <= data2   xor Sum2xDP;
Sum3xDN  <= data3   xor Sum3xDP;
 


o_input: process(StatusxDP, FcntxDP, empty_ad, empty_msg, last_block, last_partial, prepare_lstar ,process_pt,final_tag, nonce_enc,process_ad,Ozero1,Ozero2,Ozero3,
                 OReg1xDP,OReg2xDP,OReg3xDP,Lntz1,Lntz2,Lntz3)
begin
if prepare_lstar='1' then 
OReg1xDN <= (others=>'0');
OReg2xDN <= (others=>'0');
OReg3xDN <= (others=>'0');
 
elsif nonce_enc='1' then 
OReg1xDN <= Ozero1;
OReg2xDN <= Ozero2;
OReg3xDN <= Ozero3;
 
else
OReg1xDN <= Lntz1   xor OReg1xDP;
OReg2xDN <= Lntz2   xor OReg2xDP;
OReg3xDN <= Lntz3   xor OReg3xDP;
 
end if;
end process o_input;
-----------------------------------------------------------------------------------------------
Count<= std_logic_vector(to_unsigned(CountxDP,8));
nt: entity ntz (lut) port map (Count, NoutxD);
N <= to_integer(unsigned(NoutxD(2 downto 0)));

Lntz1 <= Lreg1xDP when last_block='1' and last_partial='1' else L1(N);
Lntz2 <= Lreg2xDP when last_block='1' and last_partial='1' else L2(N);
Lntz3 <= Lreg3xDP when last_block='1' and last_partial='1' else L3(N);
 
-----------------------------------------------------------------------------------------------


LoadxS  <= not reset_bc;
f<= std_logic_vector(to_unsigned(FcntxDP,5));

cg: for i in  0 to 11 generate 
cg01: entity cgate (cg) port map (clk,prepare_lstar, process_ad, nonce_enc, process_pt, f, CxDP,clk_l(i),clk_o(i),clk_a(i),clk_s(i),clk_k(i)); 
end generate cg;
 
reset_s <= '0' when (nonce_enc='1'  and FcntxDP=28) else '1';
reset_a <= '0' when (prepare_lstar='1'  and FcntxDP=28) else '1';
-----------------------------------------------------------------------------------------------

Opad1 <= data1 when last_block ='1' and last_partial='1' else OReg1xDN ;
Opad2 <= data2 when last_block ='1' and last_partial='1' else OReg2xDN ;
Opad3 <= data3 when last_block ='1' and last_partial='1' else OReg3xDN ;
 

bc_input: process(StatusxDP, FcntxDP, empty_ad, empty_msg, last_block, last_partial, prepare_lstar ,process_pt,final_tag, nonce_enc,process_ad,
                  data1,data2,data3,OReg1xDN,OReg1xDP,OReg2xDP, OReg2xDN, OReg3xDP, OReg3xDN, Sum1xDP, Sum2xDP, Sum3xDP,  
                  Ldollar1,Ldollar2,Ldollar3, Lreg1xDP,Lreg2xDP,Lreg3xDP, nonce1,nonce2, nonce3, Lntz1,Lntz2,Lntz3) 
begin
if prepare_lstar ='1' then 

        In1xD<= r1;
        In2xD<= r2;
        In3xD<= r3;
 

elsif process_pt='1' and  last_partial ='1' then

	In1xD <= OReg1xDP xor Lreg1xDP;
	In2xD <= OReg2xDP xor Lreg2xDP;
 	In3xD <= OReg3xDP xor Lreg3xDP;
 

elsif final_tag='1' then 

	In1xD <= Sum1xDP xor OReg1xDP xor Ldollar1;
	In2xD <= Sum2xDP xor OReg2xDP xor Ldollar2;
	In3xD <= Sum3xDP xor OReg3xDP xor Ldollar3;
 

elsif nonce_enc='1' then 

        In1xD <= x"00"& x"00" & x"00" & x"01" & nonce1(95 downto 6) & "00" & x"0" ;
        In2xD <= x"00"& x"00" & x"00" & x"00" & nonce2(95 downto 6) & "00" & x"0" ;
        In3xD <= x"00"& x"00" & x"00" & x"00" & nonce3(95 downto 6) & "00" & x"0" ;
 

else
	In1xD <= data1 xor OReg1xDP xor Lntz1;
	In2xD <= data2 xor OReg2xDP xor Lntz2;
	In3xD <= data3 xor OReg3xDP xor Lntz3;
 
end if;


end process bc_input;
InpK1xD<= In1xD xor key;
InpK2xD<= In2xD ;--xor key;
InpK3xD<= In3xD ;--xor key;
 

-----------------------------------------------------------------------------------------------
Stpart1xD<= EOUT1xD (127 downto 64) xor EOUT1xD(119 downto 56);
Stpart2xD<= EOUT2xD (127 downto 64) xor EOUT2xD(119 downto 56);
Stpart3xD<= EOUT3xD (127 downto 64) xor EOUT3xD(119 downto 56);
 

stretch1 <= EOUT1xD & Stpart1xD;
stretch2 <= EOUT2xD & Stpart2xD;
stretch3 <= EOUT3xD & Stpart3xD;
 

Ozero1   <= stretch1(191-bottom downto 64-bottom);
Ozero2   <= stretch2(191-bottom downto 64-bottom);
Ozero3   <= stretch3(191-bottom downto 64-bottom);
 


bottom <= to_integer(unsigned(nonce1(5 downto 0)));
-----------------------------------------------------------------------------------------------
  
 
-----------------------------------------------------------------------------------------------
ciphertext1 <= EOUT1xD xor Opad1;
ciphertext2 <= EOUT2xD xor Opad2;
ciphertext3 <= EOUT3xD xor Opad3;
 


tag1 <= EOUT1xD xor AReg1xDP;
tag2 <= EOUT2xD xor AReg2xDP;
tag3 <= EOUT3xD xor AReg3xDP;
 

cipher_ready <= '1' when process_pt='1' and FcntxDP=28 else '0';

tag_ready <= '1' when final_tag='1' and FcntxDP=28 else '0';

ready_full<= '1' when final_tag='1' and FcntxDP=28 else '0';

ready_block <= '1' when ((prepare_lstar='1' and empty_ad='0') or (process_ad='1' and last_block='0') or  (nonce_enc='1' and empty_msg='0') or (process_pt='1' and last_block='0')) 
                        and FcntxDP=28 else '0';
-----------------------------------------------------------------------------------------------

end architecture py;
