library ieee;
use ieee.std_logic_1164.all;

entity substitution is
    port (InpxDI : in  std_logic_vector(127 downto 0);
          OupxDO : out std_logic_vector(127 downto 0));
end entity substitution;

architecture structural of substitution is

begin

    gen : for i in 0 to 31 generate
        sb: entity work.sbox port map (InpxDI (4*i+3 downto 4*i), OupxDO(4*i+3 downto 4*i)); 
    end generate;

end architecture structural;


--architecture parallel of substitution is 
--
-- 
--type Atype is array (0 to 31) of std_logic_vector(3 downto 0);
--
--signal A,B: Atype; 
--
--begin 
--
--
--loop1: for i in 0 to 31 generate 
--
--A(i)<= InpxDI(i) & InpxDI(i+32) & InpxDI(i+64) & InpxDI(i+96);
--
--i_sbox: entity work.sbox port map (A(i), B(i));
--
--OupxDO(i)<=B(i)(3);
--OupxDO(i+32)<=B(i)(2);
--OupxDO(i+64)<=B(i)(1);
--OupxDO(i+96)<=B(i)(0);
--
-- 
--
--end generate loop1;
--
--end architecture parallel;
