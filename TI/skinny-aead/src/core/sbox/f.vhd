library IEEE;
use IEEE.STD_LOGIC_1164.all;

use work.all;
entity F8 is
    port (
            w7 : in  std_logic;
            w6 : in  std_logic;
            w5 : in  std_logic;
            w4 : in  std_logic;
            w3 : in  std_logic;
            w2 : in  std_logic;
            w1 : in  std_logic;
            w0 : in  std_logic;
            
            x7 : in  std_logic;
            x6 : in  std_logic;
            x5 : in  std_logic;
            x4 : in  std_logic;
            x3 : in  std_logic;
            x2 : in  std_logic;
            x1 : in  std_logic;
            x0 : in  std_logic;
            
            y7 : out  std_logic;
            y6 : out  std_logic;
            y5 : out  std_logic;
            y4 : out  std_logic;
            y3 : out  std_logic;
            y2 : out  std_logic;
            y1 : out  std_logic;
            y0 : out  std_logic
            
            );
end;

architecture skinnypaper of F8 is


begin

    y0 <= w0 xor (not (not ((x2 nor x3) xor (w2 nor x3))) xor (x2 nor w3));
    y1 <= w1;
    y2 <= w2;
    y3 <= w3;
    y4 <= w4 xor (not (not ((x6 nor x7) xor (w6 nor x7))) xor (x6 nor w7));
    y5 <= w5;
    y6 <= w6;
    y7 <= w7;
    
end;
