library IEEE;
use IEEE.STD_LOGIC_1164.all;

use work.all;
entity sbox_th4 is
    port (u1 : in  std_logic_vector (7 downto 0);
          u2 : in  std_logic_vector (7 downto 0);
          u3 : in  std_logic_vector (7 downto 0);
          y1 : out std_logic_vector (7 downto 0);
          y2 : out std_logic_vector (7 downto 0);
          y3 : out std_logic_vector (7 downto 0)
          );
end sbox_th4;

architecture PARALLEL of sbox_th4 is


begin

    f8_3_1: entity F8 (skinnypaper) port map (u3(5), u3(4), u3(0), u3(3), u3(1), u3(7), u3(6), u3(2),
                                              u2(5), u2(4), u2(0), u2(3), u2(1), u2(7), u2(6), u2(2),
                                              y1(7), y1(6), y1(5), y1(4), y1(3), y1(1), y1(2), y1(0));
    f8_3_2: entity F8 (skinnypaper) port map (u1(5), u1(4), u1(0), u1(3), u1(1), u1(7), u1(6), u1(2),
                                              u3(5), u3(4), u3(0), u3(3), u3(1), u3(7), u3(6), u3(2),
                                              y2(7), y2(6), y2(5), y2(4), y2(3), y2(1), y2(2), y2(0));
    f8_3_3: entity F8 (skinnypaper) port map (u2(5), u2(4), u2(0), u2(3), u2(1), u2(7), u2(6), u2(2),
                                              u1(5), u1(4), u1(0), u1(3), u1(1), u1(7), u1(6), u1(2),
                                              y3(7), y3(6), y3(5), y3(4), y3(3), y3(1), y3(2), y3(0));
end;
