library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity ControlLogic is
    generic (R : integer := 1);
    port (RESET     : in std_logic;
          CLK       : in std_logic;
          MODE      : in std_logic;
          
          EN_TMP    : out std_logic;
          SEL_BRANCH: out std_logic;
          SEL_C1    : out std_logic;
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
    
begin

    

    process (CLK)
    begin
        if rising_edge(CLK) then
                counter_p <= counter_n;
        end if;
    end process;
    
    counter_n <= 1 when RESET = '0' else counter_p + 1;

    EN_TMP <= '0' when MODE = '0' and counter_n = branch else '1';
    DONE <= '1' when (MODE = '1' and counter_n = c1_ready) or (MODE ='0' and (counter_n = c1_ready or counter_n = c0_ready)) else '0';    
    SEL_BRANCH <= '1' when counter_n = c1_ready else '0';
    SEL_C1 <= '1' when counter_n = c1_ready else '0';
end Round;
