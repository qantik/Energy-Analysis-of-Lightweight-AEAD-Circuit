library IEEE;
use IEEE.STD_LOGIC_1164.all;

use work.all;
entity sbox_th2 is
    port (t1 : in  std_logic_vector (7 downto 0);
          t2 : in  std_logic_vector (7 downto 0);
          t3 : in  std_logic_vector (7 downto 0);
          z1 : out std_logic_vector (7 downto 0);
          z2 : out std_logic_vector (7 downto 0);
          z3 : out std_logic_vector (7 downto 0)
          );
end sbox_th2;

architecture PARALLEL of sbox_th2 is

begin

    
    
    f8_1_1: entity F8 (skinnypaper) port map (t3(2), t3(1), t3(7), t3(6), t3(4), t3(0), t3(3), t3(5),
                                              t2(2), t2(1), t2(7), t2(6), t2(4), t2(0), t2(3), t2(5),
                                              z1(2), z1(1), z1(7), z1(6), z1(4), z1(0), z1(3), z1(5));
    f8_1_2: entity F8 (skinnypaper) port map (t1(2), t1(1), t1(7), t1(6), t1(4), t1(0), t1(3), t1(5),
                                              t3(2), t3(1), t3(7), t3(6), t3(4), t3(0), t3(3), t3(5),
                                              z2(2), z2(1), z2(7), z2(6), z2(4), z2(0), z2(3), z2(5));
    f8_1_3: entity F8 (skinnypaper) port map (t2(2), t2(1), t2(7), t2(6), t2(4), t2(0), t2(3), t2(5),
                                              t1(2), t1(1), t1(7), t1(6), t1(4), t1(0), t1(3), t1(5),
                                              z3(2), z3(1), z3(7), z3(6), z3(4), z3(0), z3(3), z3(5));

end;
