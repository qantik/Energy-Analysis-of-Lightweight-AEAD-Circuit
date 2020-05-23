library ieee;
use ieee.std_logic_1164.all;

entity substitution_tb is
end;

architecture test of substitution_tb is

    constant input : std_logic_vector(127 downto 0) := X"000102030405060708090A0B0C0D0E0F";
    signal output  : std_logic_vector(127 downto 0);
    
begin

    sub : entity work.substitution
        port map (input, output);

    test : process
    begin

        wait for 100 ns;
        assert false severity failure;
        
    end process;

end;
