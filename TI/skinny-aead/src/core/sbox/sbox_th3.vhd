library IEEE;
use IEEE.STD_LOGIC_1164.all;

use work.all;
entity sbox_th3 is
    port (z1 : in  std_logic_vector (7 downto 0);
          z2 : in  std_logic_vector (7 downto 0);
          z3 : in  std_logic_vector (7 downto 0);
          u1 : out std_logic_vector (7 downto 0);
          u2 : out std_logic_vector (7 downto 0);
          u3 : out std_logic_vector (7 downto 0)
          );
end sbox_th3;

architecture PARALLEL of sbox_th3 is


begin

    f8_2_1: entity F8 (skinnypaper) port map (z3(0), z3(3), z3(2), z3(1), z3(6), z3(5), z3(4), z3(7),
                                              z2(0), z2(3), z2(2), z2(1), z2(6), z2(5), z2(4), z2(7),
                                              u1(0), u1(3), u1(2), u1(1), u1(6), u1(5), u1(4), u1(7));
    f8_2_2: entity F8 (skinnypaper) port map (z1(0), z1(3), z1(2), z1(1), z1(6), z1(5), z1(4), z1(7),
                                              z3(0), z3(3), z3(2), z3(1), z3(6), z3(5), z3(4), z3(7),
                                              u2(0), u2(3), u2(2), u2(1), u2(6), u2(5), u2(4), u2(7));
    f8_2_3: entity F8 (skinnypaper) port map (z2(0), z2(3), z2(2), z2(1), z2(6), z2(5), z2(4), z2(7),
                                              z1(0), z1(3), z1(2), z1(1), z1(6), z1(5), z1(4), z1(7),
                                              u3(0), u3(3), u3(2), u3(1), u3(6), u3(5), u3(4), u3(7));

end;
