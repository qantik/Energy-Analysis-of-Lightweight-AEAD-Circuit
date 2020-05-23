library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity round_counter is
    port (
            rcons_p   : in std_logic_vector(6 downto 0);
            rcons_n   : out std_logic_vector(6 downto 0)
);
end;

architecture comb of round_counter is
begin

    rcons_n <= rcons_p(5 downto 0) & (rcons_p(6) xor rcons_p(5) xor '1');   

end comb;
