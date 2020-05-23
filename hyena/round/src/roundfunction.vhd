library ieee;
use ieee.std_logic_1164.all;

entity roundfunction is
    port (round_cst : in std_logic_vector(5 downto 0);
          round_key : in std_logic_vector(127 downto 0);
          state_in  : in std_logic_vector(127 downto 0);
          state_out : out std_logic_vector(127 downto 0));
end entity roundfunction;

architecture structural of roundfunction is

    signal sub  : std_logic_vector(127 downto 0);
    signal perm : std_logic_vector(127 downto 0);
    signal mix  : std_logic_vector(127 downto 0);
    
begin

    sl : entity work.substitution port map(state_in, sub);
    pl : entity work.permutation port map(sub, perm);
    kl : entity work.keymixing port map(round_cst, round_key, perm, mix);

    state_out <= mix;

end architecture structural;
