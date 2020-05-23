library ieee;
use ieee.std_logic_1164.all;

entity endian_change is
	generic (BSIZE : integer := 7);
    port (input : in std_logic_vector(8*BSIZE-1 downto 0);

          output: out std_logic_vector(8*BSIZE-1 downto 0));
end;

architecture behaviour of endian_change is
    
begin

    gen_loop : for i in 0 to BSIZE - 1 generate
        output(8*i + 7 downto 8*i) <= input(8*(BSIZE-1-i) + 7 downto 8*(BSIZE-1-i));
    end generate;

end;
