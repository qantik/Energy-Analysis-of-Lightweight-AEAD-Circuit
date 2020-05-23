library std;
use std.textio.all;
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;

entity ControlLogic is
    generic (R : integer := 1);
    port (RESET     : in std_logic;
          CLK       : in std_logic;
          MODE      : in std_logic;
          phase_vec : in std_logic_vector(1 downto 0);
          
          EN_TMP    : out std_logic;
          SEL_BRANCH: out std_logic;
          DONE      : out std_logic
);
end ControlLogic;

architecture Round of ControlLogic is

    function ceil_div (a: integer; b: integer) return integer is
        variable i, bitCount : natural;
    begin
        if a rem b > 0 then
            return 1 + a/b;
        else
            return a/b;
        end if;
    end ceil_div;

    constant rinit          : integer := 25;
    constant r0             : integer := 31;
    constant r1             : integer := 31;
    
    constant branch         : integer := ceil_div(rinit, R);
    constant c1_ready       : integer := ceil_div(rinit + r0, R);
    constant c0_ready       : integer := ceil_div(rinit + r0 + r1, R);
    constant max            : integer := ceil_div(rinit + r0 + r1, R) + 3;

    signal counter_p, counter_n : integer range 0 to max;
    
    signal phase:           integer range 0 to 3;
    
begin

    phase <= to_integer(unsigned(phase_vec));
    

    process (CLK)
    begin
        if rising_edge(CLK) then
                counter_p <= counter_n;
        end if;
    end process;
    
    process (counter_p, phase, RESET)
    begin
        counter_n <= counter_p;
        if RESET = '0' then
            counter_n <= 1;
        elsif phase = 0 then
            counter_n <= counter_p + 1;
        end if;
    end process;
    --counter_n <= 1 when RESET = '0' else counter_p + 1;

    EN_TMP <= '0' when MODE = '0' and counter_n = branch and phase = 3 else '1';
    
    DONE <= '1' when phase = 3 and ((MODE = '1' and counter_n = c1_ready) or (MODE ='0' and (counter_n = c1_ready or counter_n = c0_ready))) else '0';    
    
    SEL_BRANCH <= '1' when (counter_n = c1_ready and phase = 3) else '0';
    
end Round;
