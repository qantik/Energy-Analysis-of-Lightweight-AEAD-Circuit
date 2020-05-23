library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; 



entity cgate is 
port ( clk  : in std_logic ;
       init_enc, process_ad, alternate_casc,ctr_enc, last_block, last_partial : in std_logic ; 
       f : in std_logic_vector(4 downto 0) ;  
       clk_l,clk_i:  out std_logic ); 
 
       
end entity cgate;

architecture cg of cgate is

signal Load_LxS,Load_IxS: std_logic ; 

signal FcntxdP: integer range 0 to 21;

begin
 
Load_LxS<= '0' when ((init_enc='1' or process_ad='1' or alternate_casc='1') and FcntxDP=10)  else '1';

Load_IxS<= '0' when (init_enc='1' and FcntxDP=1) or (process_ad='1' and  FcntxDP=1) or (ctr_enc='1' and FcntxDP=10) or (alternate_casc='1' and last_block='1' and last_partial='0' and FcntxDP=10) else '1';

FcntxDP<= to_integer(unsigned(f(4 downto 0)));

clk_l  <= clk  or Load_LxS  ; 
clk_i  <= clk  or Load_IxS  ;
 



end architecture cg;
 
