library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; 



entity cgate is 
port ( clk  : in std_logic ;
       prepare_lstar, process_ad, nonce_enc, process_pt : in std_logic ; 
 
       clk_l,clk_o,clk_a,clk_s:  out std_logic ); 
 
       
end entity cgate;

architecture cg of cgate is

signal Load_LxS,Load_OxS,Load_AxS,Load_SxS: std_logic ; 

 

begin

Load_LxS<= '0' when prepare_lstar='1'  else '1';
Load_OxS<= '0' when (prepare_lstar='1' or process_ad='1' or nonce_enc='1' or process_pt='1')  else '1';
Load_AxS<= '0' when (process_ad='1' ) or (prepare_lstar='1'  ) else '1';
Load_SxS<= '0' when (process_pt='1' ) or (prepare_lstar='1'   ) else '1';
 

clk_l  <= clk  or Load_LxS  ; 
clk_o  <= clk  or Load_OxS  ;
clk_a  <= clk  or Load_AxS  ;
clk_s  <= clk  or Load_SxS  ;
 

end architecture cg;
 
