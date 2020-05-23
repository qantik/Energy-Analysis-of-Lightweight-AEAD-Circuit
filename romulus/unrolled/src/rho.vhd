library ieee;
use ieee.std_logic_1164.all;

entity rho is
    generic (CLOCK_GATED : boolean := false);
    port(
        S: in std_logic_vector(127 downto 0);
        M: in std_logic_vector(127 downto 0);

        So : out std_logic_vector(127 downto 0);
        C  : out std_logic_vector(127 downto 0));

end;

architecture behaviour of rho is

    signal state : std_logic_vector(127 downto 0);
    signal g_out : std_logic_vector(127 downto 0);

begin


   s_func : entity WORK.g_mul port map(S, g_out);
   C <= M xor g_out;

   So <= M xor S;

end;

