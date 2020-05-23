library IEEE;
use IEEE.STD_LOGIC_1164.all;

use work.all;
entity sbox_th1 is
    port (
          x1 : in  std_logic_vector (7 downto 0);
          x2 : in  std_logic_vector (7 downto 0);
          x3 : in  std_logic_vector (7 downto 0);
          t1 : out std_logic_vector (7 downto 0);
          t2 : out std_logic_vector (7 downto 0);
          t3 : out std_logic_vector (7 downto 0)
          );
end sbox_th1;

architecture PARALLEL of sbox_th1 is

begin


    f8_0_1: entity F8 (skinnypaper) port map (x3(7), x3(6), x3(5), x3(4), x3(3), x3(2), x3(1), x3(0),
                                              x2(7), x2(6), x2(5), x2(4), x2(3), x2(2), x2(1), x2(0),
                                              t1(7), t1(6), t1(5), t1(4), t1(3), t1(2), t1(1), t1(0));
    f8_0_2: entity F8 (skinnypaper) port map (x1(7), x1(6), x1(5), x1(4), x1(3), x1(2), x1(1), x1(0),
                                              x3(7), x3(6), x3(5), x3(4), x3(3), x3(2), x3(1), x3(0),
                                              t2(7), t2(6), t2(5), t2(4), t2(3), t2(2), t2(1), t2(0));
    f8_0_3: entity F8 (skinnypaper) port map (x2(7), x2(6), x2(5), x2(4), x2(3), x2(2), x2(1), x2(0),
                                              x1(7), x1(6), x1(5), x1(4), x1(3), x1(2), x1(1), x1(0),
                                              t3(7), t3(6), t3(5), t3(4), t3(3), t3(2), t3(1), t3(0));
   
end;
